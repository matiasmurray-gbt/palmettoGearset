global with sharing class BatchToUpdateInstallationComplete implements Database.Batchable<SObject>{

    global Database.QueryLocator start(Database.BatchableContext context) {
        Set<String> oppStages = new Set<String>();
        oppStages.add('20. Inspection Scheduled');
        oppStages.add('21. Inspection Complete');
        oppStages.add('22. PTO');
        oppStages.add('Closed Won');
        oppStages.add('Cancelled');
        oppStages.add('Closed Lost');

        String query = 'SELECT Id, Installation_Complete_Date__c, ' +
        '(SELECT Id, Installation_Completed_Milestone__c '+
        'FROM Project_Milestones__r ' +
        'LIMIT 1) ' +
        'FROM Opportunity '  +
        'WHERE StageName IN :oppStages ' +
        'AND Installation_Complete_Date__c = null';

        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext context, List<Opportunity> scope) {

        List<Opportunity> oppsToUpdate = new List<Opportunity>();
        for(Opportunity opp : scope){
            if(!opp.Project_Milestones__r.isEmpty() && opp.Project_Milestones__r[0].Installation_Completed_Milestone__c != null){
                opp.Installation_Complete_Date__c = opp.Project_Milestones__r[0].Installation_Completed_Milestone__c.date();
                oppsToUpdate.add(opp);
            }
        }

        if(!oppsToUpdate.isEmpty()){
            update oppsToUpdate;
        }
    }

    global void finish(Database.BatchableContext context) {
        
    }
}