public class BigObjectController {
    
    @AuraEnabled(cacheable=true)
    public static List<Transaction_BigData_V3__b> getTransactionBigDataRecords() {
        try {
            return [
                SELECT Id, CreatedDate, Contact__c, Upi_Id__c, Amount__c, Name__c, 
                       Transaction_Date__c, Transaction__c, Mode__c, Type__c  
                FROM Transaction_BigData_V3__b  
                LIMIT 10000
            ];
        } catch (QueryException e) {
            System.debug('Error fetching transaction big data records: ' + e.getMessage());
            return new List<Transaction_BigData_V3__b>();
        }
    }
    
    @AuraEnabled(cacheable=true)
    public static List<Transaction_BigData_V3__b> getTransactionBigDataRecordsforContact(Id contactId) {
        if (String.isBlank(contactId)) {
            return new List<Transaction_BigData_V3__b>();
        }
        
        try {
            return [
                SELECT Id, CreatedDate, Contact__c, Upi_Id__c, Amount__c, Name__c, 
                       Transaction_Date__c, Transaction__c, Mode__c, Type__c  
                FROM Transaction_BigData_V3__b 
                WHERE Contact__c = :contactId 
                LIMIT 10000
            ];
        } catch (QueryException e) {
            System.debug('Error fetching contact transaction records: ' + e.getMessage());
            return new List<Transaction_BigData_V3__b>();
        }
    }
}