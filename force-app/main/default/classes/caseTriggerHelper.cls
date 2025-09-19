public with sharing class caseTriggerHelper {
	//public static List<contact> Con;
    public static List<String> upiIdList = new List<String>();
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
    public caseTriggerHelper(String mailBodyX){//String upiId,  String contactName, Decimal amount, Date txnDate, String referenceNumber,String txnMode) {
        this.mailBodyX	= mailBodyX;
        this.upiId 		= getUPIid(); 	// upiId!=null?upiId:this.upiId;
        this.amount 	= getAmount();	//amount!=null?amount:this.amount;
        this.txnDate 	= txnDate!=null?txnDate:this.txnDate;
        this.txnType	= getTxnType();	//this.txnType;
        this.refNo		= getRefNum();		//refNo!=null?refNo:this.refNo;
        this.txnMode 	= getPaymentMode();		//txnMode!=null?txnMode:this.txnMode;
        this.contactName= getContactName(); 	//contactName!=null?contactName:this.contactName;
        this.bankAcc	= getBankAccount();
        upiIdList.add(this.upiId);
        conNameList.add(this.contactName);
    }
    public caseTriggerHelper(Transaction__c txn){//String upiId,  String contactName, Decimal amount, Date txnDate, String referenceNumber,String txnMode) {
        this.desX		= txn.Description__c;
        this.amount 	= txn.Rent_Amount__c;
        this.txnDate 	= txn.Paid_Date__c;
        this.txnType	= txn.Type__c;	//this.txnType;
        this.refNo		= txn.RefNo__c;		//refNo!=null?refNo:this.refNo;
        this.bankAcc	= txn.BankAccount__c;
        this.upiId 		= getUPIidDesc(); 	// upiId!=null?upiId:this.upiId;
        this.txnMode 	= this.txnMode!=null?this.txnMode:getPaymentMode();
        this.contactName= this.contactName!=null?this.contactName:getContactName(); 	//contactName!=null?contactName:this.contactName;        
    }

    public String getUPIidDesc(){
		String UPIid = 'Not Found';
        String UpiTemp ='';        
        if(this.desX!=null && this.refNo !=null ){
            if (this.desX.substring(0,3) == 'UPI' && this.desX.contains('@')){
                //txn.name = ''+TxnType+' - '+AmountValue +' - '+ UPIid ;
                this.txnMode = 'UPI';
                /* Sample Formate 
		 		UPI-EASWARAN-EASWARANS2011-6@OKAXIS-AIRP0000001-919999477484-CAM TO AIRPORT
                Type	Name			UPI ID		Some Info	Ref No		Note
                UPI	EASWARAN	EASWARANS2011-6@OKAXIS-AIRP0000001	919999477484	CAM TO AIRPORT                
                 */ 
                Integer indexHifen1 =  this.desX.indexOf('-'); // before - is UPI Symbol | After - is Contact Name
                Integer indexHifen2 =  this.desX.indexOf('-',indexHifen1+1); //Before - is Contact Name | After - is UPI ID
                Integer indexAt 	=  this.desX.indexOf('@'); // Before @ is partial UPI Id | After @ is balance UPI Id
	 			Integer indexHifen3 =  this.desX.indexOf('-',indexAt+1); //Before - is UPI Id | After - Is some un necessary Number
                Integer indexHifen4 =  this.desX.indexOf('-',indexHifen3+1); //Before - Is some un necessary Number | After - Reference Number
                Integer indexHifen5 =  this.desX.indexOf('-',indexHifen4+1); //Before - Reference Number | After - Note Info

                //Integer indexTxnDecEnd =  txn.Description__C.length();                
                this.contactName = this.desX.substring(indexHifen1+1, indexHifen2);                
                UPIid = this.desX.substring(indexHifen2+1,indexHifen3);               
                UpiTemp = this.desX.substring(indexHifen2+1,indexAt);
                //update Txn;
                system.debug('Txn Updated');
				system.debug('caseTriggerHelper | getUPIidDesc | this.contactName = '+this.contactName);
                system.debug('caseTriggerHelper | getUPIidDesc | UPIid = '+UPIid);
                system.debug('caseTriggerHelper | getUPIidDesc | this.txnMode = '+this.txnMode);
            }
        }            
        return UPIid;
    }
    public String getUPIid(){
        String UPIid = 'Not Found';
        if(this.mailBodyX.contains('UPI')==true){
            Pattern upiPattern = Pattern.compile('[\\w.-]+@[\\w]+ ');
            Matcher m = upiPattern.matcher(this.mailBodyX);
            if(m.find()){
                UPIid = m.group();
                System.debug('Found UPI ID: ' + UPIid);
            }
        }
        return UPIid;
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
        if(mailBodyX.contains('XX0690')==true || mailBodyX.contains('**0690')==true )
            return 'XX0690';
        else if(mailBodyX.contains('XX1686')==true || mailBodyX.contains('**1686')==true )
            return 'XX1686';  
        else if(mailBodyX.contains('XX9987')==true || mailBodyX.contains('**9987')==true )
            return 'XX9987'; 
        //XX9987 
        return '000000';
    }
    
    // Wrapper class to hold parsed UPI transaction details
    public static caseTriggerHelper fetchMailData(String mailBody){
        //Fetches UPI Id, Contact Name, Payment Mode  from the mail body
        txnDetails = new caseTriggerHelper(mailBody);//null, null, null, null, null, null);     
        
        return txnDetails;
    }
	public static caseTriggerHelper fetchTxnData(Transaction__c txn){
        //Fetches UPI Id, Contact Name, Payment Mode  from the mail body
        txnDetails = new caseTriggerHelper(txn);//null, null, null, null, null, null);     
                
        return txnDetails;
    }
	public static void getContact(List<String> INtxnIdList ){//For Contact related works - Future planning
		//if(Con.size()<=0 || Con == null ){
           	//Con = [Select Id, LastName, Description from contact Limit 10000];
			system.debug('Contact related works will take part here');
        //}
        txnIdList=INtxnIdList;
        //Future works need to be done.
        //contactTag( upiIdList,conNameList, txnIdList);
        Id jobId = System.enqueueJob(new contactTag(upiIdList,conNameList, txnIdList));

    }
    
    //the below future is safe to be deleted as i have moved the content to queueable
    //Future for Contact related tagging to Transaction record
    @future
    public static void contactTag( List<String> upiIdList, List<String> conNameList, List<String> txnIdList){
        system.debug('caseTriggerHelper | contactTag | Future is running');
        List<Contact> Con = [Select Id, LastName, Description, InComing__c, OutGoing__c , Balance__c from contact Limit 10000];
        List<Transaction__c> TList = [Select Id, Description__C, RefNo__c, Name, BankAccount__c, Maintenance__c, Payment_Mode__c, Paid_Date__c, Rent_Amount__c,UPI_ID__c, RentMonth__c, Type__c, Contact__c from Transaction__c where Id IN :txnIdList];
        List<String> newConUpiId = new List<String>(); // to hav new upiid alone
        Map<String,String> newUpiAndConId = new Map<String,String>();//to New upiid and its future contact id.
        List<Contact> ConNew = new List<Contact>();
        Integer index = 0;
        String upiIdTemp='';
        //if(upiIdList.size()>0)
        //List<List<Sobject>> searchResults = [FIND :upiIdList IN Description FIELDS RETURNING Contact(Id, LastName, Description)];
        for ( String upiId: upiIdList){            
            if(txnIdList[index]!='Failed'){//only working on the Txn records that are saved into database.
                system.debug('inside => if(txnIdList[index]!=\'Failed\'){//only working on the Txn records that are saved into database.');
                //################### Work here!!!
                upiIdTemp = upiId.substring(0,upiId.indexOf('@'));
                Boolean IsContactTagged = false;
                for(Contact c:con){
                    if(C.Description.contains(upiIdTemp)==true)
                    {    
                        system.debug('Inside For If');
                        TList[index].Contact__c = ''+C.Id; // If contact already Exist, Contact Id will be added to Transaction Record. 
                        IsContactTagged = true;
                        System.debug('Txn Updated | '+C.Description+' || '+upiIdTemp+' || Full =  \\ '+ TList[index].UPI_ID__c);
                        //to update amount field in contact
                        if(TList[index].Type__c == 'Income')                                 
                        {//ContactAmountUpdation.AmountUpdate2Contact( ''+C.Id, TList[index].Rent_Amount__c, 0);
                             if (C.InComing__c == null)
                                    C.InComing__c = TList[index].Rent_Amount__c;
                             else
                                    C.InComing__c +=TList[index].Rent_Amount__c;
                                C.Balance__c = (C.Balance__c == null) ? TList[index].Rent_Amount__c : (C.Balance__c + TList[index].Rent_Amount__c);
                        }
                        else if(TList[index].Type__c == 'Expense') 
                        {// ContactAmountUpdation.AmountUpdate2Contact( C.Id, 0,TList[index].Rent_Amount__c);
                            if (C.OutGoing__c == null)
                                C.OutGoing__c = TList[index].Rent_Amount__c;
                            else
                                C.OutGoing__c +=TList[index].Rent_Amount__c;
                            C.Balance__c = (C.Balance__c == null) ? -TList[index].Rent_Amount__c : (C.Balance__c - TList[index].Rent_Amount__c);            
                        }
                        //break;
                    }                     
                }
                if(!IsContactTagged){
                   /*
                    1. Create contact,
					2. Add it to a common list 
					3. Insert the contact	
					4. after that, update the transaction with the new contact ID in bulk
                    */
                    if (newConUpiId.contains(TList[index].UPI_ID__c)){
                        System.debug('Contact is not present, but previos record have this contact.');
                        //Skip for now
                    }
                    else{
                        Contact Cnew = new Contact();
                        Cnew.Description='\''+TList[index].UPI_ID__c+'\',';
                        //Cnew.HomePhone = Txn.UPI_ID__c;
                        if(conNameList[index] == 'Not Found' || conNameList[index] == null || conNameList[index] == '')
                            Cnew.LastName = ''+UpiIdTemp;
                        else
                            Cnew.LastName = conNameList[index];
                        ConNew.add(Cnew);
                        newConUpiId.add(TList[index].UPI_ID__c);
                        newUpiAndConId.put(TList[index].UPI_ID__c,' ');                        
                    }
                }
            }else{//if the respesctive Txn is Failed to save ito adtabase
                system.debug('Else of if(txnIdList[index]!=\'Failed\')');
            }
            index++;
        }        
        //Time to Create a newContacts in Bulk
        if(ConNew.size()>0)
        {
            Database.SaveResult[] results = Database.insert(ConNew,false);
            for (Integer i =0; i<results.size(); i++){
                if(results[i].isSuccess()){
                    System.debug('Success record : '+ConNew[i].Id);
                    newUpiAndConId.put(newConUpiId[i],''+ConNew[i].Id);
                    //txnIdList.add(ConNew[i].Id);
                    //txnIdList
                    //caseTriggerHelper.txnDetails.txnIdList.add(tList[i].Id);
                    //clist[i].Description = '< Transaction Record Created Successfully.  >'+clist[i].Description;
                }
                if(!results[i].isSuccess()){
                    System.debug('Failed record : '+ConNew[i]);
                }
            }
            //Contacts has been created!        
        } 
    }
}