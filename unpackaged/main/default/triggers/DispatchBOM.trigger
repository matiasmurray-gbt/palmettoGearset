trigger DispatchBOM on BOM__c (after insert, after update, after delete) {
	// ---------------------------------------------------------------------------
	// Dispatch
    // ---------------------------------------------------------------------------
    if (Trigger.isafter) {
        if (Trigger.isInsert || Trigger.isUpdate) {
            if (DispatchTriggerHandler.triggersEnabled()) {
                DispatchTriggerHandler.BOMToDispatch(Trigger.new, Trigger.old, Trigger.isDelete);
            }
        }
    }
    // ----------------------
}