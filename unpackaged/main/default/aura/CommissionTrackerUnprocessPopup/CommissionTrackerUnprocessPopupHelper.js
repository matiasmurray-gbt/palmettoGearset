({
    getTableData : function(component, helper) {
        component.set('v.negativeCommisions',component.get("v.tableSelectedRows"));
    },

    unprocessCommission : function(component, helper){

        let negativeComisions = component.get('v.negativeCommisions')
        let selectedCommisions = [];
        var alreadyPaidCommissions = [];

        for(let i = 0; i < negativeComisions.length; i++){
            if(document.getElementById('checkbox-up-0'+i).checked){

                selectedCommisions.push(negativeComisions[i].Id);

            }
        }

        if(selectedCommisions.length < 1){
            helper.fireToast("Error","There is no record selected.","error");
        } else {
            var action = component.get("c.unprocessCommissions");
            action.setParams({
                commissionsList:selectedCommisions
            });

            action.setCallback(this, function(response){
                var state = response.getState();
                var result = response.getReturnValue();
                if(state === 'SUCCESS') {
                    if(result.message == 'OK' && $A.util.isEmpty(result.Commissions)) {
                        helper.fireToast("Success","The records have been unprocessed.","success");
                    } else if (result.message == 'OK' && !$A.util.isEmpty(result.Commissions)){
                        var modalBody;
                        $A.createComponent("c:CommissionTrackerWarningModal", {
                            commissions : result.Commissions,
                            details: 'The operation was successful, but the following commissions couldn\'t be updated because they are already paid:'
                        },
                            function(content, status) {
                                if(status === "SUCCESS") {
                                    modalBody = content;
                                    component.find('overlayLib').showCustomModal({
                                        header: "The operation was successful, but...",
                                        body: modalBody,
                                        showCloseButton: true,
                                        cssClass: "mymodal",
                                        closeCallback: function() {
                                            //close
                                        }
                                    })
                                }
                            });
                    } else {
                        this.fireToast("Error",result.message,"error", 10000);
                    }
                } else if (state === 'ERROR') {
                    this.fireToast("Error",error.getMessage(),"error");
                }
            });
            $A.enqueueAction(action);
        }
    },

    fireToast : function(title, message, type){
        let toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": title,
            "message": message,
            "type": type
        });
        toastEvent.fire();
    },

    callController: function(cmp, apexMethod, params){
		return new Promise($A.getCallback(function(resolve, reject){
			let action = cmp.get("c." + apexMethod + "");
			if(params != null){
				action.setParams(params);
			}
			action.setCallback(this, function(response){
				if(response.getState() == "SUCCESS"){
					resolve(response.getReturnValue());
				}
				if(response.getState() == "ERROR"){
					reject(response.getError());
				}
			});
			$A.enqueueAction(action);
		}));
	}
})