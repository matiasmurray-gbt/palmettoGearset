@isTest
public with sharing class BatchToUpdateInstallationCompleteTest {
    @IsTest
    static void methodName(){
        Id designSalesId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('3rd Party - Design Sales').getRecordTypeId();
        Account anAccount = TestDataFactory.createAccount('Palmetto Acc', designSalesId);
        insert anAccount;
        
        Id oppDesignSalesId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('3rd Party - Design Sales').getRecordTypeId();
        Opportunity anOpportunity = TestDataFactory.createOpportunity(oppDesignSalesId, 'Test Opp', anAccount.Id, '17. Install Ready', 'Alabama');
        insert anOpportunity;

        Id intallationJob = Schema.SObjectType.Job__c
        .getRecordTypeInfosByDeveloperName()
        .get('Installation_Scheduling')
        .getRecordTypeId();

        Job__c aJob = new Job__c(
            Name = 'Test Job Installation_Scheduling',
            Opportunity__c = anOpportunity.Id,
            RecordTypeId = intallationJob,
            Flow_Status__c = 'Installation Scheduled',
            Installation_Start_Date__c = DateTime.now().date().addDays(-2),
            Automation__c = true
        );
        insert aJob;

        aJob.Flow_Status__c = 'Installation Complete';
        update aJob;

        anOpportunity.Installation_Complete_Date__c = null;
        anOpportunity.StageName = '20. Inspection Scheduled';
        update anOpportunity;    

        Test.startTest();
        Database.executeBatch(new BatchToUpdateInstallationComplete());
        Test.stopTest();
        
        Opportunity updatedOpp = [SELECT Id, Installation_Complete_Date__c FROM Opportunity WHERE Id = :anOpportunity.Id];
        System.assertNotEquals(null, updatedOpp.Installation_Complete_Date__c, 'The opportunity installation complete date was not updated');
    }
}