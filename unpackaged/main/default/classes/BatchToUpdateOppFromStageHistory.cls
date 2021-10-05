global with sharing class BatchToUpdateOppFromStageHistory implements Database.Batchable<SObject>{

    global Database.QueryLocator start(Database.BatchableContext context) {
        Set<String> oppStages = new Set<String>();
        oppStages.add('20. Inspection Scheduled');
        oppStages.add('21. Inspection Complete');
        oppStages.add('22. PTO');
        oppStages.add('Closed Won');
        oppStages.add('Cancelled');
        oppStages.add('Closed Lost');

        Id intallationJob = Schema.SObjectType.Job__c
        .getRecordTypeInfosByDeveloperName()
        .get('Installation_Scheduling')
        .getRecordTypeId();

        String query = 'SELECT Id,Installation_Complete_Date__c, ' +
        '(SELECT Id, CreatedDate, newValue ' +
        'FROM Histories ' +
        'WHERE Field = \'StageName\') ' +
        'FROM Opportunity ' +
        'WHERE StageName IN :oppStages ' +
        'AND Installation_Complete_Date__c = null';

        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext context, List<Opportunity> scope) {
        List<Opportunity> oppsToUpdate = new List<Opportunity>();
        for(Opportunity opp : scope){
            if(!opp.Histories.isEmpty()){
                for(OpportunityFieldHistory ofh : opp.Histories){
                    if(ofh.newValue == '19. Install Completed'){
                        opp.Installation_Complete_Date__c = ofh.CreatedDate.date();
                        oppsToUpdate.add(opp);
                    }
                }
            }
        }

        if(!oppsToUpdate.isEmpty()){
            update oppsToUpdate;
        }
    }

    global void finish(Database.BatchableContext context) {
        
    }
}