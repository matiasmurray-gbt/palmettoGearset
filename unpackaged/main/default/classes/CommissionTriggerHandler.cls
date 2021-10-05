public class CommissionTriggerHandler
{
    //This method is called on after update event of trigger.
    public void onAfterUpdate(List<Commission__c> lstCommission, Map<Id, Commission__c> mapIdToOldCommission){
        TriggerConfiguration__c objTriggerConfigurationCS = TriggerConfiguration__c.getInstance('LGCY API trigger');
        if(objTriggerConfigurationCS != null && objTriggerConfigurationCS.Active__c == true){
            sendCommissionData(lstCommission);
        }
    }
    
    //This method is used to send the commission data to LGCY end-point.
    private void sendCommissionData(List<Commission__c> lstCommission){
        Set<Id> setCommissionId = new Set<Id>();
        for(Commission__c objCommission : lstCommission){
            if(objCommission.X3rd_Party_Partner__c == 'LGCY Power'){
                setCommissionId.add(objCommission.Id);
            }
        }
        
        if(!setCommissionId.isEmpty()){
            Set<Id> setCommissionId2 = new Set<Id>();//and Opportunity__r.Opp_Primary_Contact__r.AccountId = '0012L000012GUMjQAO'
            for(Commission__c objCommission : [select Id from Commission__c 
                where Id in :setCommissionId ])
            {
                setCommissionId2.add(objCommission.Id);
            }
            
            if(!setCommissionId2.isEmpty()){
                PalmettoAPIService.sendCommissionData(setCommissionId2);
            }
        }
    }
}