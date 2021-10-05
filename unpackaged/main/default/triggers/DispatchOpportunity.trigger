trigger DispatchOpportunity on Opportunity (after update) {
	// ---------------------------------------------------------------------------
	// Dispatch
    // ---------------------------------------------------------------------------
    if (Trigger.isafter) {
        if (Trigger.isUpdate) {
            if (DispatchTriggerHandler.triggersEnabled()) {
                DispatchTriggerHandler.OpportunityToDispatch(Trigger.newMap);
            }
        }
    }
    // ----------------------
}