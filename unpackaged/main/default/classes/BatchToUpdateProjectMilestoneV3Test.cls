@isTest
private class BatchToUpdateProjectMilestoneV3Test
{   
    static testMethod void unitTest(){
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
        
        System.debug('>>>>>'+[SELECT Id, RecordType.DeveloperName FROM Job__c]);
        delete [SELECT Id from Job__c WHERE RecordType.DeveloperName = 'Supply_Chain' and Opportunity__c = :objOpportunity.Id];
        
        Project_Milestone__c objMilestone = [SELECT Id, Contract_Signed_Milestone__c FROM Project_Milestone__c WHERE Opportunity__c = :objOpportunity.Id];
        System.debug('>>>>>'+objMilestone);
        objMilestone.Design_Completed_Milestone__c = Datetime.now();
        update objMilestone;
        
        Database.executeBatch(new BatchToUpdateProjectMilestoneV3(objOpportunity.Id), 1);
    }
}