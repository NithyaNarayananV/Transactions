public with sharing class CreateTxnBigObjectQueuable {
    List<Transaction__c> TList = new List<Transaction__c>();
        public void createTxnInBigObject(List<Transaction__c> TxnList){
        
        List<Transaction_BigData_V3__b> BtxnL = new List<Transaction_BigData_V3__b>();
        Transaction_BigData_V3__b Btxn = new Transaction_BigData_V3__b();

        for (Transaction__c txn : TxnList) {        
            Btxn.Account__c = txn.BankAccount__c;
            Btxn.Amount__c = txn.Rent_Amount__c;
            Btxn.Contact__c = txn.Contact__c;
            Btxn.Mode__c = txn.Payment_Mode__c;
            Btxn.Name__c = txn.Name;
            Btxn.Transaction__c = txn.ID;
            Btxn.Transaction_Date__c = txn.Paid_Date__c;
            Btxn.Type__c = txn.Type__c;
            Btxn.Upi_Id__c = txn.UPI_ID__c;
            BtxnL.add(Btxn);
        }
        if (!BtxnL.isEmpty()) {
            Database.insertImmediate(BtxnL);
        }
    }
    public CreateTxnBigObjectQueuable(List<String> txnIdList) {
           TList = [Select Id, Description__C, RefNo__c, Name, BankAccount__c, Payment_Mode__c, Paid_Date__c, Rent_Amount__c,UPI_ID__c, Type__c, Contact__c from Transaction__c where Id IN :txnIdList];

    }
    public void execute(QueueableContext context) {
        createTxnInBigObject(this.TList);
    }

            //BigObject Creation part //    public void createTxnInBigObject(List<Transaction__c> TxnList){
        //List<Transaction__c> BOTList = [Select Id, Description__C, RefNo__c, Name, BankAccount__c, Payment_Mode__c, Paid_Date__c, Rent_Amount__c,UPI_ID__c, Type__c, Contact__c from Transaction__c where Id IN :txnIdList];
        //
        //system.debug('Big Object Insertion Done');
}