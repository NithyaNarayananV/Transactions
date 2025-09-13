public with sharing class caseTriggerHelper {
       public String UPIid { get; set; }
        public String contactName { get; set; }
        public Decimal Amount { get; set; }
        public Date txnDate { get; set; }
        public String referenceNumber { get; set; }
        public String txnMode { get; set; }
    public caseTriggerHelper(String upiId,  String contactName, Decimal amount, Date txnDate, String referenceNumber,String txnMode) {
            this.upiId = upiId;
            this.amount = amount;
            this.txnDate = txnDate;
            this.referenceNumber = referenceNumber;
            this.txnMode = txnMode;
            this.contactName = contactName;
    }
        // Wrapper class to hold parsed UPI transaction details
  
    public static caseTriggerHelper fetchUPI(String mailBody){
        //Via VPA
         
        String UPIid = 'Not Found';
        Integer currentIndex = 0;
        if(mailBody.contains('UPI')==true){
            Pattern upiPattern = Pattern.compile('[\\w.-]+@[\\w]+ ');
            Matcher m = upiPattern.matcher(mailBody);
            while(m.find()){
                UPIid = m.group();
                System.debug('Found UPI ID: ' + UPIid);
                break;
            }
        }
        //To find the Contact name in case if its a CreditCard UPI transaction
         String contactName = 'Not Found';
        if(mailBody.contains('Credit Card')){
            Integer UPIidIndexPosition = mailBody.indexOf(UPIid);
            Integer ContactNameIndex = UPIidIndexPosition + UPIid.length();
            Integer EndIndexPosition = mailBody.indexOf(' on ');
            contactName = mailBody.substring(ContactNameIndex, EndIndexPosition).trim();
            System.debug('Extracted Contact Name: ' + contactName);
            
        }
        caseTriggerHelper txnDetails = new caseTriggerHelper(UPIid, contactName, null, null, null, null);

        return txnDetails;
    }
}