trigger onTransactionRecCreation on Transaction__c (before insert, after insert) {
    if (Trigger.isBefore && Trigger.isInsert) {
        transactionTriggerHelper.beforeTrigger(Trigger.new);            
    } else if (Trigger.isAfter && Trigger.isInsert) {
        transactionTriggerHelper.afterTrigger(Trigger.newMap);
    }
}
