@isTest
public class PermitJobOpportunityControllerTest {
    //Note: name of tests: whatDoesTheTest_WhatExpectToReceive
    @IsTest
    static void insertBuildOnlyOpportunity_GetPermittingJob(){
        Id buildOnlyId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Build Only').getRecordTypeId();
        Account anAccount = TestDataFactory.createAccount('Test Acc', buildOnlyId);
        INSERT anAccount;
        
        Id buildOnlyOppId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Build Only').getRecordTypeId();
        Opportunity anOpportunity = TestDataFactory.createOpportunity(buildOnlyOppId, 'Test Opp', anAccount.Id, '13. Engineering Design Complete', 'Alabama');
        anOpportunity.CloseDate = Date.today().addDays(5);
        INSERT anOpportunity;
        
        anOpportunity.StageName = '14. Permit Sent';
        UPDATE anOpportunity;
        
        Test.startTest();
        anOpportunity.StageName = '13. Engineering Design Complete';
        UPDATE anOpportunity;

        Job__c permittingJob = [SELECT ID FROM Job__c WHERE Opportunity__c = :anOpportunity.Id LIMIT 1];

        Opportunity verifyOpp = PermitJobOpportunityController.getOpportunities(permittingJob.Id);

        Test.stopTest();

        System.assertEquals(anOpportunity.Id, verifyOpp.Id);
    }
}