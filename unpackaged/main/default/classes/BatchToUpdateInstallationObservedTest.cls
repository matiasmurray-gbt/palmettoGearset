@isTest
private class BatchToUpdateInstallationObservedTest
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
        
        Id contractProcessingId = Schema.SObjectType.Job__c.getRecordTypeInfosByDeveloperName().get('Business_Processing').getRecordTypeId();
        Job__c objJob = new Job__c();
        objJob.Opportunity__c = objOpportunity.Id;
        objJob.RecordTypeId = contractProcessingId;
        objJob.Type__c = 'Contract Processing- Document Verification';
        objJob.Automation__c = true;
        insert objJob;
        
        objJob.Flow_Status__c = 'Contract Processing Completed';
        update objJob;
        
        Id siteSurveyId = Schema.SObjectType.Job__c.getRecordTypeInfosByDeveloperName().get('SiteSurvey').getRecordTypeId();
        Job__c objSiteSurveyJob = new Job__c();
        objSiteSurveyJob.Opportunity__c = objOpportunity.Id;
        objSiteSurveyJob.RecordTypeId = siteSurveyId;
        objSiteSurveyJob.Automation__c = true;
        insert objSiteSurveyJob;
        
        objSiteSurveyJob.Type__c = 'Virtual Survey';
        objSiteSurveyJob.Flow_Status__c = 'Survey Complete - Confirmed';
        update objSiteSurveyJob;
        
        Id documentVerId = Schema.SObjectType.Job__c.getRecordTypeInfosByDeveloperName().get('Document_Verification').getRecordTypeId();
        Job__c objDocVerJob = new Job__c();
        objDocVerJob.Opportunity__c = objOpportunity.Id;
        objDocVerJob.RecordTypeId = documentVerId;
        objDocVerJob.Automation__c = true;
        insert objDocVerJob;
        
        objDocVerJob.Usage_Verification_Complete__c = Date.today();
        update objDocVerJob;
        
        
        Job__c objSiteApprovalJob = [SELECT Id FROM Job__c WHERE RecordType.DeveloperName = 'Design' LIMIT 1];
        objSiteApprovalJob.Flow_Status__c = 'Site Approved';
        update objSiteApprovalJob;
        
        Job__c objPermittingJob = [SELECT Id FROM Job__c WHERE RecordType.DeveloperName = 'Permitting' LIMIT 1];
        
        objPermittingJob.Flow_Status__c = 'Permit Submitted';
        update objPermittingJob;
        
        objPermittingJob.Flow_Status__c = 'Permit Received';
        update objPermittingJob;
        
        Job__c objInstallationSchedulingJob = [SELECT Id FROM Job__c WHERE RecordType.DeveloperName = 'Installation_Scheduling' LIMIT 1];
        objInstallationSchedulingJob.Installation_Start_Date__c = Date.today();
        update objInstallationSchedulingJob;
        
        new BatchToUpdateInstallationObserved().execute(null);
        System.Test.stopTest();
        
        objInstallationSchedulingJob.Installation_Start_Date__c = Date.today().addDays(6);
        objInstallationSchedulingJob.Installation_Reschedule_Reason__c = 'Customer requested';
        update objInstallationSchedulingJob;
        
        new BatchToUpdateInstallationObserved().execute(null);
    }
}