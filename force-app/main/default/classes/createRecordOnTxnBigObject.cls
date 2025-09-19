public class createRecordOnTxnBigObject {    
    @future
    public static void receiveParameters(String IdT,String IdC, String Name, Date Paid_Date,Decimal Rent_Amount, String UPIid) {
        //Process the received parameters
        //System.debug('Received message: ' + message);
        //System.debug('Received number: ' + number);
        
        Transaction_BigData__b Btxn = new Transaction_BigData__b();
        Btxn.Transaction__C = IdT;
        Btxn.Name__C = Name;
        Btxn.Transaction_Date__c = Paid_Date;
        Btxn.created_DateTime__C  = DateTime.now();
        Btxn.Amount__C = Rent_Amount;
        Btxn.UPI_ID__c = UPIid;  
        //if(IdC!=null)
        Btxn.Contact__C = ''+IdC;
        database.insertImmediate(Btxn);

    }
}