trigger DispatchNote on Note (before insert, before update, after insert) {
	// ---------------------------------------------------------------------------
	// Dispatch
    // ---------------------------------------------------------------------------
	if (Trigger.isInsert && Trigger.isAfter) {
		if (DispatchTriggerHandler.triggersEnabled()) {
			DispatchTriggerHandler.disableTriggers();
			DispatchTriggerHandler.NoteFromToDispatch(Trigger.new);
			DispatchTriggerHandler.enableTriggers();
		}
	}
	// ---------------------------------------------------------------------------
}