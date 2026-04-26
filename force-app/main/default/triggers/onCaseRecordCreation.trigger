trigger onCaseRecordCreation on Case (before insert, after insert) {
    if(trigger.isInsert){
        if(trigger.isBefore){
        
        }else if(Trigger.isAfter){
            caseTriggerHelper.caseAfterInsert(Trigger.newMap);
        }
    
        
    }//END     if(trigger.isInsert)
}
    /* Moving the below part to On txn record creation trigger for more customization
    if (!WeeklyBalance){  
        // LookUp Contact in the Transaction Record
        // 1. Add contact to the transaction record
        //     1. Search for contact with UPI id - search in 4 column (dont use mobilephone)
        //       FAX
        //       HomePhone
        //       OtherPhone
        //       Phone
        //       AssistantPhone
*/
// Need to write a scheduled apex call, which executes weekly and deletes 5+days older closed cases - so we can save some storage in salesforce