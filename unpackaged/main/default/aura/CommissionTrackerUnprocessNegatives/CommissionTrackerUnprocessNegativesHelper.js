({
    getTableData : function(component, helper) {
        let allData = component.get("v.tableData");
        let providersWithNegativeResult = [];
        for(let milestone of allData){
            for(let provider of milestone.data) {
                
                    if(provider.CommissionResult < 0){
                        providersWithNegativeResult.push(provider);
                    
                }
            }
        }

        component.set('v.providersWithNegativeResult',providersWithNegativeResult);
    },

    unprocessCommission : function(component, helper){
        let negativeComisions = component.get('v.providersWithNegativeResult')
        let selectedCommisions = [];
        for(let i = 0; i < negativeComisions.length; i++){
            if(document.getElementById('checkbox-up-0'+i).checked){
                selectedCommisions.push(negativeComisions[i]);
            }
        }
        if(selectedCommisions.length < 1){
            helper.fireToast("Error","There is no record selected.","error");
        }
        else{
            helper.callController(component,'unproccessNegatives',{providersList:selectedCommisions})
            .then(function(response){
                helper.fireToast("Success","The records have been unprocessed.","success");
                component.set("v.isOpen", false);
            }).catch(function(error){
                helper.fireToast("Error",error.getMessage(),"error");
                component.set("v.isOpen", false);
            });
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