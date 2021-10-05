public with sharing class CaseAssignedToHandler {
    public void onBeforeInsert(List<Case_Assigned_To__c> listCaseAssignedTo){
        preventIncorrectScopeOfWorkSelection(listCaseAssignedTo);
    }
    public void onBeforeUpdate(List<Case_Assigned_To__c> listCaseAssignedTo, Map<Id,Case_Assigned_To__c> mapOldCaseAssignedTo){
        preventIncorrectScopeOfWorkSelection(listCaseAssignedTo);
    }
    public void onAfterInsert(List<Case_Assigned_To__c> listCaseAssignedTo){
        sendUpdateCallOut(listCaseAssignedTo);
    }
    public void onAfterUpdate(List<Case_Assigned_To__c> listCaseAssignedTo, Map<Id,Case_Assigned_To__c> mapOldCaseAssignedTo){
        List<Case_Assigned_To__c> listUpdatedScopeOdWork = new List<Case_Assigned_To__c>();
        for(Case_Assigned_To__c objCaseAssignedTo  : listCaseAssignedTo){
            if(objCaseAssignedTo.Capability__c != mapOldCaseAssignedTo.get(objCaseAssignedTo.Id).Capability__c){
                listCaseAssignedTo.add(objCaseAssignedTo);
            }
        }
        if(!listCaseAssignedTo.isEmpty()){
            preventIncorrectScopeOfWorkSelection(listCaseAssignedTo);
        }
    }
    
    private void preventIncorrectScopeOfWorkSelection(List<Case_Assigned_To__c> listCaseAssignedTo){
        Set<Id> vendorIds = new Set<Id>();
        for(Case_Assigned_To__c objCaseAssignedTo : listCaseAssignedTo){
            if(objCaseAssignedTo.Capability__c != null && objCaseAssignedTo.Capability__c != ''){
                vendorIds.add(objCaseAssignedTo.Vendor__c);
            }
        }
        Map<Id,Vendor__c> mapAccountsById = new Map<Id,Vendor__c>([SELECT Id, Account__r.Scope_of_work__c FROM Vendor__c WHERE Id IN :vendorIds]);
        for(Case_Assigned_To__c objCaseAssignedTo : listCaseAssignedTo){
            if(mapAccountsById.containsKey(objCaseAssignedTo.Vendor__c) &&
                (!(mapAccountsById.get(objCaseAssignedTo.Vendor__c).Account__r.Scope_of_work__c != null) ||
                !mapAccountsById.get(objCaseAssignedTo.Vendor__c).Account__r.Scope_of_work__c.contains(objCaseAssignedTo.Capability__C))){

                objCaseAssignedTo.addError(System.Label.Wrong_scope_of_work);
            }
        }
    }

    private void sendUpdateCallOut(List<Case_Assigned_To__c> caseJObAssignedTo){
        Set<Id> caseAssignedToIds = new Set<Id>();
        for(Case_Assigned_To__c objCaseAssignedTo : caseJObAssignedTo){
            caseAssignedToIds.add(objCaseAssignedTo.Id);
        }
        if(!caseAssignedToIds.isEmpty() && !System.isBatch()){
            PalmettoAPIService.sendCaseAssignmentData(caseAssignedToIds);
        }
    }
}