({
    handleCancel : function(component, event, helper) {
        //closes the modal or popover from the component
        var appEvent = $A.get("e.c:CommissionTrackerConfirmOperationEvent");
        appEvent.setParams({
            "message" : "Cancel" });
        appEvent.fire();
        component.find("overlayLib").notifyClose();
    },
    handleOK : function(component, event, helper) {
        //do something
        var operation = component.get("v.operation");
		var allValidationsPass = true;

		if(operation == 'add paid date') {
			
			allValidationsPass = false;
			var paidDate = component.find("datePicker");
			var paidDateValue = paidDate.get("v.value");

			if(paidDateValue == null) {
				paidDate.setCustomValidity("Please select a date first");
				
			} else {
				paidDate.setCustomValidity("");
				allValidationsPass = true;
			}
			paidDate.reportValidity();
		}
		
        var appEvent = $A.get("e.c:CommissionTrackerConfirmOperationEvent");

        appEvent.setParams({
            "message" : "Ok",
            "operation" : component.get("v.operation"),
            "selectedDate" : component.get("v.selectedDate")
        });

		if(allValidationsPass) {
			appEvent.fire();
			component.find("overlayLib").notifyClose();
		}
    }
})