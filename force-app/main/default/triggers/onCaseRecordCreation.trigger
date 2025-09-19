trigger onCaseRecordCreation on Case (after insert) {
    if(trigger.isInsert)
    {
        system.debug('trigger.isInsert');
        List<Case> cList = [Select Id, Subject, CaseNumber,SuppliedPhone, Comments, Description from Case where Id IN :Trigger.new];
        List<Transaction__C> tList = new List<Transaction__C>();
		List<Account> aList = [Select id, Name from Account where AccountNumber in ('XX0690','XX1686','XX9987')];
        List<String> txnIdList = new List<String>();
        for (Case c:cList){
            String mailBody = ''+c.get('Description');
            Decimal AmountValue=0.0;            
            AmountValue=0;     
            System.debug('*********');            
            caseTriggerHelper.fetchMailData(mailBody);
            system.debug('onCaseRecordCreation | caseTriggerHelper.txnDetails ='+ caseTriggerHelper.txnDetails);
            String TxnType = caseTriggerHelper.txnDetails.txnType;
            AmountValue = caseTriggerHelper.txnDetails.amount;
            
            if (caseTriggerHelper.txnDetails.txnType =='Bal')
                c.Subject = 'Weekly Balance | Balance Amount = '+AmountValue  +' || '  + c.Subject;
            else
                c.Subject = ''+TxnType+' - '+AmountValue +' - '+' - ' + c.Subject;
			c.status = 'Working';
            //Creating a Transaction Record in Custom Object
            Transaction__C txn = new Transaction__C();
            for (Account a : aList){
                if(a.Name == caseTriggerHelper.txnDetails.bankAcc){
                    txn.BankAccount__c = a.Id;
                    break;
                }
            }                
            txn.name = ''+TxnType+' - '+AmountValue +' - ' +' | Name : '+caseTriggerHelper.txnDetails.contactName;
            txn.Paid_Date__c = System.today();
            txn.Rent_Amount__c = AmountValue;
            txn.UPI_ID__c = caseTriggerHelper.txnDetails.UPIid;    
            txn.RefNo__c = caseTriggerHelper.txnDetails.refNo; //RefNo;//RefNo__c
            system.debug('onCaseRecordCreation | caseTriggerHelper.txnDetails.refNo = '+caseTriggerHelper.txnDetails.refNo);
            system.debug('onCaseRecordCreation | txn.RefNo__c = '+txn.RefNo__c);
            txn.RentMonth__c = System.today();
            txn.Payment_Mode__c = caseTriggerHelper.txnDetails.txnMode;
            txn.Description__C = c.CaseNumber + '#'+caseTriggerHelper.txnDetails.contactName+'#'+caseTriggerHelper.txnDetails.txnMode;
            
            if 		(TxnType == 'Cr') 	txn.Type__c = 'Income';// if its Credited - Checkbox will be Checked!
            else if (TxnType == 'Dt') 	txn.Type__c = 'Expense';
            else 						txn.Type__c = 'Balance';         
            
            tList.add(txn);            
        }//END 	for (Case c:cList)
        Database.SaveResult[] results = Database.insert(tList,false);
        for (Integer i =0; i<results.size(); i++){
            if(results[i].isSuccess()){
                System.debug('Success record : '+tList[i].Id);
                txnIdList.add(tList[i].Id);
                //txnIdList
                //caseTriggerHelper.txnDetails.txnIdList.add(tList[i].Id);
                clist[i].Description = '< Transaction Record Created Successfully.  >'+clist[i].Description;
            }
            if(!results[i].isSuccess()){
                System.debug('Failed record : '+tList[i]);
                txnIdList.add('Failed');
                clist[i].status = 'Escalated';
				clist[i].Description = ' >>> ' + clist[i].Description; //End of Error Info
                for(Database.Error err : results[i].getErrors())
                    clist[i].Description = '[ '+ err.getMessage() +' ] '+clist[i].Description; // Actual Error Info
				clist[i].Description = ' <<< Transaction Record Could not be Created. Error Meassage :' + clist[i].Description; //Start of Error Info
            }
        }
		update cList;
        
        //txnIdList
        caseTriggerHelper.getContact(txnIdList);
        
	}//END     if(trigger.isInsert)
  
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
*/
// Need to write a scheduled apex call, which executes weekly and deletes 5+days older closed cases - so we can save some storage in salesforce