({
    
	doInit: function (component, event, helper) {

        /*var milestones = [];
        
		if(component.get("v.filter") != 'All') {
			milestones = component.get("v.tData");
		} else {
			milestones = component.get("v.milestonesWrapper")
		}
		console.log('Received object data => ', milestones);
        var commissionResultTotal = 0;
        var milestone1AmountTotal = 0;
        var milestone2AmountTotal = 0;
        var milestone3AmountTotal = 0;
        var clawbacksTotal = 0;

        let orderedList = [];

        for(var milestone of milestones) {
            for(var provider of milestone.data) {
                commissionResultTotal += provider.CommissionResult;
                console.log('commissionResultTotal ', provider.ProviderName + ' '+ provider.CommissionResult);
                milestone1AmountTotal += provider.Milestone1TotalAmount;
                milestone2AmountTotal += provider.Milestone2TotalAmount;
                milestone3AmountTotal += provider.Milestone3TotalAmount;
                clawbacksTotal += provider.ClawbackTotalAmount;

                orderedList.push(provider);
            }
            
        }

        orderedList.sort(function(a, b) {
            if(a.ProviderName > b.ProviderName) {
                return 1;
            }
            if(a.ProviderName < b.ProviderName) {
                return -1;
            }
            return 0;
        });

        component.set("v.commissionResultTotal", commissionResultTotal.toFixed(2));
        component.set("v.milestone1AmountTotal", milestone1AmountTotal.toFixed(2));
        component.set("v.milestone2AmountTotal", milestone2AmountTotal.toFixed(2));
        component.set("v.milestone3AmountTotal", milestone3AmountTotal.toFixed(2));
        component.set("v.clawbacksTotal", clawbacksTotal);
        component.set("v.providers", orderedList);
        component.set("v.data", orderedList);*/
    },

	doThis: function(component, event, helper) {
		
		component.set("v.isOpen", true);
		var milestones = [];
        
		if(component.get("v.filter") != 'All') {
			milestones = component.get("v.tData");
		} else {
			milestones = JSON.parse(JSON.stringify(component.get("v.milestonesWrapper")));
		}
		console.log('Received object data => ', milestones);
        var commissionResultTotal = 0;
        var milestone1AmountTotal = 0;
        var milestone2AmountTotal = 0;
        var milestone3AmountTotal = 0;
        var clawbacksTotal = 0;

        let orderedList = [];

		const ProviderMap = new Map();

		for(var milestone of milestones) {
            for(var provider of milestone.data) {
				if(ProviderMap.has(provider.ProviderName)) {
					let providerTemp = ProviderMap.get(provider.ProviderName);
					providerTemp.CommissionResult = Number((providerTemp.CommissionResult += provider.CommissionResult).toFixed(2));
					providerTemp.Milestone1TotalAmount = Number((providerTemp.Milestone1TotalAmount += provider.Milestone1TotalAmount).toFixed(2));
					providerTemp.Milestone2TotalAmount = Number((providerTemp.Milestone2TotalAmount += provider.Milestone2TotalAmount).toFixed(2));
					providerTemp.Milestone3TotalAmount = Number((providerTemp.Milestone3TotalAmount += provider.Milestone3TotalAmount).toFixed(2));
					providerTemp.ClawbackTotalAmount = Number((providerTemp.ClawbackTotalAmount += provider.ClawbackTotalAmount).toFixed(2));
				} else {
					ProviderMap.set(provider.ProviderName, provider);
				}
                commissionResultTotal += provider.CommissionResult;
                milestone1AmountTotal += provider.Milestone1TotalAmount;
                milestone2AmountTotal += provider.Milestone2TotalAmount;
                milestone3AmountTotal += provider.Milestone3TotalAmount;
                clawbacksTotal += provider.ClawbackTotalAmount;
            }
            
        }

		for(provider of ProviderMap.values()) {
			orderedList.push(provider);
		}

        /*for(var milestone of milestones) {
            for(var provider of milestone.data) {
				console.log('provider ', provider.ProviderName);
                commissionResultTotal += provider.CommissionResult;
                console.log('commissionResultTotal ', provider.ProviderName + ' '+ provider.CommissionResult);
                milestone1AmountTotal += provider.Milestone1TotalAmount;
                milestone2AmountTotal += provider.Milestone2TotalAmount;
                milestone3AmountTotal += provider.Milestone3TotalAmount;
                clawbacksTotal += provider.ClawbackTotalAmount;

                orderedList.push(provider);
            }
            
        }*/

        orderedList.sort(function(a, b) {
            if(a.ProviderName > b.ProviderName) {
                return 1;
            }
            if(a.ProviderName < b.ProviderName) {
                return -1;
            }
            return 0;
        });

        component.set("v.commissionResultTotal", commissionResultTotal.toFixed(2));
        component.set("v.milestone1AmountTotal", milestone1AmountTotal.toFixed(2));
        component.set("v.milestone2AmountTotal", milestone2AmountTotal.toFixed(2));
        component.set("v.milestone3AmountTotal", milestone3AmountTotal.toFixed(2));
        component.set("v.clawbacksTotal", clawbacksTotal.toFixed(2));
        component.set("v.providers", orderedList);
        component.set("v.data", orderedList);
	},
	closePopUp : function(component, event, helper){
        component.set("v.isOpen", false);
    },
})