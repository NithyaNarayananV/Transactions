public class masterFuture{
    /* Big Object
    @future  
    public static void testMethod1(Transaction__c Txn){
        

        List<Transaction_BigData__b> BtxnL = new List<Transaction_BigData__b>();
        
        //for (Transaction__c txn : TxnList) {        
        Transaction_BigData__b Btxn = new Transaction_BigData__b();
        Btxn.Name__C = txn.Name;
        Btxn.Transaction_Date__c = txn.Paid_Date__c;
        Btxn.Amount__C = txn.Rent_Amount__c;
        Btxn.UPI_ID__c = txn.UPI_ID__c;
        BtxnL.add(Btxn);
        //}
        if (!BtxnL.isEmpty()) {
            Database.insertImmediate(BtxnL);
        }
           
    } */
   @future
    public static void deleteCase(String cId){
        system.debug('deleteCase called');
        Case caseDelete = [SELECT Id FROM Case WHERE Id = :cId];
        system.debug('caseDelete = '+caseDelete);
        system.debug('caseDelete.Id = '+caseDelete.Id);        
        delete caseDelete;
        system.debug('caseDelete deleted');
    }

}
