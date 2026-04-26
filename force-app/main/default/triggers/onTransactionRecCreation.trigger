trigger onTransactionRecCreation on Transaction__c (after insert, before insert) {
    // LookUp Contact in the Transaction Record
    // 1. Add contact to the transaction record
    //     1. Search for contact with UPI id - search in 4 column (dont use mobilephone)
    //       FAX
    /*
    If the transaction record contains content in Description, separate Deconing needs to be done

     Sept 16th Learing:
1.	Types of inputs when bulk uploaded via inspector from excel:
    UPI with UPI ID
    UPI without UPI ID
    IB Fund Transfer - This can be consided as other transfers
    FD Transactions
    Interest Paid

    how to find whether its from Case or from Bulk upload:
    if it has # in description its form Case
    if it doesnt have # in description its from bulk uploa
     */    
    if(trigger.isInsert){
        if(trigger.isBefore){
            transactionTriggerHelper.beforeTrigger(Trigger.new);            
        } else if (Trigger.isAfter) {
            transactionTriggerHelper.afterTrigger(Trigger.newMap);
           
        }
	}
}
