trigger onTransactionRecCreation on Transaction__c (after insert) {
    // LookUp Contact in the Transaction Record
    // 1. Add contact to the transaction record
    //     1. Search for contact with UPI id - search in 4 column (dont use mobilephone)
    //       FAX
    System.debug('Start');
    /*
    If the transaction record contains content in Description, separate Deconing needs to be done

     Sept 16th Learing:
1.	Types of inputs when bulk uploaded via inspector from excel:
    UPI with UPI ID
    UPI without UPI ID
    IB Fund Transfer - This can be consided as other transfers
    FD Transactions
    Interest Paid

    how to find whether its from Case or from Bulk upload:
    if it has # in description its form Case
    if it doesnt have # in description its from bulk uploa
     */    
    if(trigger.isInsert){
        List<Transaction__c> TList = [Select Id, Description__C, RefNo__c, Name, BankAccount__c, Payment_Mode__c, Paid_Date__c, Rent_Amount__c,UPI_ID__c, Type__c, Contact__c from Transaction__c where Id IN :Trigger.new];
		List<String> txnIdList = new List<String>();
		List<Account> aList = [Select id, Name from Account where AccountNumber in ('XX0690','XX1686','XX9987')];

        //List<contact> Con = [Select Id, Description from contact];
        Integer indexHash1 =  -1;
        Integer indexHash2 =  -1;
        //Integer indexTxnDecEnd =  txn.Description__C.length();                
        string contactName = 'Not Found';
        string TxnType ='';   
        //if there is some thing in Description, then it is Uploaded from Inspector.
        Boolean IsFromCase = false;
        for (Transaction__c Txn: TList){
            String UpiTemp = '';
            boolean IsContactTagged = false;
            if(txn.Description__C.contains('#')){//Its from Case
                IsFromCase = true;
                system.debug('onTransactionRecCreation | if(txn.Description__C.contains(#)){//Its from Case '+txn.Description__c);
                indexHash1 =  txn.Description__C.indexOf('#');
                indexHash2 =  txn.Description__C.indexOf('#',indexHash1+1);
                contactName = Txn.Description__C.substring(indexHash1+1, indexHash2);                
                //Integer indexTxnDecEnd =  txn.Description__C.length();                
                //(Updated in the Case Trigger)Txn.Payment_Mode__c = Txn.Description__C.substring(indexHash2+1,indexTxnDecEnd)=='Not Found'?null:Txn.Description__C.substring(indexHash2+1,indexTxnDecEnd);
            }
            else{//its from Bulk Upload
				system.debug('onTransactionRecCreation | else part of => if(txn.Description__C.contains(#))//Its from Bulk Upload ');
				transactionTriggerHelper.extractDescription(txn);
                TxnType  = (caseTriggerHelper.txnDetails.TxnType == 'Income' )? 'Cr':'Dt';// if its Credited - Checkbox will be Checked!

                txn.name = ''+TxnType+' - '+Txn.Rent_Amount__c +' - '+caseTriggerHelper.txnDetails.contactName;
                //txn.Paid_Date__c = System.today();
                //txn.Rent_Amount__c = AmountValue;
                txn.UPI_ID__c = caseTriggerHelper.txnDetails.UPIid;    
                txn.RefNo__c = caseTriggerHelper.txnDetails.refNo; //RefNo;//RefNo__c
                system.debug('onTransactionRecCreation | caseTriggerHelper.txnDetails.refNo = '+caseTriggerHelper.txnDetails.refNo);
                system.debug('onTransactionRecCreation | txn.RefNo__c = '+txn.RefNo__c);
                txn.Payment_Mode__c = caseTriggerHelper.txnDetails.txnMode;
                for (Account a : aList){
                    if(a.Name == caseTriggerHelper.txnDetails.bankAcc){
                        txn.BankAccount__c = a.Id;
                        break;
                    }
                }
                //txn.Description__C = c.CaseNumber + '#'+caseTriggerHelper.txnDetails.contactName+'#'+caseTriggerHelper.txnDetails.txnMode;
            }
            txnIdList.add(Txn.Id);
        }            
        update TList;   
        system.debug('onTransactionRecCreation > AFTER > update TList > BEFORE >if(IsFromCase==false)');

        if(IsFromCase==false)
        {
            system.debug('onTransactionRecCreation > if(IsFromCase==false) >  BEFORE > caseTriggerHelper.getContact(txnIdList);  > txnIdList : '+txnIdList);
			caseTriggerHelper.getContact(txnIdList);
            system.debug('onTransactionRecCreation > if(IsFromCase==false) >  AFTER > caseTriggerHelper.getContact(txnIdList);  > txnIdList : '+txnIdList);
        }
 
	}//END if(trigger.isInsert)
}
            /*
            if (Txn.UPI_ID__c!=null)
            	UpiTemp = Txn.UPI_ID__c.substring(0,Txn.UPI_ID__c.indexOf('@'));
            
            System.debug('Before Contact Connect');
            if(Txn.UPI_ID__c!= null){
                system.debug('Inside UPI not null');
                if(Txn.UPI_ID__c.contains('Groww'))
                {
                    Txn.Contact__c = '003NS00000FwzKFYAZ';
                    IsContactTagged = true;
                    Update Txn;
                    System.debug('Txn Updated');
                }                
                else{        
                    //string LikeTemp = '\'%'+UpiTemp+'%\'';
                    //List<contact> Con = [Select Id, Description from contact];// where Description LIKE :LikeTemp ];// where (FAX == UPIid or HomePhone = UPIid or OtherPhone = UPIid or Phone = UPIid or AssistantPhone = UPIid)];
                    for (Contact C : Con){
                        //if (C.Fax == Txn.UPI_ID__c || C.HomePhone == Txn.UPI_ID__c || C.OtherPhone == Txn.UPI_ID__c || C.Phone == Txn.UPI_ID__c || C.AssistantPhone == Txn.UPI_ID__c){
                        //for (String D : C.Description )
                        if (Txn.UPI_ID__c.contains('@'))
                        	UpiTemp = (UpiTemp=='')? Txn.UPI_ID__c.substring(0,Txn.UPI_ID__c.indexOf('@')):UpiTemp;
                        else
                        	UpiTemp = (UpiTemp=='')? Txn.UPI_ID__c:UpiTemp;
                        if(C.Description!=null)
                            if(C.Description.contains(UpiTemp)==true)
                            {    
                                Txn.Contact__c = ''+C.Id; // If contact already Exist, Contact Id will be added to Transaction Record. 
                                IsContactTagged = true;
                                Update Txn;
                                System.debug('Txn Updated | '+C.Description+' || '+UpiTemp+' || Full =  \\ '+ Txn.UPI_ID__c);
                                //to update amount field in contact
                                if(Txn.Type__c == 'Income')                                 
                                    ContactAmountUpdation.AmountUpdate2Contact( ''+C.Id, Txn.Rent_Amount__c, 0);
                                else if(Txn.Type__c == 'Expense')                                 
                                    ContactAmountUpdation.AmountUpdate2Contact( C.Id, 0,Txn.Rent_Amount__c);
                                break;
                            }   
                    }
                }
                //If Contact is not already present in System (UPI), New contact will be created with UPI id.
                if(!IsContactTagged){
                    Contact Cnew = new Contact();
                    Cnew.Description='\''+Txn.UPI_ID__c+'\',';
                    //Cnew.HomePhone = Txn.UPI_ID__c;
    
                    if(contactName == 'Not Found' || contactName == null || contactName == '')
                        Cnew.LastName = ''+UpiTemp;
                    else
                        Cnew.LastName = contactName;
                    Insert Cnew; // New contact is Inserted
                    system.debug('Contact Details will be added to the Transaction record.');
                    Txn.Contact__c = ''+Cnew.Id;// Contact Details is added to the Transaction record.
                    if(Txn.Type__c == 'Income')                                 
                        ContactAmountUpdation.AmountUpdate2Contact( ''+Cnew.Id, Txn.Rent_Amount__c, 0);
                    else if(Txn.Type__c == 'Expense')                                 
                        ContactAmountUpdation.AmountUpdate2Contact( Cnew.Id, 0,Txn.Rent_Amount__c);
                                
                    if(Txn.Contact__c == null)
                    {
                        system.debug('Contact is NUll');
                        //system.debug('Contact is NUll');
                        Txn.Description__C+=Cnew.Id+'>>';
                    }
                    update Txn;
                } 
                //to update amount field in contact
                //AmountUpdate2Contact(String ConId, Decimal Income, Decimal OutGoing)
                    
                System.debug('B4 Big Object');
                
                
                //Call the method in TargetClass and pass parameters
                if(Txn.Contact__c == null)
                    {system.debug('Contact is NUll');}
                else 
                    createRecordOnTxnBigObject.receiveParameters(Txn.id,Txn.Contact__c, Txn.Name, Txn.Paid_Date__c, Txn.Rent_Amount__c,Txn.UPI_ID__c);
                if(txn.Description__C.contains('#'))

                try{
                    String caseNo = Txn.Description__C.substring(0, 8);
                    Case C = [Select CaseNumber, Status from case where CaseNumber = :caseNo ];// where (FAX == UPIid or HomePhone = UPIid or OtherPhone = UPIid or Phone = UPIid or AssistantPhone = UPIid)];
                    system.debug(c);                
                    if (c.CaseNumber == Txn.Description__C){
                        c.Status = 'Closed';
                        IsContactTagged= true;
                        System.debug(c.Status + '  | This record should be in Closed state');
                        update c;
                        if (c.Status == 'Closed')
                            masterFuture.deleteCase(''+c.id);
                    }
                }
                catch (DmlException e) {
                    System.debug('Error : Case detilas issue ' + e.getMessage());
                }
            }
            else if (Txn.Type__c == 'Balance')
            {
                Account AccUpdate = [Select Id, Balance__c from Account where id = :Txn.BankAccount__c ];// where (FAX == UPIid or HomePhone = UPIid or OtherPhone = UPIid or Phone = UPIid or AssistantPhone = UPIid)];
                AccUpdate.Balance__c =   Txn.Rent_Amount__c;
                update AccUpdate;
                try{
                    Case C = [Select CaseNumber, Status from case where CaseNumber = :Txn.Description__C ];// where (FAX == UPIid or HomePhone = UPIid or OtherPhone = UPIid or Phone = UPIid or AssistantPhone = UPIid)];
                    system.debug(c);
                    if (c.CaseNumber == Txn.Description__C){
                        masterFuture.deleteCase(''+c.id);
                        masterFuture.deleteTxn(''+Txn.id);
                    }
                }
                catch (DmlException e) {
                    System.debug('Error : Case detilas issue ' + e.getMessage());
                }
            }*/