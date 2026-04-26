public class transactionTriggerHelper {
 
    public static transactionTriggerHelper txnDetails;
    private static List<Contact> conList;
    private static Map<String, Id> accountNameIdMap;
    //public String 	mailBodyX 	{ get; set; }
    public String 	UPIid 		{ get; set; }
    public String 	contactName { get; set; }
    public String 	refNo 		{ get; set; }
    public String 	txnMode 	{ get; set; }
    public String  	txnType		{ get; set; }
    public String 	bankAcc		{ get; set; }
    public Decimal 	Amount 		{ get; set; }
    public Date 	txnDate 	{ get; set; }
    
    // Lazy-load contact list on first use
    private static List<Contact> getInterestPaidContacts() {
        if (conList == null) {
            conList = [SELECT id, Name, LastName FROM Contact WHERE LastName = 'INTEREST PAID' LIMIT 1];
        }
        return conList;
    }
    
    // Lazy-load account map on first use
    private static Map<String, Id> getAccountNameIdMap() {
        if (accountNameIdMap == null) {
            accountNameIdMap = new Map<String, Id>();
            for (Account a : [SELECT id, Name FROM Account WHERE AccountNumber != null]) {
                accountNameIdMap.put(a.Name, a.Id);
            }
        }
        return accountNameIdMap;
    }

    public static void extractDescription(Transaction__C txn){
        if (String.isBlank(txn.Description__C)) {
            return;
        }
        
        String description = txn.Description__C;
        
        if (description.contains('UPI')){
            if (description.contains('@')){
                caseTriggerHelper.fetchTxnData(txn);
            } else if (description.startsWith('UPI') && String.isBlank(txn.RefNo__c)) {
                // Bulk upload from credit card - needs contact name extraction
                // TODO: Implement contact search by name
            }
        } else if (description.contains('IB FUNDS TRANSFER')){
            // Handle IB fund transfers
            return;
        } else if (description.contains('INTEREST PAID')){
            caseTriggerHelper.fetchTxnData(txn);
        } else if (description.contains('FD THROUGH')){
            // Handle FD transactions
            return;
        } else if (description.contains('$')){
            // From LWC component
            return;
        }
    }//End of  public static void extractDescription(Transaction__C txn){
    //public static void extractRefere(Transaction__C txn){
    public static void interestPaid(Transaction__c txn){
        txn.RefNo__c = 'Interest Paid';
        txn.Type__c = 'Income';
        List<Contact> interestContacts = getInterestPaidContacts();
        if(interestContacts.size() > 0){
            txn.Contact__c = interestContacts[0].Id;
            interestContacts[0].InComing__c = (interestContacts[0].InComing__c == null) ? txn.Rent_Amount__c : interestContacts[0].InComing__c + txn.Rent_Amount__c;
            interestContacts[0].Balance__c = (interestContacts[0].Balance__c == null) ? txn.Rent_Amount__c : interestContacts[0].Balance__c + txn.Rent_Amount__c;
        }
        // Note: Contact insert/update should be handled in batch outside trigger
    }
    public static void beforeTrigger(List<Transaction__c> newTxnList){
        Map<String, Id> accountMap = getAccountNameIdMap();
        Integer indexHash1 = -1;
        Integer indexHash2 = -1;
        String contactName = 'Not Found';
        String txnType = '';   
        
        for (Transaction__c txn : newTxnList){
            // Skip if description is null/empty
            if (String.isBlank(txn.Description__C)) {
                continue;
            }
            
            if (txn.Description__C.contains('#')) {
                indexHash1 = txn.Description__C.indexOf('#');
                indexHash2 = txn.Description__C.indexOf('#', indexHash1 + 1);
                if (indexHash2 > indexHash1) {
                    contactName = txn.Description__C.substring(indexHash1 + 1, indexHash2);
                }
            } else if (txn.Description__C.contains('$')) {
                // From LWC component - handle separately
                continue;
            } else {
                // Bulk upload - extract transaction details
                extractDescription(txn);
                if (caseTriggerHelper.txnDetails != null) {
                    txnType = (caseTriggerHelper.txnDetails.txnType == 'Income') ? 'Cr' : 'Dt';
                    txn.name = txnType + ' - ' + txn.Rent_Amount__c + ' - ' + caseTriggerHelper.txnDetails.contactName;
                    txn.UPI_ID__c = caseTriggerHelper.txnDetails.UPIid;    
                    txn.RefNo__c = caseTriggerHelper.txnDetails.refNo; 
                    txn.Payment_Mode__c = caseTriggerHelper.txnDetails.txnMode;
                    
                    // Use map lookup instead of loop
                    if (caseTriggerHelper.txnDetails.bankAcc != null && accountMap.containsKey(caseTriggerHelper.txnDetails.bankAcc)) {
                        txn.BankAccount__c = accountMap.get(caseTriggerHelper.txnDetails.bankAcc);
                    }
                }
            }
        }            
    }
    public static void afterTrigger(map<Id, Transaction__c> newMap){
        List<Id> txnIdList = new List<Id>();
        for (Transaction__c txn : newMap.values()) {
            if (txn.Contact__c == null) {
                txnIdList.add(txn.Id);
            }
        }
        if (!txnIdList.isEmpty()) {
            caseTriggerHelper.getContact(txnIdList);
        }
    }
}