({
    doInit : function(component, event, helper) {
        console.log('paso por aca');
        const action = component.get("c.getOpportunities");
        action.setParams({"recordId": component.get("v.recordId")});
        action.setCallback(this, function(response){
            const state = response.getState();
            if(state == "SUCCESS") {
                component.set("v.opportunity", response.getReturnValue());
                const docuSignList = [];
                const googleDocs = [];

                if(response.getReturnValue().dsfs__R00N80000002fD9vEAE__r != null) {
                    for(const docuSignObj of response.getReturnValue().dsfs__R00N80000002fD9vEAE__r) {
                        docuSignList.push({
                            link: docuSignObj.dsfs__DocuSign_Envelope_ID__c == null ?
                                `/lightning/r/dsfs__DocuSign_Status__c/${docuSignObj.Id}/view` : `https://app.docusign.com?back=documents/details/${docuSignObj.dsfs__DocuSign_Envelope_ID__c.toLowerCase()}`,
                            name: docuSignObj.Name
                        });
                    }
                }
                
                component.set("v.docuSignList", docuSignList);

                if(response.getReturnValue().GoogleDocs != null) {
                    for(const googleDoc of response.getReturnValue().GoogleDocs) {
                        googleDocs.push({
                            link: googleDoc.Url,
                            name: googleDoc.Name
                        });
                    }
                }

                component.set("v.googleDocsList", googleDocs);
            }
        });
        $A.enqueueAction(action);
    }
})