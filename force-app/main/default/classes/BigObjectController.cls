public class BigObjectController {
    @AuraEnabled(cacheable=true)
    public static List<Transaction_BigData_V3__b> getTransactionBigDataRecords(){
        System.debug(' BigObjectController > getTransactionBigDataRecords > Start');
        List<Transaction_BigData_V3__b> txnBigList = new List<Transaction_BigData_V3__b>();
        txnBigList = [SELECT Id,CreatedDate, Contact__c, Upi_Id__c, Amount__c, Name__c, Transaction_Date__c, Transaction__c,Mode__c, Type__c  FROM Transaction_BigData_V3__b  LIMIT 10000];
    	return txnBigList;
    }
    @AuraEnabled(cacheable=true)
    public static List<Transaction_BigData_V3__b> getTransactionBigDataRecordsforContact(Id contactId){
        System.debug(' BigObjectController > getTransactionBigDataRecordsforContact > Start');
        List<Transaction_BigData_V3__b> txnBigList = new List<Transaction_BigData_V3__b>();
        txnBigList = [SELECT Id,CreatedDate,  Contact__c, Upi_Id__c, Amount__c, Name__c, Transaction_Date__c, Transaction__c,Mode__c, Type__c  FROM Transaction_BigData_V3__b WHERE Contact__c = :contactId LIMIT 10000];
  
        return txnBigList;
    }
}