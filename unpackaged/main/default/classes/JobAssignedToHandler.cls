public class JobAssignedToHandler {
    public void onBeforeInsert(List<Job_Assigned_To__c> listJObAssignedTo){
        preventIncorrectScopeOfWorkSelection(listJObAssignedTo);
    }
    public void onBeforeUpdate(List<Job_Assigned_To__c> listJObAssignedTo, Map<Id,Job_Assigned_To__c> mapOldJobAssignedTo){
        preventIncorrectScopeOfWorkSelection(listJObAssignedTo);
    }
    public void onAfterInsert(List<Job_Assigned_To__c> listJObAssignedTo){
        
            sendUpdateCallOut(listJObAssignedTo);
        
    }
    public void onAfterUpdate(List<Job_Assigned_To__c> listJobAssignedTo, Map<Id,Job_Assigned_To__c> mapOldJobAssignedTo){
        List<Job_Assigned_To__c> listUpdatedScopeOdWork = new List<Job_Assigned_To__c>();
        for(Job_Assigned_To__c objJobAssignedTo  : listJobAssignedTo){
            if(objJobAssignedTo.Capability__c != mapOldJobAssignedTo.get(objJobAssignedTo.Id).Capability__c){
                listJobAssignedTo.add(objJobAssignedTo);
            }
        }
        if(!listJobAssignedTo.isEmpty()){
            preventIncorrectScopeOfWorkSelection(listJObAssignedTo);
        }
    }
    
    private void preventIncorrectScopeOfWorkSelection(List<Job_Assigned_To__c> listJObAssignedTo){
        Set<Id> vendorId = new Set<Id>();
        for(Job_Assigned_To__c objJobAssignedTo : listJObAssignedTo){
            vendorId.add(objJobAssignedTo.Vendor__c);
        }
        Map<Id,Vendor__c> mapAccountsById = new Map<Id,Vendor__c>([SELECT Id, Account__r.Scope_of_Work__c FROM Vendor__c WHERE Id IN :vendorId]);
        for(Job_Assigned_To__c objJobAssignedTo : listJObAssignedTo){
            if(!mapAccountsById.containsKey(objJobAssignedTo.Vendor__c) ||
                !(mapAccountsById.get(objJobAssignedTo.Vendor__c).Account__r.Scope_of_Work__c != null) ||
                !mapAccountsById.get(objJobAssignedTo.Vendor__c).Account__r.Scope_of_Work__c.contains(objJobAssignedTo.Capability__c)){

                objJobAssignedTo.addError(System.Label.Wrong_scope_of_work);
            }
        }
    }

    private void sendUpdateCallOut(List<Job_Assigned_To__c> listJObAssignedTo){
        Set<Id> jobAssignedToIds = new Set<Id>();
        for(Job_Assigned_To__c objJobAssignedTo : listJObAssignedTo){
            jobAssignedToIds.add(objJobAssignedTo.Id);
        }
            if(!jobAssignedToIds.isEmpty()){
                PalmettoAPIService.sendJobAssignmentData(jobAssignedToIds);
            }
        
    }
}