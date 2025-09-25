public class BigObjectController {
    @AuraEnabled(cacheable=true)
    public static List<Transaction_BigData__b> getTransactionBigDataRecords(){
        System.debug(' BigObjectController > getTransactionBigDataRecords > Start');
        List<Transaction_BigData__b> txnBigList = new List<Transaction_BigData__b>();
        txnBigList = [SELECT Id, CreatedById, CreatedDate, SystemModstamp, Created_DateTime__c, Contact__c, UPI_ID__c, Amount__c, Name__c, Transaction_Date__c, Transaction__c  FROM Transaction_BigData__b LIMIT 50];
    	return txnBigList;
    }
    @AuraEnabled(cacheable=true)
    public static List<Transaction_BigData_V2__b> getTransactionBigDataRecordsforContact(Id contactId){
        System.debug(' BigObjectController > getTransactionBigDataRecordsforContact > Start');
        List<Transaction_BigData_V2__b> txnBigList = new List<Transaction_BigData_V2__b>();
        txnBigList = [SELECT Id, Contact__c, UPI_ID__c, Amount__c, Name__c, Transaction_Date__c, Transaction__c,Mode__C, Type__c  FROM Transaction_BigData_V2__b WHERE Contact__c = :contactId LIMIT 10000];
  
        return txnBigList;
    }
}