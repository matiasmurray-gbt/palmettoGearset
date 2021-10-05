@isTest
public class CaseAssignedToHandlerTest {
    @isTest
    private static void testPreventCreationWrongScopeOfWork() {
        // Test data setup
        TriggerConfiguration__c caseApiCall = new TriggerConfiguration__c();
        caseApiCall.Name = 'Case Assignment API Trigger';
        caseApiCall.Active__c = true;
        insert caseApiCall;

        Id designSalesId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('3rd Party - Design Sales').getRecordTypeId();
        Account objAccount = TestDataFactory.createAccount('Test Acc', designSalesId);
        insert objAccount;

        Id buildPartnerId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Build Partner').getRecordTypeId();
        Account bpAccount = TestDataFactory.createAccount('Test Acc', buildPartnerId);
        bpAccount.Scope_of_Work__c = 'Design;Inspection';
        insert bpAccount;

        Vendor__c buildPartner = new Vendor__c(Name = 'Test BP', Account__c = bpAccount.Id);
        insert buildPartner;
        
        Id oppDesignSalesId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('3rd Party - Design Sales').getRecordTypeId();
        Opportunity objOpportunity = TestDataFactory.createOpportunity(oppDesignSalesId, 'Test Opp', objAccount.Id, '1. Appointment Set', 'Alabama');
        objOpportunity.Financing_Tool__c = 'SunRun';
        objOpportunity.Installation_Complete_Date__c = Date.today().addDays(5);
        objOpportunity.Location__c = 'Pennsylvania';
        insert objOpportunity;

        Id desingChangeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Design_Change').getRecordTypeId();
        Case objCase = new Case();
        objCase.Opportunity__c = objOpportunity.Id;
        objCase.RecordTypeId = desingChangeId;
        insert objCase;

        // Actual test
        Test.startTest();
        try{
            Case_Assigned_To__c objCaseAssignment = new Case_Assigned_To__c(
            Vendor__c = buildPartner.Id,
            Case__c = objCase.Id,
            Capability__c = 'Permitting'
            );
            insert objCaseAssignment;
            System.assert(false, 'An exception should have been thrown by the trigger but was not.');
        }catch(Exception e){
            Test.stopTest();
            // Asserts
            System.assert(e.getMessage().contains(System.Label.Wrong_scope_of_work), 'The exception thrown was not the expected one');
        }
    } 

    @isTest
    private static void testPreventUpdateWrongScopeOfWork() {
        // Test data setup
        TriggerConfiguration__c caseApiCall = new TriggerConfiguration__c();
        caseApiCall.Name = 'Case Assignment API Trigger';
        caseApiCall.Active__c = true;
        insert caseApiCall;
        
        Id designSalesId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('3rd Party - Design Sales').getRecordTypeId();
        Account objAccount = TestDataFactory.createAccount('Test Acc', designSalesId);
        insert objAccount;

        Id buildPartnerId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Build Partner').getRecordTypeId();
        Account bpAccount = TestDataFactory.createAccount('Test Acc', buildPartnerId);
        bpAccount.Scope_of_Work__c = 'Design;Inspection';
        insert bpAccount;

        Vendor__c buildPartner = new Vendor__c(Name = 'Test BP', Account__c = bpAccount.Id);
        insert buildPartner;
        
        Id oppDesignSalesId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('3rd Party - Design Sales').getRecordTypeId();
        Opportunity objOpportunity = TestDataFactory.createOpportunity(oppDesignSalesId, 'Test Opp', objAccount.Id, '1. Appointment Set', 'Alabama');
        objOpportunity.Financing_Tool__c = 'SunRun';
        objOpportunity.Installation_Complete_Date__c = Date.today().addDays(5);
        objOpportunity.Location__c = 'Pennsylvania';
        insert objOpportunity;

        Id desingChangeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Design_Change').getRecordTypeId();
        Case objCase = new Case();
        objCase.Opportunity__c = objOpportunity.Id;
        objCase.RecordTypeId = desingChangeId;
        insert objCase;
 
        Case_Assigned_To__c objCaseAssignment = new Case_Assigned_To__c(
            Vendor__c = buildPartner.Id,
            Case__c = objCase.Id,
            Capability__c = 'Design'
            );
        insert objCaseAssignment;

        // Actual test
        Test.startTest();
        try{
            objCaseAssignment.Capability__c = 'Permitting';
            update objCaseAssignment;
            System.assert(false, 'An exception should have been thrown by the trigger but was not.');
        }catch(Exception e){
            Test.stopTest();
            // Asserts
            System.assert(e.getMessage().contains(System.Label.Wrong_scope_of_work), 'The exception thrown was not the expected one');
        }
    }
}