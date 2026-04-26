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
            if(txn.Description__C.contains('@')){
                caseTriggerHelper.fetchTxnData(Txn);

				/*
                UPI-NAMEEE-NAMEEE-6@OKAXIS-AIRP0000001-998888477484-CAM TO AIRPORT
                Type	Name			UPI ID		Some Info	Ref No		Note
                UPI	NAMEEE	NAME-6@OKAXIS-AIRP0000001	998888477484	CAM TO AIRPORT
                INTEREST PAID TILL 30-JUN-2025	000000000000000	1234#000000000000000	2025-07-01	391	Income
                INTEREST PAID TILL 31-MAR-2025	000000000000000	1234#000000000000000	2025-04-01	24	Income

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
        txn.RefNo__c = 'Interest Paid';
        txn.Type__c = 'Income';
        //txn.txnMode = 'Other';
        if(conList.size()>0){
            txn.Contact__c = conList[0].Id;
            conList[0].InComing__c = (conList[0].InComing__c==null) ? txn.Rent_Amount__c : conList[0].InComing__c + txn.Rent_Amount__c;
            conList[0].Balance__c += txn.Rent_Amount__c;
           }else{  
            Contact Cnew = new Contact();
            Cnew.LastName = 'INTEREST PAID';
            insert Cnew;
            txn.Contact__c = Cnew.Id;
            Cnew.InComing__c = txn.Rent_Amount__c;
            Cnew.OutGoing__c = 0;
            Cnew.Balance__c = Cnew.InComing__c - Cnew.OutGoing__c;
            conList.add(Cnew);
        }
    }
    public static void beforeTrigger(List<Transaction__c> newTxnList){
       List<Account> aList = [SELECT id, Name FROM Account WHERE AccountNumber != null];
        Integer indexHash1 =  -1;
        Integer indexHash2 =  -1;
        string contactName = 'Not Found';
        string txnType ='';   
        //if there is some thing in Description, then it is Uploaded from Inspector.
        Boolean isFromCase = false;
        Boolean isFromBulkUpload = false;
        Boolean isFromManual = false;
        for (Transaction__c txn: newTxnList){
            if(txn.Description__C.contains('#')){//Its from Case  if(txn.Description__C.contains(#)){//Its from Case '+txn.Description__c);

                isFromCase = true;
                indexHash1 =  txn.Description__C.indexOf('#');
                indexHash2 =  txn.Description__C.indexOf('#',indexHash1+1);
                contactName = Txn.Description__C.substring(indexHash1+1, indexHash2);          
            }
            else if(txn.Description__C.contains('$')){//Should be from LWC compoenent
                isFromManual=true;
                break;
            }
            else{//its from Bulk Upload
                isFromBulkUpload=true;
                transactionTriggerHelper.extractDescription(txn);
                txnType  = (caseTriggerHelper.txnDetails.txnType == 'Income' )? 'Cr':'Dt';// if its Credited - Checkbox will be Checked!

                txn.name = ''+txnType+' - '+Txn.Rent_Amount__c +' - '+caseTriggerHelper.txnDetails.contactName;
                txn.UPI_ID__c = caseTriggerHelper.txnDetails.UPIid;    
                txn.RefNo__c = caseTriggerHelper.txnDetails.refNo; 
                txn.Payment_Mode__c = caseTriggerHelper.txnDetails.txnMode;
                for (Account a : aList){
                    if(a.Name == caseTriggerHelper.txnDetails.bankAcc){
                        txn.BankAccount__c = a.Id;
                        break;
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