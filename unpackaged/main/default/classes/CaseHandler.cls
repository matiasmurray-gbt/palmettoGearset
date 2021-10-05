public class CaseHandler
{
    //This method is called on before insert event of trigger.
    public void onBeforeInsert(List<Case> lstCase){
        populateOpp(lstCase);
        populateContactData(lstCase);
    }
    
    //This method is called on after insert event of trigger.
    public void onAfterInsert(List<case> lstCase){
        markOpenRetentionCase(lstCase, null);
    }
    
    //This method is called on after update event of trigger.
    public void onAfterUpdate(List<case> lstCase, Map<Id, Case> mapIdToOldCase){
        markOpenRetentionCase(lstCase, mapIdToOldCase);
    }
    
    //This method is called on before update event of trigger.
    public void onBeforeUpdate(List<Case> lstCase, Map<Id, Case> mapIdToOldCase){
        autoCloseCase(lstCase, mapIdToOldCase);
    }
    
    //This method is used to auto-close the supply chain case.
    private void autoCloseCase(List<Case> lstCase, Map<Id, Case> mapIdToOldCase){
        Id supplyChainId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Supply_Chain').getRecordTypeId();
        
        Set<String> setFlowStatus = new Set<String>();
        setFlowStatus.add('Confirmed');
        setFlowStatus.add('Redelivered');
        setFlowStatus.add('Confirmed Delivered to Site');
        
        for(Case objCase : lstCase){
            Case objOldCase = mapIdToOldCase.get(objCase.Id);
            if(objCase.Flow_Status__c != objOldCase.Flow_Status__c && setFlowStatus.contains(objCase.Flow_Status__c) 
                && objCase.RecordTypeId == supplyChainId)
            {
                objCase.Status = 'Closed';
            }
        }
    }
    
    //This method is used to populate opp on cases.
    private void populateOpp(List<Case> lstCase){
        Map<Id, List<Case>> mapJobIdToLstCase = new Map<Id, List<Case>>();
        for(Case objCase : lstCase){
            if(objCase.Job__c != null && objCase.Opportunity__c == null){
                if(mapJobIdToLstCase.containsKey(objCase.Job__c)){
                    mapJobIdToLstCase.get(objCase.Job__c).add(objCase);
                } else{
                    mapJobIdToLstCase.put(objCase.Job__c, new List<Case>{objCase});
                }
            }
        }
        System.debug('>>>>>'+mapJobIdToLstCase);
        if(!mapJobIdToLstCase.isEmpty()){
            for(Job__c objJob : [select Id, Opportunity__c from Job__c where Id in :mapJobIdToLstCase.keyset()]){
                for(Case objCase : mapJobIdToLstCase.get(objJob.Id)){
                    objCase.Opportunity__c = objJob.Opportunity__c;
                }    
            }
        }
    }
    
    //This method is used to populate Contact data.
    private void populateContactData(List<Case> lstCase){
        Map<Id, List<Case>> mapOppIdToLstCase = new Map<Id, List<Case>>();
        for(Case objCase : lstCase){
            if(objCase.Opportunity__c != null){
                if(mapOppIdToLstCase.containsKey(objCase.Opportunity__c)){
                    mapOppIdToLstCase.get(objCase.Opportunity__c).add(objCase);
                } else{
                    mapOppIdToLstCase.put(objCase.Opportunity__c, new List<Case>{objCase});
                }
            }
        }
        System.debug('>>>>>'+mapOppIdToLstCase);
        if(!mapOppIdToLstCase.isEmpty()){
            for(Opportunity objOpp : [select Id, AccountId, Contact__c from Opportunity where Id in :mapOppIdToLstCase.keyset()]){
                for(Case objCase : mapOppIdToLstCase.get(objOpp.Id)){
                    objCase.AccountId = objOpp.AccountId;
                    objCase.ContactId = objOpp.Contact__c;
                }    
            }
        }
    }
    
    private void markOpenRetentionCase(List<Case> lstCase, Map<Id, Case> mapIdToOldCase){
        Id retentionId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Retention').getRecordTypeId();
        Set<Id> setOpportunityId = new Set<Id>();
        for(Case objCase : lstCase){
            if(objCase.RecordTypeId == retentionId && objCase.Opportunity__c != null){
                if(mapIdToOldCase == null){
                    setOpportunityId.add(objCase.Opportunity__c);
                } else{
                    Case objOldCase = mapIdToOldCase.get(objCase.Id);
                    if(objCase.IsClosed != objOldCase.IsClosed){
                        setOpportunityId.add(objCase.Opportunity__c);
                    }
                }
            }
        }
    
        if(!setOpportunityId.isEmpty()){
            List<Opportunity> lstOppToUpdate = new List<Opportunity>();
            for(Opportunity objOpp : [SELECT Id, Open_Retention_Case__c, 
                    (SELECT Id FROM Cases__r 
                    WHERE RecordType.DeveloperName = 'Retention' 
                    AND IsClosed = false)
                    FROM Opportunity WHERE Id IN :setOpportunityId])
            {
                if(objOpp.Cases__r.size() > 0 && objOpp.Open_Retention_Case__c == false){
                    objOpp.Open_Retention_Case__c = true;
                    lstOppToUpdate.add(objOpp);
                } else if(objOpp.Cases__r.size() == 0 && objOpp.Open_Retention_Case__c == true){
                    objOpp.Open_Retention_Case__c = false;
                    lstOppToUpdate.add(objOpp);
                }
            }
    
            if(!lstOppToUpdate.isEmpty())
                update lstOppToUpdate;
        }
    }
}