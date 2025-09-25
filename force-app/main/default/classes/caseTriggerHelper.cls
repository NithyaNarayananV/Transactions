public with sharing class caseTriggerHelper {
	//public static List<contact> Con;
    public static List<String> upiIdList = new List<String>();
    public static List<String> upiIdListTemp = new List<String>();
    public static List<String> ConCondition = new List<String>();
    public static List<String> conNameList = new  List<String>();
    public static List<Id> txnIdList;
    public static caseTriggerHelper txnDetails;
    
    public String 	mailBodyX 	{ get; set; }
    public String 	desX 		{ get; set; }
    public String 	UPIid 		{ get; set; }
    public String 	contactName { get; set; }
    public String 	refNo 		{ get; set; }
    public String 	txnMode 	{ get; set; }
    public String  	txnType		{ get; set; }
    public String 	bankAcc		{ get; set; }
    public Decimal 	Amount 		{ get; set; }
    public Date 	txnDate 	{ get; set; }

    //String UPIid = 'Not Found';
    String UpiTemp ='';    
    Integer indexHifen1 = -1;// this.desX.indexOf('-'); // before - is UPI Symbol | After - is Contact Name
    Integer indexHifen2 = -1;// this.desX.indexOf('-',indexHifen1+1); //Before - is Contact Name | After - is UPI ID
    Integer indexAt 	= -1;// this.desX.indexOf('@'); // Before @ is partial UPI Id | After @ is balance UPI Id
    Integer indexHifen3 = -1;// this.desX.indexOf('-',indexAt+1); //Before - is UPI Id | After - Is some un necessary Number
    Integer indexHifen4 = -1;// this.desX.indexOf('-',indexHifen3+1); //Before - Is some un necessary Number | After - Reference Number
    Integer indexHifen5 = -1;// this.desX.indexOf('-',indexHifen4+1); //Before - Reference Number | After - Note Info


    public caseTriggerHelper(String mailBodyX){//String upiId,  String contactName, Decimal amount, Date txnDate, String referenceNumber,String txnMode) {
        this.mailBodyX	= mailBodyX;
        this.upiId 		= getUPIid(); 	// upiId!=null?upiId:this.upiId;
        this.amount 	= getAmount();	//amount!=null?amount:this.amount;
        this.txnDate 	= txnDate!=null?txnDate:this.txnDate;
        this.txnType	= getTxnType();	//this.txnType;
        this.refNo		= getRefNum();		//refNo!=null?refNo:this.refNo;
        this.txnMode 	= getPaymentMode();		//txnMode!=null?txnMode:this.txnMode;
        if (this.txnType=='Bal')
            this.contactName = 'Balance Enquiry';
        else
            this.contactName= getContactName(); 	//contactName!=null?contactName:this.contactName;
        this.bankAcc	= getBankAccount();
        upiIdList.add(this.upiId);
        upiIdListTemp.add(this.UpiTemp);
        ConCondition.add('Upi_Ids__c LIKE \'%'+this.UpiTemp+'%\'');
        System.debug('caseTriggerHelper | Constructor | ConCondition = '+ConCondition);
        //this.upiId.substring(0,this.upiId.indexOf('@'-1))
        conNameList.add(this.contactName);
    }
    public caseTriggerHelper(Transaction__c txn){//String upiId,  String contactName, Decimal amount, Date txnDate, String referenceNumber,String txnMode) {
        this.desX		= txn.Description__c;
        this.amount 	= txn.Rent_Amount__c;
        this.txnDate 	= txn.Paid_Date__c;
        this.txnType	= txn.Type__c;	//this.txnType;
        this.refNo		= txn.RefNo__c;		//refNo!=null?refNo:this.refNo;
        this.bankAcc	= getBankAccount(); //txn.BankAccount__c; // Need to fetch it from the Reference No
        this.upiId 		= getUPIidDesc(); 	// upiId!=null?upiId:this.upiId;
        this.txnMode 	= this.txnMode!=null?this.txnMode:getPaymentMode();
        this.contactName= this.contactName!=null?this.contactName:getContactName(); 	//contactName!=null?contactName:this.contactName;        
        upiIdList.add(this.UpiId);
        upiIdListTemp.add(this.UpiTemp);

        ConCondition.add('Upi_Ids__c LIKE \'%'+this.UpiTemp+'%\'');
        //ConCondition.add('Upi_Ids__c LIKE \'%'+this.upiId.substring(0,this.upiId.indexOf('@')-1)+'%\'');
        conNameList.add(this.contactName);
    }

    
    public String getUPIidDesc(){
        if(this.desX!=null && this.refNo !=null ){
            if (this.desX.substring(0,3) == 'UPI' && this.desX.contains('@')){
                //txn.name = ''+TxnType+' - '+AmountValue +' - '+ UPIid ;
                this.txnMode = 'UPI';
                /* Sample Formate 
		 		UPI-EASWARAN-EASWARANS2011-6@OKAXIS-AIRP0000001-919999477484-CAM TO AIRPORT
                Type	Name			UPI ID		Some Info	Ref No		Note
                UPI	EASWARAN	EASWARANS2011-6@OKAXIS-AIRP0000001	919999477484	CAM TO AIRPORT                
                 */ 
                this.indexHifen1 =  this.desX.indexOf('-'); // before - is UPI Symbol | After - is Contact Name
                this.indexHifen2 =  this.desX.indexOf('-',indexHifen1+1); //Before - is Contact Name | After - is UPI ID
                this.indexAt 	 =  this.desX.indexOf('@'); // Before @ is partial UPI Id | After @ is balance UPI Id
	 			this.indexHifen3 =  this.desX.indexOf('-',indexAt+1); //Before - is UPI Id | After - Is some un necessary Number
                this.indexHifen4 =  this.desX.indexOf('-',indexHifen3+1); //Before - Is some un necessary Number | After - Reference Number
                this.indexHifen5 =  this.desX.indexOf('-',indexHifen4+1); //Before - Reference Number | After - Note Info

                //Integer indexTxnDecEnd =  txn.Description__C.length();                
                this.contactName = this.desX.substring(indexHifen1+1, indexHifen2);                
                this.UPIid = this.desX.substring(indexHifen2+1,indexHifen3);               
                this.UpiTemp = this.desX.substring(indexHifen2+1,indexAt);
                //if(UpiTemp[-2]=='-')
                //    UpiTemp = UpiTemp.substring(0,UpiTemp.length()-2);
                //update Txn;
                system.debug('Txn Updated');
				system.debug('caseTriggerHelper | getUPIidDesc | this.contactName = '+this.contactName);
                system.debug('caseTriggerHelper | getUPIidDesc | UPIid = '+UPIid);
                system.debug('caseTriggerHelper | getUPIidDesc | this.txnMode = '+this.txnMode);
            }
        }            
        return this.UPIid;
    }
    public String getUPIid(){
        //String UPIid = 'Not Found';
        if(this.mailBodyX.contains('UPI')==true){
            Pattern upiPattern = Pattern.compile('[\\w.-]+@[\\w]+ ');
            Matcher m = upiPattern.matcher(this.mailBodyX);
            if(m.find()){
                this.UPIid = m.group();
                System.debug('Found UPI ID: ' + this.UPIid);
            }
            this.UpiTemp = this.UPIid.substring(0,UPIid.indexOf('@'));

        }
        return this.UPIid;
    }
    
    public string getContactName(){ 
        Integer UPIidIndexPosition = this.mailBodyX.indexOf(this.UPIid);
        Integer ContactNameIndex = UPIidIndexPosition + this.UPIid.length();
        Integer EndIndexPosition = this.mailBodyX.indexOf(' on ');
        contactName = this.mailBodyX.substring(ContactNameIndex, EndIndexPosition).trim();
        System.debug('Extracted Contact Name: ' + contactName);
        return contactName;
    }
    public string getPaymentMode(){
        if(this.mailBodyX.contains('Credit Card')==true && this.mailBodyX.contains('UPI')==true)
            return 'UPI Credit Card';
        else if(this.mailBodyX.contains('UPI')==true)
            return 'UPI';
        else if(this.mailBodyX.contains('Credit Card')==true)
            return 'Credit Card';
        return 'Other';
    }
    public Decimal getAmount(){
        String amountString;
        //Pattern currencyPattern = Pattern.compile('\\d{1,3}(,\\d{2})*(\\.\\d{2})');
		Pattern currencyPattern = Pattern.compile('\\b(?:0|[1-9]\\d{0,6})(?:\\.\\d{2})\\b|\\b(?:\\d{1,2},\\d{2},\\d{3}|\\d{1,3}(?:,\\d{3}{1,2})\\.\\d{2})\\b');
        
        if (this.mailBodyX != null && (this.mailBodyX.contains('Rs.') || this.mailBodyX.contains('INR'))) {
            Matcher m = currencyPattern.matcher(this.mailBodyX);
            if (m.find()) 
                amountString = m.group();
        } if (amountString != null) {
            Decimal amountDec = Decimal.valueOf(amountString.replace(',', ''));
            System.debug('Converted Decimal: ' + amountDec);
            return amountDec;
        }
        System.debug('No valid amount found.');
        return 0;
    }
    public String getRefNum(){
        String RefNo='000';
        if(this.mailBodyX.contains('reference number is')==true){
            Integer PositionRN=-1;            
            PositionRN = this.mailBodyX.indexOf('reference number is') + 20;
            while(this.mailBodyX.charAt(PositionRN) !=32 && this.mailBodyX.charAt(PositionRN) !=46){ 
                if(this.mailBodyX.charAt(PositionRN) ==10)
                	break;
                RefNo+=String.fromCharArray( new List<integer> { this.mailBodyX.charAt(PositionRN) } );    
                PositionRN+=1;
            }
            System.debug('class : caseTriggerHelper | Reference No : '+RefNo);            
        }
        return RefNo;
    }
    public String getTxnType(){
        if(this.mailBodyX.contains('credited'))
            return 'Cr';
        else if (this.mailBodyX.contains('debited'))
            return 'Dt';              
        return 'Bal';
    }
    public String getBankAccount(){
        String A90 = 'XX0690';
        String A86 = 'XX1686';
		String A87 = 'XX9987';
        system.debug('class : caseTriggerHelper | getBankAccount | this.refNo : '+this.refNo);
        system.debug('class : caseTriggerHelper | getBankAccount | mailBodyX : '+this.mailBodyX);
        if (this.refNo.contains('#'))//Then its from the Bulk Txn Upload;
        {
            mailBodyX = 'XX'+this.refNo.substring(0,this.refNo.indexOf('#'));
            System.debug('class : caseTriggerHelper | getBankAccount | mailBodyX after modification : '+this.mailBodyX);
            this.refNo = this.refNo.substring(this.refNo.indexOf('#')+1,this.refNo.length());
            return mailBodyX;
        }
        if(mailBodyX.contains('XX0690')==true || mailBodyX.contains('**'+A90)==true)
            return 'XX0690';
        else if(mailBodyX.contains('XX1686')==true || mailBodyX.contains('**'+A86)==true )
            return 'XX1686';  
        else if(mailBodyX.contains('XX9987')==true || mailBodyX.contains('**'+A87)==true )
            return 'XX9987'; 
        //XX9987 
        return '000000';
    }
    
    // Wrapper class to hold parsed UPI transaction details
    public static caseTriggerHelper fetchMailData(String mailBody){
        //Fetches UPI Id, Contact Name, Payment Mode  from the mail body
        txnDetails = new caseTriggerHelper(mailBody);
        return txnDetails;
    }
	public static caseTriggerHelper fetchTxnData(Transaction__c txn){
        //Fetches UPI Id, Contact Name, Payment Mode  from the Transaction's Description
        txnDetails = new caseTriggerHelper(txn);
        return txnDetails;
    }
	public static void getContact(List<String> INtxnIdList ){//For Contact related works - Future planning
		system.debug('Contact related works will take part here');
        txnIdList=INtxnIdList;
        Id jobId = System.enqueueJob(new contactTag(upiIdList, conNameList, txnIdList, ConCondition));
    }
}