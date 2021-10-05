@isTest(seeAllData=true)
private class BatchToUpdateProjectMilestoneV4Test
{   
    static testMethod void unitTest(){
        Job__c objJob = [SELECT Id, Opportunity__c FROM Job__c 
                WHERE RecordType.DeveloperName = 'Interconnection' AND Opportunity__c != null LIMIT 1];
                
        delete [SELECT Id FROM Project_Milestone__c WHERE Opportunity__c = :objJob.Opportunity__c];
        
        Project_Milestone__c objMilestone = new Project_Milestone__c();
        objMilestone.Name = 'test';
        objMilestone.Opportunity__c = objJob.Opportunity__c;
        insert objMilestone;
        
        Database.executeBatch(new BatchToUpdateProjectMilestoneV4(objJob.Opportunity__c), 1);
    }
}