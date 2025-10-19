public class transactionTriggerHelper {
 
    public static transactionTriggerHelper txnDetails;
    public static List<Contact> conList = [SELECT id, Name, LastName FROM Contact WHERE LastName ='INTEREST PAID'];
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
                INTEREST PAID TILL 30-JUN-2025	000000000000000	1686#000000000000000	2025-07-01	391	Income
                INTEREST PAID TILL 31-MAR-2025	000000000000000	1686#000000000000000	2025-04-01	24	Income

                go from 1st Dash =UPI
                2nd Dash = Name
                UPI starts after 2nd Dash.-> make note of Index (IndexA)
                count the dash after @ symbol
                if the dash count is 3 then UPI Id would be from IndexA to the 1st Dash after @.
                if its 4 then then UPI Id would be from IndexA to the 2st Dash after @.
                also vefiry the reference 
                */
                
            }

            else{system.debug('onTransactionRecCreation | UPI not having @');
                if(txn.Description__C.substring(0,3)=='UPI' && (txn.RefNo__c==null || txn.RefNo__c.length()==0)){ // Bulk Upload form CreditCard Txn.
                    System.debug('onTransactionRecCreation > extractDescription > Inside CreditCard Txn Upload > UPI not having @ and not having Ref No');
                    
                    //Need to Search contact with Name present in the Description.
                    //Need If Found, need to use it. else create a new contact.

                }
                system.debug('onTransactionRecCreation | UPI not having @ but having PAYTM');
            }
        }
        //Need to Work on the Below 1st. > So i can complete the upload from Bank Statement.
        else if(txn.Description__C.contains('IB FUNDS TRANSFER')){
            system.debug('onTransactionRecCreation | IB FUNDS TRANSFER > Nothing to Do with this Right now');
        }else if(txn.Description__C.contains('INTEREST PAID')){
            system.debug('onTransactionRecCreation > INTEREST PAID <Commented>');
            //interestPaid(txn);
            system.debug('Before : caseTriggerHelper.fetchTxnData(Txn);');
            caseTriggerHelper.fetchTxnData(Txn);
            system.debug('After : caseTriggerHelper.fetchTxnData(Txn);');
            //Create a Contact for Interest Paid. and add this to it.
        }else if(txn.Description__C.contains('FD THROUGH')){
            system.debug('onTransactionRecCreation | FD THROUGH');
        }
        else if(txn.Description__C.contains('$')){
            system.debug('Should be from LWC compoenent.');
        }
              //Contact Tagging needs to be performed belo this.
        
        
	}//End of  public static void extractDescription(Transaction__C txn){
    //public static void extractRefere(Transaction__C txn){
    public static void interestPaid(Transaction__C txn){
        System.debug('onTransactionRecCreation > interestPaid > START > txn : '+txn);
        txn.RefNo__c = 'Interest Paid';
        txn.Type__c = 'Income';
        //txn.txnMode = 'Other';
        if(conList.size()>0){
            txn.Contact__c = conList[0].Id;
            conList[0].InComing__c = (conList[0].InComing__c==null) ? txn.Rent_Amount__c : conList[0].InComing__c + txn.Rent_Amount__c;
            conList[0].Balance__c += txn.Rent_Amount__c;
            System.debug('onTransactionRecCreation > interestPaid > Contact Found > conList[0].Id : '+conList[0].Id);
            System.debug('onTransactionRecCreation > interestPaid > Contact Found > txn.Contact__c : '+txn.Contact__c);
            System.debug('onTransactionRecCreation > interestPaid > Contact Found > conList[0].InComing__c : '+conList[0].InComing__c);
            System.debug('onTransactionRecCreation > interestPaid > Contact Found > conList[0].Balance__c : '+conList[0].Balance__c);
        }else{  
            System.debug('onTransactionRecCreation > interestPaid > Contact Not Found > Creating New Contact');
            Contact Cnew = new Contact();
            Cnew.LastName = 'INTEREST PAID';
            insert Cnew;
            txn.Contact__c = Cnew.Id;
            Cnew.InComing__c = txn.Rent_Amount__c;
            Cnew.OutGoing__c = 0;
            Cnew.Balance__c = Cnew.InComing__c - Cnew.OutGoing__c;
            conList.add(Cnew);
            System.debug('onTransactionRecCreation > interestPaid > Contact Created > [Cnew.Id : '+Cnew.Id+'] [ txn.Contact__c : '+txn.Contact__c );
        }


        System.debug('onTransactionRecCreation > interestPaid > END');
    }


}