trigger onCaseRecordCreation on Case (after insert) {
    Case c = [Select Id, Subject, CaseNumber,SuppliedPhone, Comments, Description from Case where Id IN :Trigger.new];
    String mailBody = ''+c.get('Description');
    Boolean WeeklyBalance = False;
    Integer PositionRs = -1, i, PositionVPA,PositionRN;
    Decimal AmountValue=0.0;
    String UPIid='null';
    String TxnType='null';
    String RefNo='000';
    AmountValue=0; 
    PositionVPA = -1;
    i= -1;
    UPIid='';
    System.debug('*********');
    
    Boolean Flag = false;
    //credit card ending 9987
    //AmountValue = extractAmount.getAmount(mailBody);
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
    caseTriggerHelper.fetchUPI(mailBody);
    if(caseTriggerHelper.txnDetails.UPIid !='Not Found'){
        WeeklyBalance = false;
    }
    // Need to create a new method for Account to Account transaction where the UPI id is not present so the contact is not getting tagged.
    //account **0690 to account
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
    AmountValue = caseTriggerHelper.txnDetails.amount;
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
    txn.name = ''+TxnType+' - '+AmountValue +' - '+ UPIid +' | Name : '+caseTriggerHelper.txnDetails.contactName;
    txn.Paid_Date__c = System.today();
    txn.Rent_Amount__c = AmountValue;
    txn.UPI_ID__c = caseTriggerHelper.txnDetails.UPIid;    
    txn.RefNo__c = RefNo;//RefNo__c
    txn.RentMonth__c = System.today();
    txn.Description__C = c.CaseNumber + '#'+caseTriggerHelper.txnDetails.contactName+'#'+caseTriggerHelper.txnDetails.txnMode;
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
        //    ;        
        //if no error - status should be closed Status        
    } catch (DmlException e) {
        //System.debug('An error occurred: ' + e.getMessage());
        //if error - status should be escalated
        c.status = 'Escalated';
        c.Description = '< Transaction Record Could not be Created. Error Meassage : '+ e.getMessage() +'  > ' + c.Description;
        update c;
    }
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
 Account  001NS00000beezpYAA  XX0690
 Account  001NS00000behFTYAY  XX1686
*/
// Need to write a scheduled apex call, which executes weekly and deletes 5+days older closed cases - so we can save some storage in salesforce