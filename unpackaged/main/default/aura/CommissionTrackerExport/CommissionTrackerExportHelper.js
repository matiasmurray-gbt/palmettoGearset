({
    createCSV : function(component, helper) {

        let provider;
        if(component.get("v.selectedProviders").length < 1 ){
            provider = component.get("v.availableProviders").map(function(prov){
                return "'" + prov.value + "'";
            }).join(",");
        }else{
            provider = component.get("v.selectedProviders").map(function(prov){
                return "'" + prov + "'";
            }).join(",")
        }

        let milestones;
        if(component.get("v.selectedMilestones").length < 1){
            milestones = "test";
            milestones = component.get("v.availableMilestones").map(function(mil){
                return mil.value;
            }).join(";");
        }else{
            milestones = component.get("v.selectedMilestones").join(";")
        }

        let fromDate = component.get("v.fromDate");
        let toDate = component.get("v.toDate");
        if(fromDate != null){
            let tempArr = fromDate.split("-");
            tempArr = [tempArr[1],tempArr[2],tempArr[0]];
            fromDate = tempArr.join("/");
        }
        if(toDate != null){
            let tempArr = toDate.split("-");
            tempArr = [tempArr[1],tempArr[2],tempArr[0]];
            toDate = tempArr.join("/");
        }

        let reportType;
        if(component.get("v.selectedMode") == "Paid Commission"){
            reportType = 3;
        }else if(component.get("v.selectedMode") == "Processed Commission"){
            reportType = 2;
        }else{
            reportType = 1;
        }

        let params = {
            fromDate : fromDate,
            toDate : toDate,
            selectedProvider : provider,
            milestone : milestones,
            reportType : reportType,
            paidMileStone : component.get("v.selectedPaidMilestones") != null ? component.get("v.selectedPaidMilestones") : false
        };



        helper.callController(component,'getReport',params)
        .then(function(response){
            let csvContent = "data:text/csv;charset=utf-8," + response;
            var encodedUri = encodeURI(csvContent);
            var link = document.createElement("a");
            link.setAttribute("href", encodedUri);
            link.setAttribute("download", "Commission Processing - palmetto Accounting.csv");
            document.body.appendChild(link);
            
            link.click(); // This will download the data file named "Commission Processing - palmetto Accounting".
        }).catch(function(errors){
            //helper.fireToast('Error',error,'error');
            console.log(errors);
        });
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

    callController: function(component, apexMethod, params){
		return new Promise($A.getCallback(function(resolve, reject){
			let action = component.get("c." + apexMethod + "");
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