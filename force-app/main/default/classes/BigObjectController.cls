public class BigObjectController {
    @AuraEnabled(cacheable=true)
    public static List<Transaction_BigData__b> getTransactionBigDataRecords(){
        System.debug(' BigObjectController > getTransactionBigDataRecords > Start');
        List<Transaction_BigData__b> txnBigList = new List<Transaction_BigData__b>();
        txnBigList = [SELECT Id, CreatedById, CreatedDate, SystemModstamp, Created_DateTime__c, Contact__c, UPI_ID__c, Amount__c, Name__c, Transaction_Date__c, Transaction__c  FROM Transaction_BigData__b LIMIT 50];
    	return txnBigList;
    }
    @AuraEnabled(cacheable=true)
    public static List<Transaction_BigData__b> getTransactionBigDataRecordsforContact(String contactId){
        System.debug(' BigObjectController > getTransactionBigDataRecordsforContact > Start');
        List<Transaction_BigData__b> txnBigList = new List<Transaction_BigData__b>();
        txnBigList = [SELECT Id, CreatedById, CreatedDate, SystemModstamp, Created_DateTime__c, Contact__c, UPI_ID__c, Amount__c, Name__c, Transaction_Date__c, Transaction__c  FROM Transaction_BigData__b  LIMIT 10000];
    	List<Transaction_BigData__b> txnBigListRec = new List<Transaction_BigData__b>();
        for(Transaction_BigData__b txn : txnBigList){
            if(txn.Contact__C == contactId)
            	txnBigListRec.add(txn);
        }
        return txnBigListRec;
    }
}