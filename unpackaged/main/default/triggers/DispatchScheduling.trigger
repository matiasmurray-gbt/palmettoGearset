trigger DispatchScheduling on Scheduling__c (after update, after insert) {

	// ---------------------------------------------------------------------------
	// Dispatch
	// ---------------------------------------------------------------------------
	if (Trigger.isAfter) {
		if (Trigger.isUpdate || Trigger.isInsert) {
			if (DispatchTriggerHandler.triggersEnabled()) {
				DispatchTriggerHandler.disableTriggers();
				DispatchTriggerHandler.JobToDispatch(Trigger.new, Trigger.old, Trigger.newMap, Trigger.oldMap);
				DispatchTriggerHandler.enableTriggers();
			}
		}
	}
	// ---------------------------------------------------------------------------
}