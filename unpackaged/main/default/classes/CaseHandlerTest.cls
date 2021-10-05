@isTest
private class CaseHandlerTest
{
    static testMethod void unitTest(){
        Id designSalesId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('3rd Party - Design Sales').getRecordTypeId();
        Account objAccount = TestDataFactory.createAccount('Test Acc', designSalesId);
        insert objAccount;
        
        Id oppDesignSalesId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('3rd Party - Design Sales').getRecordTypeId();
        Opportunity objOpportunity = TestDataFactory.createOpportunity(oppDesignSalesId, 'Test Opp', objAccount.Id, '1. Appointment Set', 'Alabama');
        objOpportunity.Financing_Tool__c = 'Sunlight';
        objOpportunity.Installation_Complete_Date__c = Date.today().addDays(5);
        insert objOpportunity;
        
        
        Id financingId = Schema.SObjectType.Job__c.getRecordTypeInfosByName().get('Financing').getRecordTypeId();
        Job__c objJob = new Job__c();
        objJob.Opportunity__c = objOpportunity.Id;
        objJob.RecordTypeId = financingId;
        insert objJob;
        
        Case objCase = new Case();
        objCase.Job__c = objJob.Id;
        insert objCase;
        
        Id retentionId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Retention').getRecordTypeId();
        objCase = new Case();
        objCase.RecordTypeId = retentionId;
        objCase.Opportunity__c = objOpportunity.Id;
        objCase.Job__c = objJob.Id;
        insert objCase;
        
        objCase.Status = 'Closed';
        update objCase;
    }
}