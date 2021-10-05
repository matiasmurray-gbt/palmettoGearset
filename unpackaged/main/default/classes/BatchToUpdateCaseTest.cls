@isTest
private class BatchToUpdateCaseTest
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
        
        Database.executeBatch(new BatchToUpdateCase());
    }
}