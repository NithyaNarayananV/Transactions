trigger onCaseRecordCreation on Case (after insert) {
    Case c = [Select Id, Subject, CaseNumber,SuppliedPhone, Comments, Description from Case where Id IN :Trigger.new];
    String mailBody = ''+c.get('Description');
    //System.debug(mailBody);
    //List<String> bodyList = mailBody.split(',');
    //System.debug(bodyList);
    //List<Case> clist = [Select Id, Subject, CaseNumber, Description from Case];
    Boolean WeeklyBalance = False;
    Integer PositionRs = -1, i, PositionVPA,PositionRN;
    Decimal AmountValue=0.0;
    String UPIid='null';
    String TxnType='null';
    String RefNo='000';
    //for (case c:clist){
    AmountValue=0; 
    PositionVPA = -1;
    i= -1;
    UPIid='';
    //String mailBody = ''+c.get('Description');
    System.debug('*********');
    
    Boolean Flag = false;
    //credit card ending 9987
    if(mailBody.contains('Rs.')==true){
        PositionRs = mailBody.indexOf('Rs.');
        PositionRs+=3;
        Flag = true;
    }    
    else if(mailBody.contains('INR')==true){
        PositionRs = mailBody.indexOf('INR');
        PositionRs+=4;
        Flag = true;
    }   
    if (Flag)
    {
        //call function here        
        Decimal[] arrayOfValue = new List<Decimal>();
        arrayOfValue = extractAmount.amountExtraction(mailBody, PositionRs, AmountValue);
        AmountValue = arrayOfValue[0];
        PositionRs = Integer.valueOf(arrayOfValue[1]);
        /*
        for( i= PositionRs; i<PositionRs+10; i++)
        {
        System.debug(mailBody.charAt(i) +' = ' +String.fromCharArray( new List<integer> { mailBody.charAt(i) } ));
        //44 = , //46 = . //48 = 0  //57 = 9
        if(mailBody.charAt(i)==44)
        continue;
        if(mailBody.charAt(i)>47 && mailBody.charAt(i)<58)
        {
        AmountValue*=10;
        AmountValue+=mailBody.charAt(i) - 48;
        }                
        //System.debug(mailBody.charAt(PositionRs));
        if(mailBody.charAt(i)==46)
        { 
        PositionRs = i+1;
        break;
        }
        }
        
        //IsDecimal = true;
        //Decimal addition (2 point) 
        AmountValue *=100;
        AmountValue += (mailBody.charAt(PositionRs) - 48)*10 + (mailBody.charAt(PositionRs+1) - 48);
        AmountValue /=100;
        */
       System.debug('Amount = '+AmountValue + (mailBody.charAt(PositionRs) - 48)/10 + (mailBody.charAt(PositionRs+1) - 48)/100);
   }
    //from now need to differentiate email
    // 1 - Transaction Email having Debited Credited Information
    // 2 - Weekly Balance Update Emails
    
    if(mailBody.contains('credited'))
        TxnType = 'Cr';
    else if (mailBody.contains('debited'))
        TxnType = 'Dt';  
    else {
        TxnType = 'Bal';
        WeeklyBalance = true;
    }
    //need to add UPI ID    
    if(mailBody.contains('VPA')==true){
        WeeklyBalance = false;
        PositionVPA = mailBody.indexOf('VPA');
        PositionVPA+=4;        
        while(mailBody.charAt(PositionVPA) !=32)    // Its a SPACE char
        { if(mailBody.charAt(PositionVPA) ==10)     // New Line Char
            break;
            UPIid+=String.fromCharArray( new List<integer> { mailBody.charAt(PositionVPA) } );    
            PositionVPA+=1;
        }
    }
    // Need to create a new method for Account to Account transaction where the UPI id is not present so the contact is not getting tagged.
    //account **0690 to account
    else if(mailBody.contains('account **0690 to account')==true){
        WeeklyBalance = false;
        PositionVPA = mailBody.indexOf('account **0690 to account');
        PositionVPA+=26;        
        while(mailBody.charAt(PositionVPA) !=32)    // Its a SPACE char
        { if(mailBody.charAt(PositionVPA) ==10)     // New Line Char
            break;
            UPIid+=String.fromCharArray( new List<integer> { mailBody.charAt(PositionVPA) } );    
            PositionVPA+=1;
        }
    }


    //need to extract the Reference Number from the Email

    // Reference Number Extracition END!
    if(mailBody.contains('reference number is')==true){
        PositionRN = mailBody.indexOf('reference number is');
        PositionRN+=20;
        while(mailBody.charAt(PositionRN) !=32 && mailBody.charAt(PositionRN) !=46)
        { if(mailBody.charAt(PositionRN) ==10)
            break;
            RefNo+=String.fromCharArray( new List<integer> { mailBody.charAt(PositionRN) } );    
            PositionRN+=1;
        }
        System.debug('Reference No : '+RefNo);
    }
    //UPI END
    if (WeeklyBalance)
        c.Subject = 'Weekly Balance | Balance Amount = '+AmountValue  +' || '  + c.Subject;
    else
        c.Subject = ''+TxnType+' - '+AmountValue +' - '+ UPIid +' - ' + c.Subject;
    update c;
   
    //Creating a Transaction Record in Custom Object
    Transaction__C txn = new Transaction__C();
    //Adding the Account link to the transactinos 
    /*Account  001NS00000beezpYAA  XX0690
      Account  001NS00000behFTYAY  XX1686*/
    if(mailBody.contains('XX0690')==true || mailBody.contains('**0690')==true )
        txn.BankAccount__c ='001NS00000beezpYAA';
    else if(mailBody.contains('XX1686')==true || mailBody.contains('**1686')==true )
        txn.BankAccount__c ='001NS00000behFTYAY';
    txn.name = ''+TxnType+' - '+AmountValue +' - '+ UPIid ;
    txn.Paid_Date__c = System.today();
    txn.Rent_Amount__c = AmountValue;
    txn.UPI_ID__c = UPIid;    
    txn.RefNo__c = RefNo;//RefNo__c
    txn.RentMonth__c = System.today();
    txn.Description__C = c.CaseNumber;
    if (TxnType == 'Cr') txn.Type__c = 'Income';// if its Credited - Checkbox will be Checked!
    else if (TxnType == 'Dt') txn.Type__c = 'Expense';
    else txn.Type__c = 'Balance';
    c.status = 'Working';
    update c;
    // Insert the txn    
    try{
        //System.debug('txn record created successfully.');
        c.Description = '< Transaction Record Created Successfully.  >' + c.Description;
        update c;

        insert txn;
        //After inserting Txn, case status will be updated in OnTransactionRecCreation trigger.
        if (c.status == 'Closed')
            delete c;
        //if (IsContactTagged)
        //    c.status = 'Closed';        
        //if no error - status should be closed Status        
    } catch (DmlException e) {
        //System.debug('An error occurred: ' + e.getMessage());
        //if error - status should be escalated
        c.status = 'Escalated';
        c.Description = '< Transaction Record Could not be Created. Error Meassage : '+ e.getMessage() +'  > ' + c.Description;
      update c;
    }
    
    /* Moving the below part to On txn record creation trigger for more customization
    if (!WeeklyBalance){  
        // LookUp Contact in the Transaction Record
        // 1. Add contact to the transaction record
        //     1. Search for contact with UPI id - search in 4 column (dont use mobilephone)
        //       FAX
        //       HomePhone
        //       OtherPhone
        //       Phone
        //       AssistantPhone
        List<contact> Con = [Select Id, Fax, HomePhone, OtherPhone, Phone, AssistantPhone from contact];// where (FAX == UPIid or HomePhone = UPIid or OtherPhone = UPIid or Phone = UPIid or AssistantPhone = UPIid)];
        
        for (Contact C : Con){
            if (C.Fax == UPIid || C.HomePhone == UPIid || C.OtherPhone == UPIid || C.Phone == UPIid || C.AssistantPhone == UPIid){
                txn.Contact__c = ''+C.Id; // If contact already Exist, Contact Id will be added to Transaction Record. 
                IsContactTagged = true; 
            }    
        }
        //If Contact is not already present in System (UPI), New contact will be created with UPI id.
        if(!IsContactTagged){          
            Contact Cnew = new Contact();
            Cnew.HomePhone = UPIid;
            Cnew.LastName = ''+UPIid;
            Insert Cnew; // New contact is Inserted
            IsContactTagged = true;
            txn.Contact__c = ''+Cnew.Id; // Contact Details is added to the Transaction record.
        }
    }
    
    // Call the method in TargetClass and pass parameters
    if (!WeeklyBalance)  createRecordOnTxnBigObject.receiveParameters(txn.id,txn.Contact__c, txn.Name, txn.Paid_Date__c, txn.Rent_Amount__c,UPIid);
    */
}
/*
 Account  001NS00000beezpYAA  XX0690
 Account  001NS00000behFTYAY  XX1686
*/
// Need to write a scheduled apex call, which executes weekly and deletes 5+days older closed cases - so we can save some storage in salesforce


global class UpdateAccountStatusBatch implements Database.Batchable<SObject>, Database.Stateful {

    // Member variable to keep track of the number of records processed
    global Integer processedCount = 0;

    // Start method to collect records to be processed
    global Database.QueryLocator start(Database.BatchableContext BC) {
        // Query to select Accounts with Status 'Pending'
        return Database.getQueryLocator('SELECT Id, Status__c FROM Account WHERE Status__c = \'Pending\'');
    }

    // Execute method to process each batch of records
    global void execute(Database.BatchableContext BC, List<Account> scope) {
        // Iterate through each account in the batch and update its status
        for (Account acc : scope) {
            acc.Status__c = 'Active';
        }
        
        // Try to update the records and handle any errors
        try {
            update scope;
            processedCount += scope.size(); // Update the processed count
        } catch (Exception e) {
            // Handle the exception (log error, send email, etc.)
            System.debug('Error updating records: ' + e.getMessage());
        }
    }

    // Finish method for post-processing tasks
    global void finish(Database.BatchableContext BC) {
        // Send a confirmation email after the batch job completes
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[] {'admin@example.com'};
        mail.setToAddresses(toAddresses);
        mail.setSubject('Batch Job Complete');
        mail.setPlainTextBody('The batch job has completed successfully. Number of records processed: ' + processedCount);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        
        // Log the result
        System.debug('Batch job completed successfully. Number of records processed: ' + processedCount);
    }
}



