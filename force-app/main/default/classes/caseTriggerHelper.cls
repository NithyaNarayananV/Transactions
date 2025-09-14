public with sharing class caseTriggerHelper {
    public static caseTriggerHelper txnDetails;
    public String mailBodyX { get; set; }
    public String UPIid { get; set; }
    public String contactName { get; set; }
    public Decimal Amount { get; set; }
    public Date txnDate { get; set; }
    public String referenceNumber { get; set; }
    public String txnMode { get; set; }
    public caseTriggerHelper(String mailBodyX){//String upiId,  String contactName, Decimal amount, Date txnDate, String referenceNumber,String txnMode) {
        this.mailBodyX = mailBodyX;
        this.upiId = getUPIid(); // upiId!=null?upiId:this.upiId;
        this.amount = getAmount();//amount!=null?amount:this.amount;
        this.txnDate = txnDate!=null?txnDate:this.txnDate;
        this.referenceNumber = referenceNumber!=null?referenceNumber:this.referenceNumber;
        this.txnMode = getPaymentMode();//txnMode!=null?txnMode:this.txnMode;
        this.contactName = getContactName(); //contactName!=null?contactName:this.contactName;
    }
    public String getUPIid(){
        Integer currentIndex = 0;
        String UPIid = 'Not Found';
        if(this.mailBodyX.contains('UPI')==true){
            Pattern upiPattern = Pattern.compile('[\\w.-]+@[\\w]+ ');
            Matcher m = upiPattern.matcher(this.mailBodyX);
            if(m.find()){
                UPIid = m.group();
                System.debug('Found UPI ID: ' + UPIid);
            }
        }
        this.UPIid = UPIid;
        return UPIid;
    }
    public string getContactName(){ 
        Integer UPIidIndexPosition = this.mailBodyX.indexOf(this.UPIid);
        Integer ContactNameIndex = UPIidIndexPosition + this.UPIid.length();
        Integer EndIndexPosition = this.mailBodyX.indexOf(' on ');
        contactName = this.mailBodyX.substring(ContactNameIndex, EndIndexPosition).trim();
        System.debug('Extracted Contact Name: ' + contactName);
        this.contactName = contactName;
        return contactName;
    }
    public string getPaymentMode(){
        if(this.mailBodyX.contains('Credit Card')==true && this.mailBodyX.contains('UPI')==true)
            this.txnMode = 'UPI Credit Card';
        else if(this.mailBodyX.contains('UPI')==true)
            this.txnMode = 'UPI';
        else if(this.mailBodyX.contains('Credit Card')==true)
            this.txnMode = 'Credit Card';
        return this.txnMode;
    }
    public Decimal getAmount(){
        String amountString = '-1';
        Pattern currencyPattern = Pattern.compile('\\d{1,2}(,\\d{2})*(\\.\\d{2})');
        if(this.mailBodyX.contains('Rs.')==true || this.mailBodyX.contains('INR')==true){
            Matcher m = currencyPattern.matcher(this.mailBodyX);
            if(m.find()){
                amountString = m.group();
            }
        }
        Decimal amountDec = Decimal.valueOf(amountString.replace(',', ''));
        System.debug('Converted Decimal: ' + amountDec);
        return amountDec;
    }
    
    // Wrapper class to hold parsed UPI transaction details
    public static caseTriggerHelper fetchUPI(String mailBody){
        //Fetches UPI Id, Contact Name, Payment Mode  from the mail body
        txnDetails = new caseTriggerHelper(mailBody);//null, null, null, null, null, null);     
        return txnDetails;
    }
}