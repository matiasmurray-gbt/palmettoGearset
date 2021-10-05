@isTest(seeAllData=true)
private class BatchToCreateProjectMilestoneTest
{
    static testMethod void unitTest(){
        System.Test.startTest();
        Id designSalesId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('3rd Party - Design Sales').getRecordTypeId();
        Account objAccount = TestDataFactory.createAccount('Test Acc', designSalesId);
        insert objAccount;
        
        Id oppDesignSalesId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('3rd Party - Design Sales').getRecordTypeId();
        Opportunity objOpportunity = TestDataFactory.createOpportunity(oppDesignSalesId, 'Test Opp', objAccount.Id, '1. Appointment Set', 'Alabama');
        objOpportunity.Financing_Tool__c = 'Sunlight';
        objOpportunity.Installation_Complete_Date__c = Date.today().addDays(5);
        objOpportunity.Location__c = 'New Jersey';
        insert objOpportunity;
        
        delete [SELECT Id FROM Project_Milestone__c LIMIT 1000];
        
        Id contractProcessingId = Schema.SObjectType.Job__c.getRecordTypeInfosByDeveloperName().get('Business_Processing').getRecordTypeId();
        Job__c objJob = new Job__c();
        objJob.Opportunity__c = objOpportunity.Id;
        objJob.RecordTypeId = contractProcessingId;
        objJob.Type__c = 'Contract Processing- Document Verification';
        insert objJob;
        
        objJob.Flow_Status__c = 'Contract Processing Completed';
        update objJob;
        
        Id siteSurveyId = Schema.SObjectType.Job__c.getRecordTypeInfosByDeveloperName().get('SiteSurvey').getRecordTypeId();
        Job__c objSiteSurveyJob = new Job__c();
        objSiteSurveyJob.Opportunity__c = objOpportunity.Id;
        objSiteSurveyJob.RecordTypeId = siteSurveyId;
        insert objSiteSurveyJob;
        
        objSiteSurveyJob.Type__c = 'Virtual Survey';
        objSiteSurveyJob.Flow_Status__c = 'Survey Complete - Confirmed';
        update objSiteSurveyJob;
        
        
        Id documentVerId = Schema.SObjectType.Job__c.getRecordTypeInfosByDeveloperName().get('Document_Verification').getRecordTypeId();
        Job__c objDocVerJob = new Job__c();
        objDocVerJob.Opportunity__c = objOpportunity.Id;
        objDocVerJob.RecordTypeId = documentVerId;
        insert objDocVerJob;
        
        objDocVerJob.Usage_Verification_Complete__c = Date.today();
        update objDocVerJob;
        
        Id PermittingId = Schema.SObjectType.Job__c.getRecordTypeInfosByDeveloperName().get('Permitting').getRecordTypeId();    
        Job__c objPermittingJob = new Job__c();
        objPermittingJob.Name = 'test';
        objPermittingJob.Opportunity__c = objOpportunity.Id;
        objPermittingJob.RecordTypeId = PermittingId;
        try{
            insert objPermittingJob;
        }catch(Exception e){}
        
        Id siteApprovalId = Schema.SObjectType.Job__c.getRecordTypeInfosByDeveloperName().get('Design').getRecordTypeId();    
        Job__c objSiteApprovalJob = new Job__c();
        objSiteApprovalJob.Flow_Status__c = 'Site Approved';
        objSiteApprovalJob.RecordTypeId = siteApprovalId;
        objSiteApprovalJob.Opportunity__c = objOpportunity.Id;
        insert objSiteApprovalJob;
        
        objPermittingJob = new Job__c();
        try{
            objPermittingJob.RecordTypeId = PermittingId;
            objPermittingJob.Opportunity__c = objOpportunity.Id;
            objPermittingJob.Flow_Status__c = 'Permit Received';
            insert objPermittingJob;
        }catch(Exception e){}
        /*
        objPermittingJob.Flow_Status__c = 'Permit Submitted';
        insert objPermittingJob;
        
        objPermittingJob.Flow_Status__c = 'Permit Received';
        update objPermittingJob;
        */
        objOpportunity.StageName = '17. Install Ready';
        update objOpportunity;
        Database.executeBatch(new BatchToCreateProjectMilestone(), 1);
        System.Test.stopTest();

        Id installationSchedulingId = Schema.SObjectType.Job__c.getRecordTypeInfosByDeveloperName().get('Installation_Scheduling').getRecordTypeId(); 
        Job__c objInstallationJob = new Job__c();//[SELECT Id FROM Job__c WHERE RecordType.DeveloperName = 'Installation_Scheduling' LIMIT 1];
        objInstallationJob.RecordTypeId = installationSchedulingId;
        objInstallationJob.Opportunity__c = objOpportunity.Id;
        objInstallationJob.Flow_Status__c = 'Installation Scheduled';
        objInstallationJob.Installation_Start_Date__c = Date.today();
        insert objInstallationJob;
        
        objInstallationJob.Flow_Status__c = 'Installation Complete';
        update objInstallationJob;
        
        objOpportunity.StageName = '19. Install Completed';
        update objOpportunity;
        
        Database.executeBatch(new BatchToUpdateProjectMilestone(objOpportunity.Id), 1);
    }
    
    static testMethod void unitTest2(){
        Job__c objJob = [SELECT Id, Opportunity__c FROM Job__c WHERE RecordType.DeveloperName = 'PTO' AND Opportunity__c != null LIMIT 1];
        delete [SELECT Id FROM Project_Milestone__c WHERE Opportunity__c = :objJob.Opportunity__c];
        
        Project_Milestone__c objMilestone = new Project_Milestone__c();
        objMilestone.Name = 'test';
        objMilestone.Opportunity__c = objJob.Opportunity__c;
        insert objMilestone;
        
        Database.executeBatch(new BatchToUpdateProjectMilestone(objJob.Opportunity__c), 1);
    }
}