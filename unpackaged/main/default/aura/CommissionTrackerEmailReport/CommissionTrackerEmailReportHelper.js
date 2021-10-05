({
    fetchData : function(component, event, helper) {
        let data = [];
        let providers = [];
        const allProviders = component.get("v.availableProviders");
        var allProvidersArray = allProviders.map(a => a.value);

        data = component.get("v.commissionsList");

        for(var milestone of data) {
            for(var provider of milestone.data) {
                providers.push(provider.ProviderName);
            }
        }

        var action = component.get("c.getEmailsAndContactsFromProvider");

        action.setParams({
            providers : allProvidersArray
        });

        action.setCallback(this, function(response) {
            var data = response.getReturnValue();
            var state = response.getState();

            if(state === 'SUCCESS') {
                let providers = [];
                var milestonesData = component.get("v.commissionsList");
                var providersWithCommissions = [];
                var providersWithoutCommissions = []

                for(var milestone of milestonesData) {
                    for(var provider of milestone.data) {
                        providers.push(provider.ProviderName);
                    }
                }

                for(var provider of data) {
                    if(providers.includes(provider.ProviderName)) {
                        providersWithCommissions.push(provider);
                    } else {
                        providersWithoutCommissions.push(provider);
                    }
                }

                component.set("v.data", providersWithCommissions);
                component.set("v.dataTwo", providersWithoutCommissions)
            } else {
                this.fireToast('Error', 'There was an error', 'error');
            }
        });

        $A.enqueueAction(action);
        component.set("v.isLoading", false);
    },

    sendEmailHelper : function(component, event, helper) {

        let selectedProviders = [];
        selectedProviders = component.find("providersData").getSelectedRows();

        let selectedProvidersWithoutCommissions = [];
        selectedProvidersWithoutCommissions = component.find("providersDataTwo").getSelectedRows();

        let milestonesData = [];
        milestonesData = component.get("v.commissionsList");

        //Creo este array para poder almacenar los proveedores con sus comisiones extraidas de los milestones
        let providerCommissions = [];

        //Extraigo los proveedores con sus comisiones de los milestones
        for(var provider of milestonesData) {
            for(var data of provider.data) {
                providerCommissions.push(data);
            }
        }

        //Recorro seleccionados
        for(var provider of selectedProviders) {
            //Comparo con la lista creada anteriormente
            for(var provider2 of providerCommissions) {
                if(provider.ProviderName == provider2.ProviderName) {
                    provider["CommissionResult"] = provider2.CommissionResult;
                    provider["PaidMilestone"] = true;
                }
            }
        }

        var action = component.get("c.sendEmailToProviders");

        action.setParams({
            selectedAllmilestone : component.get("v.selectedMilestones"),
            fromDate : component.get("v.fromDate"),
            toDate : component.get("v.toDate"),
            providersList : selectedProviders,
            providersWithoutCommissions : selectedProvidersWithoutCommissions

        });

        action.setCallback(this, function(response){
            var result = response.getReturnValue();
            var state = response.getState();

            if(state === 'SUCCESS') {
                if(result == 'OK') {
                    helper.fireToast("Success", 'Emails sent successfully!', 'success');
                } else {
                    helper.fireToast("Error", result, 'error');
                }

            } else {
                helper.fireToast("Error", response.getReturnValue(), "error");
            }
        });
        $A.enqueueAction(action);
    },

    fireToast : function(title, message, type){
        let toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": title,
            "message": message,
            "type": type
        });
        toastEvent.fire();
    }
    //metodo para para traer de apex los contactos relacionados a los comm providers
})