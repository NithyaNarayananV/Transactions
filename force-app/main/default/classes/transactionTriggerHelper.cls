public class transactionTriggerHelper {
 
    public static transactionTriggerHelper txnDetails;
    //public String 	mailBodyX 	{ get; set; }
    public String 	UPIid 		{ get; set; }
    public String 	contactName { get; set; }
    public String 	refNo 		{ get; set; }
    public String 	txnMode 	{ get; set; }
    public String  	txnType		{ get; set; }
    public String 	bankAcc		{ get; set; }
    public Decimal 	Amount 		{ get; set; }
    public Date 	txnDate 	{ get; set; }

    public static void extractDescription(Transaction__C txn){
        if(txn.Description__C.contains('UPI')){
            system.debug('onTransactionRecCreation | UPI');
            if(txn.Description__C.contains('@')){
                system.debug('onTransactionRecCreation | UPI having @');
                system.debug('Before : caseTriggerHelper.fetchTxnData(Txn);');
                caseTriggerHelper.fetchTxnData(Txn);
				system.debug('After : caseTriggerHelper.fetchTxnData(Txn);');

				/*
                UPI-EASWARAN-EASWARANS2011-6@OKAXIS-AIRP0000001-919999477484-CAM TO AIRPORT
                Type	Name			UPI ID		Some Info	Ref No		Note
                UPI	EASWARAN	EASWARANS2011-6@OKAXIS-AIRP0000001	919999477484	CAM TO AIRPORT
                
                go from 1st Dash =UPI
                2nd Dash = Name
                UPI starts after 2nd Dash.-> make note of Index (IndexA)
                count the dash after @ symbol
                if the dash count is 3 then UPI Id would be from IndexA to the 1st Dash after @.
                if its 4 then then UPI Id would be from IndexA to the 2st Dash after @.
                also vefiry the reference 
                */
                
            }else{system.debug('onTransactionRecCreation | UPI not having @');}
        }else if(txn.Description__C.contains('IB FUNDS TRANSFER')){
            system.debug('onTransactionRecCreation | IB FUNDS TRANSFER');
        }else if(txn.Description__C.contains('INTEREST PAID')){
            system.debug('onTransactionRecCreation | INTEREST PAID');
        }else if(txn.Description__C.contains('FD THROUGH')){
            system.debug('onTransactionRecCreation | FD THROUGH');
        }   
        
        //Contact Tagging needs to be performed belo this.
        
        
	}//End of  public static void extractDescription(Transaction__C txn){

}