public with sharing class CreateTxnBigObjectQueuable implements Queueable {
    
    private List<String> txnIdList = new List<String>();
    private static final Integer MAX_STRING_LENGTH = 20;
    private static final Integer MAX_NAME_LENGTH = 30;
    
    public CreateTxnBigObjectQueuable(List<String> txnIdList) {
        this.txnIdList = txnIdList != null ? txnIdList : new List<String>();
    }
    
    public void execute(QueueableContext context) {
        if (txnIdList.isEmpty()) {
            return;
        }
        
        try {
            List<Transaction__c> txnList = [
                SELECT Id, Description__C, RefNo__c, Name, BankAccount__c, Payment_Mode__c, 
                       Paid_Date__c, Rent_Amount__c, UPI_ID__c, Type__c, Contact__c 
                FROM Transaction__c 
                WHERE Id IN :txnIdList
                LIMIT 10000
            ];
            
            createTxnInBigObject(txnList);
        } catch (QueryException e) {
            System.debug('Error querying transactions: ' + e.getMessage());
        }
    }
    
    private void createTxnInBigObject(List<Transaction__c> txnList) {
        if (txnList == null || txnList.isEmpty()) {
            return;
        }
        
        List<Transaction_BigData_V3__b> bigObjectList = new List<Transaction_BigData_V3__b>();
        
        for (Transaction__c txn : txnList) {
            Transaction_BigData_V3__b bigObjRecord = new Transaction_BigData_V3__b();
            
            // Safely assign values with null checks and truncation
            bigObjRecord.Account__c = txn.BankAccount__c;
            bigObjRecord.Amount__c = txn.Rent_Amount__c;
            bigObjRecord.Contact__c = txn.Contact__c;
            bigObjRecord.Mode1__c = 'NA';
            bigObjRecord.Mode__c = truncateString(txn.Payment_Mode__c, MAX_STRING_LENGTH);
            bigObjRecord.Name__c = truncateString(txn.Name, MAX_NAME_LENGTH);
            bigObjRecord.Note__c = 'NA';
            bigObjRecord.RefNumber__c = txn.RefNo__c;
            bigObjRecord.Transaction__c = txn.Id;
            bigObjRecord.Transaction_Date__c = txn.Paid_Date__c;
            bigObjRecord.Type__c = txn.Type__c;
            bigObjRecord.Upi_Id__c = txn.UPI_ID__c;
            
            bigObjectList.add(bigObjRecord);
        }
        
        if (!bigObjectList.isEmpty()) {
            insertBigObjectRecords(bigObjectList);
        }
    }
    
    private void insertBigObjectRecords(List<Transaction_BigData_V3__b> records) {
        try {
            // Corrected: Removed the 'false' parameter
            List<Database.SaveResult> results = Database.insertImmediate(records);
            
            for (Integer i = 0; i < results.size(); i++) {
                if (!results[i].isSuccess()) {
                    for (Database.Error error : results[i].getErrors()) {
                        System.debug('Error inserting record ' + i + ': ' + error.getMessage());
                        System.debug('Status Code: ' + error.getStatusCode());
                    }
                }
            }
        } catch (Exception e) {
            // Database.insertImmediate can throw an exception if the entire call fails 
            // (e.g., if the list is null or metadata is missing)
            System.debug('Exception during big object insertion: ' + e.getMessage());
        }
    }
    private String truncateString(String value, Integer maxLength) {
        if (String.isBlank(value)) {
            return '';
        }
        return value.length() > maxLength ? value.substring(0, maxLength) : value;
    }
}