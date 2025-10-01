global class dailyCleanUp implements Schedulable{
    global void execute(SchedulableContext sc) {
        // Your logic here
        System.debug('class : dailyCleanUp -> method : execute -> loc : start');
        System.debug('Scheduled Apex is running!');
        transactionDescriptionCleanup();
        System.debug('class : dailyCleanUp -> method : execute -> loc : end');
        
    }


    public static void transactionDescriptionCleanup()
    {
		system.debug('class : dailyCleanUp -> method : transactionDescriptionCleanup -> loc : start');

	 	String queryTransaction ='SELECT Id, Name, LastModifiedDate, Payment_Mode__c, Rent_Amount__c, Contact__c, Paid_Date__c, UPI_ID__c, Type__c, BankAccount__c, Description__c, RefNo__c FROM transaction__c WHERE LastModifiedDate = THIS_WEEK AND LastModifiedDate != TODAY AND LastModifiedDate != YESTERDAY';
        List<Transaction__C> resultTransaction =  Database.query(queryTransaction);
        for(Transaction__C txn: resultTransaction){
            if (txn.Payment_Mode__c!=null &&	txn.Rent_Amount__c!=null &&	txn.Contact__c!=null &&	txn.Paid_Date__c!=null && txn.UPI_ID__c!=null && txn.Type__c!=null && txn.BankAccount__c!=null)
                if( txn.Description__c.contains('#'))
                	txn.Description__c='';
        }
		system.debug('class : dailyCleanUp -> method : transactionDescriptionCleanup -> loc : before update | Update content = resultTransaction = '+resultTransaction);

        update resultTransaction;
		system.debug('class : dailyCleanUp -> method : transactionDescriptionCleanup -> loc : End');


    }
    public static void dailyCleanUp(){
        //Purpose is to remove the description of a record when its last modifiled is more than 24 hrs at the time of this exicution.
    	system.debug('class : dailyCleanUp -> method : dailyCleanUp -> loc : start');
    }

}