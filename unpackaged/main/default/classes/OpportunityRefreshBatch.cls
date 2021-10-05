global class OpportunityRefreshBatch implements Database.Batchable<SObject>, Schedulable {
    global void execute(SchedulableContext sc){
        TriggerConfiguration__c objTriggerConfigurationRCCS = TriggerConfiguration__c.getInstance('Refresh Commissions');
        if(objTriggerConfigurationRCCS != null && objTriggerConfigurationRCCS.Active__c == true){
            Database.executeBatch(new OpportunityRefreshBatch(), 1);
        }
    }
    
    /*****************Batchable Interface Methods*****************/
    global Database.QueryLocator start(Database.BatchableContext context) {
        String query = 'select Id, Amount from Opportunity '; 
        query += 'where Id in (select Opportunity__c from Commission__c) AND LastModifiedDate = TODAY';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext context, List<Opportunity> lstOpportunity) {
        TriggerConfiguration__c objTriggerConfigurationCS = TriggerConfiguration__c.getInstance('HomeCustomerUpdate');
        if(objTriggerConfigurationCS != null){
            objTriggerConfigurationCS.Active__c = false;
            update objTriggerConfigurationCS;
        }
        
        TriggerConfiguration__c objAlTriggerConfigurationCS = TriggerConfiguration__c.getInstance('LGCY API trigger');
        if(objAlTriggerConfigurationCS != null){
            objAlTriggerConfigurationCS.Active__c = false;
            update objAlTriggerConfigurationCS;
        }
    
        Set<Id> setOppId = new Set<Id>();
        for(Opportunity objOpp : lstOpportunity){
            setOppId.add(objOpp.Id);
            objOpp.Last_Refreshed_Commissions__c = Datetime.now();
        }
        
        if(!lstOpportunity.isEmpty())
            update lstOpportunity;
            
        OpportunityService.refreshCommission(setOppId);
    }
    
    global void finish(Database.BatchableContext context) {
        TriggerConfiguration__c objTriggerConfigurationCS = TriggerConfiguration__c.getInstance('HomeCustomerUpdate');
        if(objTriggerConfigurationCS != null){
            objTriggerConfigurationCS.Active__c = true;
            update objTriggerConfigurationCS;
        }
        
        TriggerConfiguration__c objAlTriggerConfigurationCS = TriggerConfiguration__c.getInstance('LGCY API trigger');
        if(objAlTriggerConfigurationCS != null){
            objAlTriggerConfigurationCS.Active__c = true;
            update objAlTriggerConfigurationCS;
        }
    }
}