public with sharing class AccountTeamMemberHandler {
    public void onAfterInsert(List<AccountTeamMember> listAccTM){
        List<AccountTeamMember> accTmToCearteOppTM = new List<AccountTeamMember>();
        for(AccountTeamMember objAccTM : listAccTM){
            if(objAccTM.TeamMemberRole == 'Market Manager'){
                accTmToCearteOppTM.add(objAccTM);   
            }
        }
        if(!accTmToCearteOppTM.isEmpty()){
            createOppTeamMember(accTmToCearteOppTM);
        }
    }

    public void onAfterDelete(List<AccountTeamMember> listAccTM){
        List<AccountTeamMember> accTmToDeleteOppTM = new List<AccountTeamMember>();
        for(AccountTeamMember objAccTM : listAccTM){
            if(objAccTM.TeamMemberRole == 'Market Manager'){
                accTmToDeleteOppTM.add(objAccTM);   
            }
        }
        if(!accTmToDeleteOppTM.isEmpty()){
            deleteOppTeamMember(accTmToDeleteOppTM);
        }
    }

    public void onAfterUpdate(List<AccountTeamMember> listAccTM, Map<Id,AccountTeamMember> mapOldAccTM){
        List<AccountTeamMember> accTmToCearteOppTM = new List<AccountTeamMember>();
        List<AccountTeamMember> accTmToDeleteOppTM = new List<AccountTeamMember>();
        List<AccountTeamMember> accTmToUpdateStates = new List<AccountTeamMember>();
        for(AccountTeamMember objAccTM : listAccTM){
            if((objAccTM.TeamMemberRole == 'Market Manager' && mapOldAccTM.get(objAccTM.Id).TeamMemberRole != 'Market Manager')){
                accTmToCearteOppTM.add(objAccTM);
            }
            else if(objAccTM.TeamMemberRole != 'Market Manager' && mapOldAccTM.get(objAccTM.Id).TeamMemberRole == 'Market Manager'){
                accTmToDeleteOppTM.add(objAccTM);
            }
            if(objAccTM.State__c != null && objAccTM.State__c != mapOldAccTM.get(objAccTm.Id).State__c){
                accTmToUpdateStates.add(objAccTM);
            }
        }
        if(!accTmToCearteOppTM.isEmpty()){
            createOppTeamMember(accTmToCearteOppTM);
        }
        if(!accTmToDeleteOppTM.isEmpty()){
            deleteOppTeamMember(accTmToDeleteOppTM);
        }
        if(!accTmToUpdateStates.isEmpty()){
            updateOppTeamMemberByState(accTmToUpdateStates);
        }
    }

    private void createOppTeamMember(List<AccountTeamMember> listAccTM){
        Set<Id> accIds = new Set<Id>();
        Map<Id, AccountTeamMember> mapAccTMByAccId = new Map<Id, AccountTeamMember>();
        for(AccountTeamMember objAccTM : listAccTM){
            accIds.add(objAccTM.AccountId);
            mapAccTMByAccId.put(objAccTM.AccountId,objAccTM);
        }
        List<OpportunityTeamMember> listOppTM = new List<OpportunityTeamMember>();
        List<Opportunity> listOpps = [SELECT Id, Location__c, Vendor__r.Account__c FROM Opportunity WHERE Vendor__r.Account__c IN :accIds];
        for(Opportunity objOpp : listOpps){
            if(mapAccTMByAccId.containsKey(objOpp.Vendor__r.Account__c) && mapAccTMByAccId.get(objOpp.Vendor__r.Account__c).State__c != null && mapAccTMByAccId.get(objOpp.Vendor__r.Account__c).State__c.contains(objOpp.Location__c)){
                listOppTM.add(new OpportunityTeamMember(
                                    TeamMemberRole = 'Market Manager',
                                    UserId = mapAccTMByAccId.get(objOpp.Vendor__r.Account__c).UserId,
                                    OpportunityId = objOpp.Id
                                ));
            }
        }
        if(!listOppTM.isEmpty()){
            insert listOppTM;
        }
    }

    private void deleteOppTeamMember(List<AccountTeamMember> listAccTM){
        Set<Id> usrIds = new Set<Id>();
        Set<Id> accIds = new Set<Id>();
        Map<Id, AccountTeamMember> mapAccTMbyAccId = new Map<Id,AccountTeamMember>();
        Map<Id, AccountTeamMember> mapAccTMbyUserId = new Map<Id,AccountTeamMember>();
        for(AccountTeamMember objAccTM : listAccTM){
            usrIds.add(objAccTM.UserId);
            accIds.add(objAccTM.AccountId);
            mapAccTMbyAccId.put(objAccTM.AccountId, objAccTM);
            mapAccTMbyUserId.put(objAccTM.UserId, objAccTM);
        }
        List<Opportunity> listOpps = [
            SELECT Id, Vendor__r.Account__c,
            (
                SELECT Id, UserId
                FROM OpportunityTeamMembers
                WHERE TeamMemberRole = 'Market Manager'
                AND UserId IN :usrIds
            )
            FROM Opportunity
            WHERE Vendor__r.Account__c IN :accIds
        ];
        List<OpportunityTeamMember> listOppTMForDeletion = new List<OpportunityTeamMember>();
        for(Opportunity objOpp : listOpps){
            if(mapAccTMbyAccId.containsKey(objOpp.Vendor__r.Account__c) && !objOpp.OpportunityTeamMembers.isEmpty()){
                for(OpportunityTeamMember objOppTM : objOpp.OpportunityTeamMembers){
                    if(mapAccTMbyUserId.containsKey(objOppTM.UserId)){
                        listOppTMForDeletion.add(objOppTM);
                    }
                }
            }
        }
        if(!listOppTMForDeletion.isEmpty()){
            delete listOppTMForDeletion;
        }
    }

    private void updateOppTeamMemberByState(List<AccountTeamMember> listAccTM){
        Set<Id> usrIds = new Set<Id>();
        Set<Id> accIds = new Set<Id>();
        Map<Id, AccountTeamMember> mapAccTMbyAccId = new Map<Id,AccountTeamMember>();
        Map<Id, AccountTeamMember> mapAccTMbyUserId = new Map<Id,AccountTeamMember>();
        for(AccountTeamMember objAccTM : listAccTM){
            usrIds.add(objAccTM.UserId);
            accIds.add(objAccTM.AccountId);
            mapAccTMbyAccId.put(objAccTM.AccountId, objAccTM);
            mapAccTMbyUserId.put(objAccTM.UserId, objAccTM);
        }
        List<Opportunity> listOpps = [
            SELECT Id, Vendor__r.Account__c, Location__c,
            (
                SELECT Id, UserId
                FROM OpportunityTeamMembers
                WHERE TeamMemberRole = 'Market Manager'
                AND UserId IN :usrIds
            )
            FROM Opportunity
            WHERE Vendor__r.Account__c IN :accIds
        ];
        List<OpportunityTeamMember> listOppTMForDeletion = new List<OpportunityTeamMember>();
        List<OpportunityTeamMember> listOppTMForCreation = new List<OpportunityTeamMember>();
        for(Opportunity objOpp : listOpps){
            if(mapAccTMbyAccId.containsKey(objOpp.Vendor__r.Account__c) &&
                !mapAccTMbyAccId.get(objOpp.Vendor__r.Account__c).State__c.contains(objOpp.Location__c) &&
                !objOpp.OpportunityTeamMembers.isEmpty()){

                for(OpportunityTeamMember objOppTM : objOpp.OpportunityTeamMembers){
                    if(objOppTM.UserId == mapAccTMbyAccId.get(objOpp.Vendor__r.Account__c).UserId){
                        listOppTMForDeletion.add(objOppTM);
                    }
                }
            }else if((mapAccTMbyAccId.containsKey(objOpp.Vendor__r.Account__c) &&
            mapAccTMbyAccId.get(objOpp.Vendor__r.Account__c).State__c.contains(objOpp.Location__c))){
                Boolean createOppTm = true;
                if(!objOpp.OpportunityTeamMembers.isEmpty()){
                    for(OpportunityTeamMember objOppTM : objOpp.OpportunityTeamMembers){
                        if(objOppTM.UserId == mapAccTMbyAccId.get(objOpp.Vendor__r.Account__c).UserId){
                            createOppTm = false;
                        }
                    }
                }
                if(createOppTm){
                    listOppTMForCreation.add(new OpportunityTeamMember(
                                    TeamMemberRole = 'Market Manager',
                                    UserId = mapAccTMByAccId.get(objOpp.Vendor__r.Account__c).UserId,
                                    OpportunityId = objOpp.Id
                                ));
                }
            }
        }
        if(!listOppTMForDeletion.isEmpty()){
            delete listOppTMForDeletion;
        }
        if(!listOppTMForCreation.isEmpty()){
            insert listOppTMForCreation;
        }
    }
}