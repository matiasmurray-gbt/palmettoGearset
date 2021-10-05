@isTest(seeAllData=true)
private class BatchToUpdateProjectMilestoneV2Test
{   
    static testMethod void unitTest3(){
        Job__c objJob = [SELECT Id, Opportunity__c FROM Job__c WHERE RecordType.DeveloperName = 'Financing' 
            AND Opportunity__c != null AND Flow_Status__c = 'M1 - Approved' LIMIT 1];
        delete [SELECT Id FROM Project_Milestone__c WHERE Opportunity__c = :objJob.Opportunity__c];
        
        Project_Milestone__c objMilestone = new Project_Milestone__c();
        objMilestone.Name = 'test';
        objMilestone.Opportunity__c = objJob.Opportunity__c;
        objMilestone.Contract_Signed_Milestone__c = Datetime.now();
        objMilestone.Survey_Complete_Confirmed__c = Datetime.now();
        objMilestone.Energy_Bill_checked__c = Datetime.now();
        objMilestone.Contract_Received_Milestone__c = Datetime.now();
        insert objMilestone;
        
        Database.executeBatch(new BatchToUpdateProjectMilestoneV2(objJob.Opportunity__c), 1);
    }
}