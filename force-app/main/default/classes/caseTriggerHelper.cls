public with sharing class caseTriggerHelper {
    public static List<String> upiIdList = new List<String>();
    public static List<String> upiIdListTemp = new List<String>();
    public static List<String> ConCondition = new List<String>();
    public static List<String> conNameList = new List<String>();
    public static List<Id> txnIdList;
    public static caseTriggerHelper txnDetails;
    
    private static Map<String, Id> accountNameIdMap;
    
    private static Map<String, Id> getAccountNameIdMap() {
        if (accountNameIdMap == null) {
            accountNameIdMap = new Map<String, Id>();
            for (Account a : [SELECT id, Name FROM Account WHERE AccountNumber != null LIMIT 10000]) {
                accountNameIdMap.put(a.Name, a.Id);
            }
        }
        return accountNameIdMap;
    }
    
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


    public caseTriggerHelper(String mailBodyX) {
        if (String.isBlank(mailBodyX)) return;
        
        this.mailBodyX = mailBodyX;
        this.upiId = getUPIid();
        this.amount = getAmount();
        this.txnType = getTxnType();
        this.refNo = getRefNum();
        this.txnMode = getPaymentMode();
        this.contactName = (this.txnType == 'Bal') ? 'Balance Enquiry' : getContactName();
        this.bankAcc = getBankAccount();
        
        if (String.isNotBlank(this.upiId)) {
            upiIdList.add(this.upiId);
            upiIdListTemp.add(this.UpiTemp);
            ConCondition.add('Upi_Ids__c LIKE \'%' + this.UpiTemp + '%\'');
            conNameList.add(String.isNotBlank(this.contactName) ? this.contactName : 'Not Found');
        }
    }
    public caseTriggerHelper(Transaction__c txn) {
        if (txn == null) return;
        
        this.desX = txn.Description__c;
        this.amount = txn.Rent_Amount__c;
        this.txnDate = txn.Paid_Date__c;
        this.txnType = txn.Type__c;
        this.refNo = txn.RefNo__c;
        this.bankAcc = getBankAccount();
        this.upiId = getUPIidDesc();
        this.txnMode = String.isNotBlank(this.txnMode) ? this.txnMode : getPaymentMode();
        this.contactName = String.isNotBlank(this.contactName) ? this.contactName : getContactName();
        
        if (String.isNotBlank(this.UpiId)) {
            upiIdList.add(this.UpiId);
            upiIdListTemp.add(this.UpiTemp);
            ConCondition.add('Upi_Ids__c LIKE \'%' + this.UpiTemp + '%\'');
            conNameList.add(String.isNotBlank(this.contactName) ? this.contactName : 'Not Found');
        }
    }

    
    public String getUPIidDesc(){
        //if(this.desX.contains('UPI')){

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
            }else if(this.desX.contains('INTEREST PAID')){
                this.txnMode = 'Other';
                this.contactName = 'INTEREST PAID';
                this.UPIid = 'INTEREST PAID';
                this.UpiTemp = 'INTEREST PAID';
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
        }else if(this.mailBodyX.contains('towards')==true){
            Integer startIndex = this.mailBodyX.indexOf('towards') + 8; // 8 is the length of 'towards' + 1 for space
            Integer endIndex = this.mailBodyX.indexOf(' on ', startIndex);
            this.UPIid = this.mailBodyX.substring(startIndex, endIndex).trim();
            this.UpiTemp = this.UPIid;
            this.contactName = this.UPIid;
        }
        return this.UPIid;
    }
    
    public String getContactName() { 
        if (String.isBlank(this.mailBodyX) || String.isBlank(this.UPIid)) {
            return 'Not Found';
        }
        
        try {
            Integer upiIdIndexPosition = this.mailBodyX.indexOf(this.UPIid);
            Integer contactNameIndex = upiIdIndexPosition + this.UPIid.length();
            Integer endIndexPosition = this.mailBodyX.indexOf(' on ');
            
            if (endIndexPosition > contactNameIndex && contactNameIndex >= 0) {
                return this.mailBodyX.substring(contactNameIndex, endIndexPosition).trim();
            }
        } catch (Exception e) {
            return 'Not Found';
        }
        return 'Not Found';
    }
    
    public String getPaymentMode() {
        if (String.isBlank(this.mailBodyX)) {
            return 'Other';
        }
        if (this.mailBodyX.contains('Credit Card') && this.mailBodyX.contains('UPI')) {
            return 'UPI Credit Card';
        } else if (this.mailBodyX.contains('UPI')) {
            return 'UPI';
        } else if (this.mailBodyX.contains('Credit Card')) {
            return 'Credit Card';
        }
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
    public String getBankAccount() {
        if (String.isBlank(this.refNo)) {
            return 'NA';
        }
        
        if (this.refNo.contains('#')) {
            try {
                Integer hashIndex = this.refNo.indexOf('#');
                String bankAccount = 'XX' + this.refNo.substring(0, hashIndex);
                this.refNo = this.refNo.substring(hashIndex + 1, this.refNo.length());
                return bankAccount;
            } catch (Exception e) {
                return 'NA';
            }
        }
        
        // Search in account map for matching account
        Map<String, Id> accountMap = getAccountNameIdMap();
        for (String accountName : accountMap.keySet()) {
            if (String.isNotBlank(this.mailBodyX) && this.mailBodyX.contains(accountName)) {
                return accountName;
            }
        }
        return 'NA';
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
    public static void caseBeforeInsert(List<Case> newCaseList){
        
    }
    public static void caseAfterInsert(Map<Id, Case> newCaseMap){
        List<Transaction__C> tList  = new List<Transaction__C>();
        List<Account> aList         = [Select id, Name from Account where AccountNumber != null];
        List<String> txnIdList      = new List<String>();
        List<Id> deleteCaseId = new List<Id>();
        for (Case c : newCaseMap.values()){
            String mailBody = ''+c.get('Description');
            String TxnType ='';
            Decimal AmountValue = 0.0;
            AmountValue = 0;
            caseTriggerHelper.fetchMailData(mailBody);
            TxnType     = caseTriggerHelper.txnDetails.txnType;
            AmountValue = caseTriggerHelper.txnDetails.amount;
            Transaction__C txn = new Transaction__C();
            for (Account a : aList){
                if(a.Name == caseTriggerHelper.txnDetails.bankAcc){
                    txn.BankAccount__c = a.Id;
                    break;
                }
            }
            txn.name = ''+TxnType+' - '+AmountValue +' - '+caseTriggerHelper.txnDetails.contactName;
            txn.Paid_Date__c = System.today();
            txn.Rent_Amount__c = AmountValue;
            txn.UPI_ID__c = caseTriggerHelper.txnDetails.UPIid;    
            txn.RefNo__c = caseTriggerHelper.txnDetails.refNo; //RefNo;//RefNo__c
            txn.Payment_Mode__c = caseTriggerHelper.txnDetails.txnMode;
            txn.Description__C = 'Case'+c.CaseNumber + '#'+caseTriggerHelper.txnDetails.contactName+'#'+caseTriggerHelper.txnDetails.txnMode;
            if 		(TxnType == 'Cr') 	txn.Type__c = 'Income';// if its Credited - Checkbox will be Checked!
            else if (TxnType == 'Dt') 	txn.Type__c = 'Expense';
            else 						txn.Type__c = 'Balance';
            
            tList.add(txn);   
        }
        Database.SaveResult[] results = Database.insert(tList,false);
        for (Integer i =0; i<results.size(); i++){
            if(results[i].isSuccess()){
                txnIdList.add(tList[i].Id);
                deleteCaseId.add(newCaseMap.values()[i].Id);
            }
            if(!results[i].isSuccess()){
                System.debug('Failed record : '+tList[i]);
                txnIdList.add(null);
            }
        }
		//update newCaseMap.values();
        caseTriggerHelper.getContact(txnIdList);
        caseTriggerHelper.deleteCase(deleteCaseId);
    }
    @future
    private static void deleteCase(List<Id> deleteCaseId){
        List<Case> cList = [Select Id from Case where Id IN :deleteCaseId];
        delete cList;
    }
}