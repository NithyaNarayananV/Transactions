trigger onCaseRecordCreation on Case (before insert, after insert) {
    if (Trigger.isBefore && Trigger.isInsert) {
        // Before insert logic if needed
    } else if (Trigger.isAfter && Trigger.isInsert) {
        caseTriggerHelper.caseAfterInsert(Trigger.newMap);
    }
}