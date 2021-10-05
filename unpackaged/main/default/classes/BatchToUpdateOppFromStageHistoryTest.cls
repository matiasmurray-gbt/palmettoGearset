@isTest
public with sharing class BatchToUpdateOppFromStageHistoryTest {
    @testSetup
    private static void testSetup() {
        Id designSalesId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('3rd Party - Design Sales').getRecordTypeId();
        Account anAccount = TestDataFactory.createAccount('Palmetto Acc', designSalesId);
        insert anAccount;
        
        Id oppDesignSalesId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('3rd Party - Design Sales').getRecordTypeId();
        Opportunity anOpportunity = TestDataFactory.createOpportunity(oppDesignSalesId, 'Test Opp', anAccount.Id, '1. Appointment Set', 'Alabama');
        insert anOpportunity;

        Id intallationJob = Schema.SObjectType.Job__c
        .getRecordTypeInfosByDeveloperName()
        .get('Installation_Scheduling')
        .getRecordTypeId();

        Job__c aJob = new Job__c();
        aJob.Name = 'Test Job Installation_Scheduling';
        aJob.Opportunity__c = anOpportunity.Id;
        aJob.RecordTypeId = intallationJob;
        aJob.Automation__c = true;

        insert aJob;
    }

    @IsTest
    static void testBatchToUpdateInstallationComplete(){
        Job__c aJob = [
            SELECT Id, Build_Partner__c, Opportunity__c, Installation_Complete_Date__c
            FROM Job__c
            WHERE Opportunity__r.Name = 'Palmetto Acc - Opportunity'
            AND RecordType.DeveloperName = 'Installation_Scheduling'
            LIMIT 1
        ];
        Opportunity opp = [SELECT Id FROM Opportunity WHERE Id = :aJob.Opportunity__c];

        opp.StageName = '17. Install Ready';
        update opp;

        aJob.Flow_Status__c = 'Installation Scheduled';
        aJob.Installation_Start_Date__c = DateTime.now().date().addDays(-2);
        update aJob;
        aJob.Flow_Status__c = 'Installation Complete';
        update aJob;
        opp.StageName = '19. Install Completed';
        update opp;        
        
        opp.StageName = '20. Inspection Scheduled';
        update opp;

        opp.Installation_Complete_Date__c = null;
        update opp;
        
        Test.startTest();
        Database.executeBatch(new BatchToUpdateOppFromStageHistory());
        Test.stopTest();

        Job__c updatedJob = [
            SELECT Id, Build_Partner__c, Opportunity__c, Installation_Complete_Date__c
            FROM Job__c
            WHERE Opportunity__r.Name = 'Palmetto Acc - Opportunity'
            AND RecordType.DeveloperName = 'Installation_Scheduling'
            LIMIT 1
        ];
        Opportunity updatedOpp = [
            SELECT Id, Installation_Complete_Date__c, 
            (
                SELECT Id, CreatedDate, newValue 
                FROM Histories
                WHERE Field = 'StageName'
            )
            FROM Opportunity WHERE Id = :updatedJob.Opportunity__c];
        
        Date stageDate;
        for(OpportunityFieldHistory ofh : updatedOpp.Histories){
            if(ofh.newValue == '19. Install Completed'){
                stageDate = ofh.CreatedDate.date();
            }
        }
        
        System.assertEquals(updatedOpp.Installation_Complete_Date__c, stageDate, 'The installation date was not corrected');
    }
}