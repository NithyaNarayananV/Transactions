public with sharing class CreateTxnBigObjectQueuable implements Queueable {
    List<String> TxnIDLt = new List<String>(); 
    List<Transaction__c> TList = new List<Transaction__c>();
    public void createTxnInBigObject(List<Transaction__c> TxnList){
        system.debug('CreateTxnBigObjectQueuable > createTxnInBigObject > Start > TxnList : '+TxnList);
        List<Transaction_BigData_V3__b> BtxnL = new List<Transaction_BigData_V3__b>();
        for (Transaction__c txn : TxnList) {    
            Transaction_BigData_V3__b Btxn = new Transaction_BigData_V3__b();
            system.debug('CreateTxnBigObjectQueuable > createTxnInBigObject > for (Transaction__c txn : TxnList) > START > txn : '+txn);
            Btxn.Account__c 	= txn.BankAccount__c;
            Btxn.Amount__c 		= txn.Rent_Amount__c;
            Btxn.Contact__c 	= txn.Contact__c;
            Btxn.Mode__c 		= txn.Payment_Mode__c;
            Btxn.Name__c 		= (txn.Name.Length()>30) ? txn.Name.SubString(0,30) : txn.Name; // Name__C's Max limit is 30.
            Btxn.Note__c 		= 'NA';	// to update the Note given in the transaction. -> Future works
            Btxn.RefNumber__c 	= txn.RefNo__c;
            Btxn.Transaction__c = txn.ID;
            Btxn.Transaction_Date__c = txn.Paid_Date__c;
            Btxn.Type__c 		= txn.Type__c;
            Btxn.Upi_Id__c 		= txn.UPI_ID__c;
            BtxnL.add(Btxn);
            system.debug('CreateTxnBigObjectQueuable > createTxnInBigObject > for (Transaction__c txn : TxnList) > END  > Btxn : '+Btxn);
        }
        if (!BtxnL.isEmpty()) {
            system.debug('CreateTxnBigObjectQueuable > createTxnInBigObject > if (!BtxnL.isEmpty())  > START  > BtxnL : '+BtxnL);
            List<Database.SaveResult> results = Database.insertImmediate(BtxnL);
            for(Database.SaveResult result : results ){
                if(!result.isSuccess()){
                    System.debug('CreateTxnBigObjectQueuable > createTxnInBigObject > Error in Insertion : '+result.getErrors()[0].getMessage());
                }else{
                    System.debug('CreateTxnBigObjectQueuable > createTxnInBigObject > Successfully inserted : '+result);
                }
            }
            system.debug('CreateTxnBigObjectQueuable > createTxnInBigObject > if (!BtxnL.isEmpty())  > END  > BtxnL : '+BtxnL);
        }
    }
    public CreateTxnBigObjectQueuable(List<String> txnIdList) {
        this.TxnIDLt = txnIdList;
    }
    public void execute(QueueableContext context) {
        this.TList = [SELECT Id, Description__C, RefNo__c, Name, BankAccount__c, Payment_Mode__c, Paid_Date__c, Rent_Amount__c, UPI_ID__c, Type__c, Contact__c FROM Transaction__c WHERE Id IN :TxnIDLt];
        system.debug('CreateTxnBigObjectQueuable > execute > START > this.TList : '+this.TList);
        createTxnInBigObject(this.TList);
        system.debug('CreateTxnBigObjectQueuable > execute > AFTER > createTxnInBigObject(this.TList);');
    }
    //BigObject Creation part //    public void createTxnInBigObject(List<Transaction__c> TxnList){
    //List<Transaction__c> BOTList = [Select Id, Description__C, RefNo__c, Name, BankAccount__c, Payment_Mode__c, Paid_Date__c, Rent_Amount__c,UPI_ID__c, Type__c, Contact__c from Transaction__c where Id IN :txnIdList];
    //
    //system.debug('Big Object Insertion Done');
}