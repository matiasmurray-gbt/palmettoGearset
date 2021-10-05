global class BatchToCreateProjectMilestone implements Database.Batchable<SObject>
{   
    /*****************Batchable Interface Methods*****************/
    global Database.QueryLocator start(Database.BatchableContext context) {
        String query = System.Label.Project_Milestone_Query;
        if(Test.isRunningTest()){
            query += ' LIMIT 1';
        }
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext context, List<Opportunity> lstOpportunity) {
        List<Project_Milestone__c> lstProjectMilestone = new List<Project_Milestone__c>();
        for(Opportunity objOpp : lstOpportunity){
            Project_Milestone__c objProjectMilestone = new Project_Milestone__c();
            objProjectMilestone.Name = objOpp.Name;
            objProjectMilestone.Opportunity__c = objOpp.Id;
            lstProjectMilestone.add(objProjectMilestone);
        }
        
        if(!lstProjectMilestone.isEmpty())
            insert lstProjectMilestone;
    }
    
    global void finish(Database.BatchableContext context) {
        
    }
}