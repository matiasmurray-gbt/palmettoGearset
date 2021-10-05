public class ServiceAgreementHandler
{
    //This method is called on after insert event of trigger.
    public void onAfterInsert(List<Service_Agreement__c> lstServiceAgreement){
        createServiceProvider(lstServiceAgreement, null);
    }
    //This method is called on after update event of trigger.
    public void onAfterUpdate(List<Service_Agreement__c> lstServiceAgreement, Map<Id, Service_Agreement__c> mapIdToOldAgreement){
        createServiceProvider(lstServiceAgreement, mapIdToOldAgreement);
    }
    /*
    //This method is called to create operational input record.
    private void createOperationInput(List<Service_Agreement__c> lstServiceAgreement){
        List<Operations_Input__c> lstOperationsInput = new List<Operations_Input__c>();
        for(Service_Agreement__c objServiceAgreement : lstServiceAgreement){
            Operations_Input__c objOperationsInput = new Operations_Input__c();
            objOperationsInput.Service_Agreement__c = objServiceAgreement.Id;
            lstOperationsInput.add(objOperationsInput);
        }
        
        if(!lstOperationsInput.isEmpty())
            insert lstOperationsInput;
    }
    */
    //This method is used to create service provider record.
    private void createServiceProvider(List<Service_Agreement__c> lstServiceAgreement, Map<Id, Service_Agreement__c> mapIdToOldAgreement){
        /*
        List<dispconn__Service_Provider__c> lstServiceProvoider = new List<dispconn__Service_Provider__c>();
        for(Service_Agreement__c objServiceAgreement : lstServiceAgreement){
            if(objServiceAgreement.Active_MSA_Flag__c == true && (objServiceAgreement.Vendor_Onboarding_Status__c == 'Account Approved' || objServiceAgreement.Vendor_Onboarding_Status__c == 'Approved')){
                Boolean criteriaSatisfied = false;
                if(mapIdToOldAgreement == null){
                    criteriaSatisfied = true;
                } else{
                    Service_Agreement__c objOldAgreement = mapIdToOldAgreement.get(objServiceAgreement.Id);
                    if(objOldAgreement.Active_MSA_Flag__c == false){
                        criteriaSatisfied = true;
                    }
                }
                if(criteriaSatisfied){
                    dispconn__Service_Provider__c objServiceProvider = new dispconn__Service_Provider__c();
                    objServiceProvider.Name = objServiceAgreement.Vendor_Name__c + ' - ' + objServiceAgreement.State__c;
                    objServiceProvider.Service_Agreement__c = objServiceAgreement.Id;
                    objServiceProvider.Vendor__c = objServiceAgreement.Vendor__c;
                    objServiceProvider.dispconn__Email__c = objServiceAgreement.Vendor_Email__c;
                    objServiceProvider.dispconn__Phone__c = objServiceAgreement.Vendor_Phone__c;
                    lstServiceProvoider.add(objServiceProvider);
                }
            }            
        }
        try{
            if(!lstServiceProvoider.isEmpty())
                Database.insert(lstServiceProvoider, false);
        } catch(Exception e){}*/
    }
}