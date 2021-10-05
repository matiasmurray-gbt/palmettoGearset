@isTest
public class JobAssignedToHandlerTest {
    @isTest
    private static void testPreventCreationWrongScopeOfWork() {
        // Test data setup
        TriggerConfiguration__c jobApiCall = new TriggerConfiguration__c();
        jobApiCall.Name = 'Job Assignment API Trigger';
        jobApiCall.Active__c = true;
        insert jobApiCall;
        
        Id designSalesId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('3rd Party - Design Sales').getRecordTypeId();
        Account objAccount = TestDataFactory.createAccount('Test Acc', designSalesId);
        insert objAccount;

        Id buildPartnerId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Build Partner').getRecordTypeId();
        Account bpAccount = TestDataFactory.createAccount('Test Acc', buildPartnerId);
        bpAccount.Scope_of_work__c = 'Installation;Inspection';
        insert bpAccount;

        Vendor__c buildPartner = new Vendor__c(Name = 'Test BP', Account__c = bpAccount.Id);
        insert buildPartner;
        
        Id oppDesignSalesId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('3rd Party - Design Sales').getRecordTypeId();
        Opportunity objOpportunity = TestDataFactory.createOpportunity(oppDesignSalesId, 'Test Opp', objAccount.Id, '1. Appointment Set', 'Alabama');
        objOpportunity.Financing_Tool__c = 'SunRun';
        objOpportunity.Installation_Complete_Date__c = Date.today().addDays(5);
        objOpportunity.Location__c = 'Pennsylvania';
        insert objOpportunity;
        
        Id contractProcessingId = Schema.SObjectType.Job__c.getRecordTypeInfosByDeveloperName().get('Job_Close_Out').getRecordTypeId();
        Job__c objJob = new Job__c();
        objJob.Opportunity__c = objOpportunity.Id;
        objJob.RecordTypeId = contractProcessingId;
        objJob.Type__c = 'Job Close Out';
        objJob.Automation__c = true;
        insert objJob;

        // Actual test
        Test.startTest();
        try{
            Job_Assigned_To__c objJobAssignment = new Job_Assigned_To__c(
            Vendor__c = buildPartner.Id,
            Job__c = objJob.Id,
            Capability__c = 'Permitting'
            );
            insert objJobAssignment;
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
        TriggerConfiguration__c jobApiCall = new TriggerConfiguration__c();
        jobApiCall.Name = 'Job Assignment API Trigger';
        jobApiCall.Active__c = true;
        insert jobApiCall;

        Id designSalesId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('3rd Party - Design Sales').getRecordTypeId();
        Account objAccount = TestDataFactory.createAccount('Test Acc', designSalesId);
        insert objAccount;
 
        Id buildPartnerId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Build Partner').getRecordTypeId();
        Account bpAccount = TestDataFactory.createAccount('Test Acc', buildPartnerId);
        bpAccount.Scope_of_work__c = 'Installation;Inspection';
        insert bpAccount;

        Vendor__c buildPartner = new Vendor__c(Name = 'Test BP', Account__c = bpAccount.Id);
        insert buildPartner;

        Id oppDesignSalesId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('3rd Party - Design Sales').getRecordTypeId();
        Opportunity objOpportunity = TestDataFactory.createOpportunity(oppDesignSalesId, 'Test Opp', objAccount.Id, '1. Appointment Set', 'Alabama');
        objOpportunity.Financing_Tool__c = 'SunRun';
        objOpportunity.Installation_Complete_Date__c = Date.today().addDays(5);
        objOpportunity.Location__c = 'Pennsylvania';
        insert objOpportunity;
         
        Id contractProcessingId = Schema.SObjectType.Job__c.getRecordTypeInfosByDeveloperName().get('Job_Close_Out').getRecordTypeId();
        Job__c objJob = new Job__c();
        objJob.Opportunity__c = objOpportunity.Id;
        objJob.RecordTypeId = contractProcessingId;
        objJob.Type__c = 'Job Close Out';
        objJob.Automation__c = true;
        insert objJob;
 
        Job_Assigned_To__c objJobAssignment = new Job_Assigned_To__c(
        Vendor__c = buildPartner.Id,
        Job__c = objJob.Id,
        Capability__c = 'Inspection'
        );
        insert objJobAssignment;
        // Actual test
        Test.startTest();
        try{
            objJobAssignment.Capability__c = 'Permitting';
            update objJobAssignment;
            System.assert(false, 'An exception should have been thrown by the trigger but was not.');
        }catch(Exception e){
            Test.stopTest();
            // Asserts
            System.assert(e.getMessage().contains(System.Label.Wrong_scope_of_work), 'The exception thrown was not the expected one');
        }
    }
}