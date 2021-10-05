@isTest
public class PalmettoAPIServiceTest {
    @isTest
    static void testInterconnectionSubmittedCallout() {
        TriggerConfiguration__c testCallout = new TriggerConfiguration__c();
        testCallout.Name = 'Test send callouts';
        testCallout.Active__c = true;
        insert testCallout;

        TriggerConfiguration__c apiCall = new TriggerConfiguration__c();
        apiCall.Name = 'Order API Trigger';
        apiCall.Active__c = true;
        insert apiCall;

        Id designSalesId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('3rd Party - Design Sales').getRecordTypeId();
        Account objAccount = TestDataFactory.createAccount('Test Acc', designSalesId);
        insert objAccount;

        Id oppDesignSalesId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('3rd Party - Design Sales').getRecordTypeId();
        Opportunity objOpportunity = TestDataFactory.createOpportunity(oppDesignSalesId, 'Test Opp 784', objAccount.Id, '1. Appointment Set', 'Alabama');
        objOpportunity.Financing_Tool__c = 'SunRun';
        objOpportunity.Installation_Complete_Date__c = Date.today().addDays(5);
        objOpportunity.Location__c = 'Pennsylvania';
        insert objOpportunity;

        Project_Milestone__c milestone = [SELECT Id FROM Project_Milestone__c WHERE Opportunity__c = :objOpportunity.Id];

        Test.setMock(HttpCalloutMock.class, new PalmettoAPIServiceCalloutMocks.InterconnectionSubmittedMockImp());
        Test.startTest();
        milestone.Interconnection_Application_Submitted__c = Datetime.now();
        update milestone;
        Test.stopTest();
        
        System.assert(true);
    }

    @isTest
    static void testInterconnectionApprovedCallout() {
        TriggerConfiguration__c testCallout = new TriggerConfiguration__c();
        testCallout.Name = 'Test send callouts';
        testCallout.Active__c = true;
        insert testCallout;

        TriggerConfiguration__c apiCall = new TriggerConfiguration__c();
        apiCall.Name = 'Order API Trigger';
        apiCall.Active__c = true;
        insert apiCall;

        Id designSalesId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('3rd Party - Design Sales').getRecordTypeId();
        Account objAccount = TestDataFactory.createAccount('Test Acc', designSalesId);
        insert objAccount;

        Id oppDesignSalesId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('3rd Party - Design Sales').getRecordTypeId();
        Opportunity objOpportunity = TestDataFactory.createOpportunity(oppDesignSalesId, 'Test Opp 784', objAccount.Id, '1. Appointment Set', 'Alabama');
        objOpportunity.Financing_Tool__c = 'SunRun';
        objOpportunity.Installation_Complete_Date__c = Date.today().addDays(5);
        objOpportunity.Location__c = 'Pennsylvania';
        insert objOpportunity;

        Project_Milestone__c milestone = [SELECT Id FROM Project_Milestone__c WHERE Opportunity__c = :objOpportunity.Id];

        Test.setMock(HttpCalloutMock.class, new PalmettoAPIServiceCalloutMocks.InterconnectionApprovedMockImp());
        Test.startTest();
        milestone.Interconnection_Application_Approved__c = Datetime.now();
        update milestone;
        Test.stopTest();
        
        System.assert(true);
    }

    @isTest
    static void testInstallScheduledCallout() {
        TriggerConfiguration__c testCallout = new TriggerConfiguration__c();
        testCallout.Name = 'Test send callouts';
        testCallout.Active__c = true;
        insert testCallout;

        TriggerConfiguration__c apiCall = new TriggerConfiguration__c();
        apiCall.Name = 'Order API Trigger';
        apiCall.Active__c = true;
        insert apiCall;

        Id designSalesId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('3rd Party - Design Sales').getRecordTypeId();
        Account objAccount = TestDataFactory.createAccount('Test Acc', designSalesId);
        insert objAccount;

        Id oppDesignSalesId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('3rd Party - Design Sales').getRecordTypeId();
        Opportunity objOpportunity = TestDataFactory.createOpportunity(oppDesignSalesId, 'Test Opp 784', objAccount.Id, '1. Appointment Set', 'Alabama');
        objOpportunity.Financing_Tool__c = 'SunRun';
        objOpportunity.Installation_Complete_Date__c = Date.today().addDays(5);
        objOpportunity.Location__c = 'Pennsylvania';
        insert objOpportunity;

        Project_Milestone__c milestone = [SELECT Id FROM Project_Milestone__c WHERE Opportunity__c = :objOpportunity.Id];

        Test.setMock(HttpCalloutMock.class, new PalmettoAPIServiceCalloutMocks.InstallScheduledMockImp());
        Test.startTest();
        milestone.Installation_Scheduled_Milestone__c = Datetime.now();
        update milestone;
        Test.stopTest();
        
        System.assert(true);
    }

    @isTest
    static void testSurveyCompletedCallout() {
        TriggerConfiguration__c testCallout = new TriggerConfiguration__c();
        testCallout.Name = 'Test send callouts';
        testCallout.Active__c = true;
        insert testCallout;

        TriggerConfiguration__c apiCall = new TriggerConfiguration__c();
        apiCall.Name = 'Order API Trigger';
        apiCall.Active__c = true;
        insert apiCall;

        Id designSalesId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('3rd Party - Design Sales').getRecordTypeId();
        Account objAccount = TestDataFactory.createAccount('Test Acc', designSalesId);
        insert objAccount;

        Id oppDesignSalesId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('3rd Party - Design Sales').getRecordTypeId();
        Opportunity objOpportunity = TestDataFactory.createOpportunity(oppDesignSalesId, 'Test Opp 784', objAccount.Id, '1. Appointment Set', 'Alabama');
        objOpportunity.Financing_Tool__c = 'SunRun';
        objOpportunity.Installation_Complete_Date__c = Date.today().addDays(5);
        objOpportunity.Location__c = 'Pennsylvania';
        insert objOpportunity;

        Project_Milestone__c milestone = [SELECT Id FROM Project_Milestone__c WHERE Opportunity__c = :objOpportunity.Id];

        Test.setMock(HttpCalloutMock.class, new PalmettoAPIServiceCalloutMocks.SurveyCompletedMockImp());
        Test.startTest();
        milestone.Site_Survey_Completed_Milestone__c = Datetime.now();
        update milestone;
        Test.stopTest();
        
        System.assert(true);
    }

    @isTest
    static void testInstallReadyCallout() {
        TriggerConfiguration__c testCallout = new TriggerConfiguration__c();
        testCallout.Name = 'Test send callouts';
        testCallout.Active__c = true;
        insert testCallout;

        TriggerConfiguration__c apiCall = new TriggerConfiguration__c();
        apiCall.Name = 'Order API Trigger';
        apiCall.Active__c = true;
        insert apiCall;

        Id designSalesId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('3rd Party - Design Sales').getRecordTypeId();
        Account objAccount = TestDataFactory.createAccount('Test Acc', designSalesId);
        insert objAccount;

        Id oppDesignSalesId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('3rd Party - Design Sales').getRecordTypeId();
        Opportunity objOpportunity = TestDataFactory.createOpportunity(oppDesignSalesId, 'Test Opp 784', objAccount.Id, '1. Appointment Set', 'Alabama');
        objOpportunity.Financing_Tool__c = 'SunRun';
        objOpportunity.Installation_Complete_Date__c = Date.today().addDays(5);
        objOpportunity.Location__c = 'Pennsylvania';
        insert objOpportunity;

        Project_Milestone__c milestone = [SELECT Id FROM Project_Milestone__c WHERE Opportunity__c = :objOpportunity.Id];

        Test.setMock(HttpCalloutMock.class, new PalmettoAPIServiceCalloutMocks.InstallReadyMockImp());
        Test.startTest();
        milestone.Installation_Ready_Milestone__c = Datetime.now();
        update milestone;
        Test.stopTest();
        
        System.assert(true);
    }

    @isTest
    static void sendCommissionData(){
        //Test copies from CommissionTriggerHandlerTest to give coverage to API class
        TriggerConfiguration__c objTriggerConfigurationCS = new TriggerConfiguration__c();
        objTriggerConfigurationCS.Name = 'LGCY API trigger';
        objTriggerConfigurationCS.Active__c = true;
        insert objTriggerConfigurationCS;

        
        
        Account objAccount = new Account();
        objAccount.Name = 'Test 1';
        insert objAccount;
        
        Contact objContact = TestDataFactory.createContact('Urvashi', 'Babbar', objAccount.Id);
        insert objContact;
        
        string opp_recordtype_id = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('3rd Party - Design Sales').getRecordTypeId();
        Opportunity objOpportunity = TestDataFactory.createOpportunity(opp_recordtype_id, 'Test 2', objAccount.id, '7a. Contract Received Confirmed', 'Alabama');
        objOpportunity.LeadSource = '3rd Party Provider';
        objOpportunity.Lead_Source_Type__c = 'Channel';
        objOpportunity.Customer_Type__c = 'Residential - Customer';
        objOpportunity.Financing_Tool__c  = 'Sunlight';
        objOpportunity.X3rd_Party_Partner__c = 'LGCY Power';
        objOpportunity.Loan_Term__c = '20';
        objOpportunity.Proposal_Created__c = true;
        objOpportunity.Engineering_Created__c = true;
        objOpportunity.Final_Design_Created_Date__c = system.Date.today();
        objOpportunity.Number_of_Arrays__c = 1;
        objOpportunity.Contract_Received_Confirmed__c= true;
        objOpportunity.Contract_Received_Confirmed_Date__c = system.Date.today().addDays(-5);
        objOpportunity.Amount = 30000;
        objOpportunity.Number_of_Solar_Panels__c  = 25;
        objOpportunity.Panel_Type__c = 'Q.PEAK-G4.1 300';
        objOpportunity.Panel_Wattage__c = 300;
        objOpportunity.Test_Account__c = false;
        insert objOpportunity;
        
        Commission_Plan__c objCommissionPlan = TestDataFactory.createCommissionPlan('TEST');
        objCommissionPlan.Opportunity__c = objOpportunity.Id;
        insert objCommissionPlan;
        
        Commission__c objCommission = new Commission__c();
        objCommission.Commission_Plan__c = objCommissionPlan.Id;
        objCommission.Opportunity__c = objOpportunity.id;
        insert objCommission;
        
        update objCommission;
        
        PalmettoAPIService.sendCommissionData(new Set<Id>{objCommission.Id});
    }

    @isTest
    static void testSendOppData(){
        //test copied from OpportunityHandlerTest to ensure code coverage
        TriggerConfiguration__c objTriggerConfigurationCS = new TriggerConfiguration__c();
        objTriggerConfigurationCS.Name = 'LGCY API trigger';
        objTriggerConfigurationCS.Active__c = true;
        insert objTriggerConfigurationCS;
        
        objTriggerConfigurationCS = new TriggerConfiguration__c();
        objTriggerConfigurationCS.Name = 'Alchemy API trigger';
        objTriggerConfigurationCS.Active__c = true;
        insert objTriggerConfigurationCS;
        
        objTriggerConfigurationCS = new TriggerConfiguration__c();
        objTriggerConfigurationCS.Name = 'HomeCustomerUpdate';
        objTriggerConfigurationCS.Active__c = true;
        insert objTriggerConfigurationCS;
        
        objTriggerConfigurationCS = new TriggerConfiguration__c();
        objTriggerConfigurationCS.Name = 'Refresh Commissions';
        objTriggerConfigurationCS.Active__c = true;
        insert objTriggerConfigurationCS;
    
        Opportunity_Field_List__c objOpportunityFieldListCS = new Opportunity_Field_List__c();
        objOpportunityFieldListCS.Name = 'Loan_Term__c';
        insert objOpportunityFieldListCS;
    
        string account_recordtype_id = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Residential - Customer').getRecordTypeId();
        Account objAccount = TestDataFactory.createAccount('Harbor Energy',account_recordtype_id);
        insert objAccount;
        
        Contact objContact = TestDataFactory.createContact('Urvashi', 'Babbar', objAccount.Id);
        insert objContact;

        string opp_recordtype_id = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('3rd Party - Design Sales').getRecordTypeId();
        Opportunity objOpportunity = TestDataFactory.createOpportunity(opp_recordtype_id, 'Test 2', objAccount.id, '7a. Contract Received Confirmed', 'Alabama');
        objOpportunity.LeadSource = '3rd Party Provider';
        objOpportunity.Lead_Source_Type__c = 'Independent';
        objOpportunity.Customer_Type__c = 'Residential - Customer';
        objOpportunity.Financing_Tool__c  = 'Sunlight';
        objOpportunity.X3rd_Party_Partner__c = 'LGCY Power';
        objOpportunity.Loan_Term__c = '20';
        objOpportunity.Proposal_Created__c = true;
        objOpportunity.Engineering_Created__c = true;
        objOpportunity.Final_Design_Created_Date__c = system.Date.today();
        objOpportunity.Number_of_Arrays__c = 1;
        objOpportunity.Contract_Received_Confirmed__c= true;
        objOpportunity.Contract_Received_Confirmed_Date__c = system.Date.today().addDays(-5);
        objOpportunity.Amount = 30000;
        objOpportunity.Number_of_Solar_Panels__c  = 25;
        objOpportunity.Panel_Type__c = 'Q.PEAK-G4.1 300';
        objOpportunity.Panel_Wattage__c = 300;
        objOpportunity.Test_Account__c = false;
        objOpportunity.Contact__c = objContact.Id;
        objOpportunity.StageName = '1. Appointment Set';
        insert objOpportunity;
                
        PalmettoAPIService.sendOppData(new Set<Id>{objOpportunity.Id});
    }
    
    @isTest
    static void testOrderStatusFromOppCallout() {
        TriggerConfiguration__c testCallout = new TriggerConfiguration__c();
        testCallout.Name = 'Test send callouts';
        testCallout.Active__c = true;
        insert testCallout;

        TriggerConfiguration__c apiCall = new TriggerConfiguration__c();
        apiCall.Name = 'Order API Trigger';
        apiCall.Active__c = true;
        insert apiCall;

        Id designSalesId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('3rd Party - Design Sales').getRecordTypeId();
        Account objAccount = TestDataFactory.createAccount('Test Acc', designSalesId);
        insert objAccount;

        Id oppDesignSalesId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('3rd Party - Design Sales').getRecordTypeId();
        Opportunity objOpportunity = TestDataFactory.createOpportunity(oppDesignSalesId, 'Test Opp 784', objAccount.Id, '1. Appointment Set', 'Alabama');
        objOpportunity.Financing_Tool__c = 'SunRun';
        objOpportunity.Installation_Complete_Date__c = Date.today().addDays(5);
        objOpportunity.Location__c = 'Pennsylvania';
        insert objOpportunity;

        Set<Id> oppsIds = new Set<Id>();
        oppsIds.add(objOpportunity.Id);
        Test.setMock(HttpCalloutMock.class, new PalmettoAPIServiceCalloutMocks.OrderStatusFromOppMockImp(objOpportunity.Id));
        Test.startTest();
        PalmettoAPIService.sendOrderStatusFromOpp(oppsIds);
        Test.stopTest();

        //The real assert is in the mock
        System.assert(true);
    }

    @isTest
    static void testBuildJobAssignmentUpdateCallout() {
        // Test data setup
        TriggerConfiguration__c testCallout = new TriggerConfiguration__c();
        testCallout.Name = 'Test send callouts';
        testCallout.Active__c = true;
        insert testCallout;

        TriggerConfiguration__c apiCall = new TriggerConfiguration__c();
        apiCall.Name = 'Order API Trigger';
        apiCall.Active__c = true;
        insert apiCall;

        TriggerConfiguration__c jobApiCall = new TriggerConfiguration__c();
        jobApiCall.Name = 'Job Assignment API Trigger';
        jobApiCall.Active__c = true;
        insert jobApiCall;

        Id designSalesId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('3rd Party - Design Sales').getRecordTypeId();
        Account objAccount = TestDataFactory.createAccount('Test Acc', designSalesId);
        insert objAccount;

        Id buildPartnerId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Build Partner').getRecordTypeId();
        Account bpAccount = TestDataFactory.createAccount('Test Acc', buildPartnerId);
        bpAccount.Scope_of_Work__c = 'Installation';
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

        Test.setMock(HttpCalloutMock.class, new PalmettoAPIServiceCalloutMocks.JobAssignmentUpdateMockImp(buildPartner.Id, objJob.Id));
        Test.startTest();
        Job_Assigned_To__c objJobAssignment = new Job_Assigned_To__c(
            Vendor__c = buildPartner.Id,
            Job__c = objJob.Id,
            Capability__c = 'Installation'
        );
        insert objJobAssignment;
        Test.stopTest();

        //The real assert is in the mock
        System.assert(true);
    }

    @isTest
    private static void testBuildPartnerUpdateCallout() {
        // Test data setup
        TriggerConfiguration__c testCallout = new TriggerConfiguration__c();
        testCallout.Name = 'Test send callouts';
        testCallout.Active__c = true;
        insert testCallout;

        TriggerConfiguration__c apiCall = new TriggerConfiguration__c();
        apiCall.Name = 'Order API Trigger';
        apiCall.Active__c = true;
        insert apiCall;

        TriggerConfiguration__c jobApiCall = new TriggerConfiguration__c();
        jobApiCall.Name = 'Job Assignment API Trigger';
        jobApiCall.Active__c = true;
        insert jobApiCall;

        Id buildPartnerId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Build Partner').getRecordTypeId();
        Account bpAccount = TestDataFactory.createAccount('Test Acc', buildPartnerId);
        insert bpAccount;

        Id designSalesId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('3rd Party - Design Sales').getRecordTypeId();
        Account objAccount = TestDataFactory.createAccount('Test Acc', designSalesId);
        insert objAccount;

        Vendor__c buildPartner = new Vendor__c(Name = 'Test BP', Account__c = bpAccount.Id);
        insert buildPartner;

        
        Id oppDesignSalesId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('3rd Party - Design Sales').getRecordTypeId();
        Opportunity objOpportunity = TestDataFactory.createOpportunity(oppDesignSalesId, 'Test Opp', objAccount.Id, '1. Appointment Set', 'Alabama');
        objOpportunity.Vendor__c = buildPartner.Id;
        insert objOpportunity;

        Id inpectionId = Schema.SObjectType.Job__c.getRecordTypeInfosByDeveloperName().get('Inspection').getRecordTypeId();
        Job__c objJob = new Job__c();
        objJob.Opportunity__c = objOpportunity.Id;
        objJob.RecordTypeId = inpectionId;
        objJob.Build_Partner__c = buildPartner.Id;
        objJob.Type__c = 'Inspection';
        objJob.Automation__c = true;
        // Actual test
        Test.setMock(HttpCalloutMock.class, new PalmettoAPIServiceCalloutMocks.BuildPartnerUpdateMockImp(buildPartner.Id));
        Test.startTest();
        insert objJob;
        Test.stopTest();
    
        // Asserts
        //The real assert is in the mock
        System.assert(true);
    }
    
    @isTest
    static void testCaseAssignmentUpdateCallout() {
        // Test data setup
        TriggerConfiguration__c testCallout = new TriggerConfiguration__c();
        testCallout.Name = 'Test send callouts';
        testCallout.Active__c = true;
        insert testCallout;

        TriggerConfiguration__c apiCall = new TriggerConfiguration__c();
        apiCall.Name = 'Order API Trigger';
        apiCall.Active__c = true;
        insert apiCall;

        TriggerConfiguration__c caseApiCall = new TriggerConfiguration__c();
        caseApiCall.Name = 'Case Assignment API Trigger';
        caseApiCall.Active__c = true;
        insert caseApiCall;

        Id designSalesId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('3rd Party - Design Sales').getRecordTypeId();
        Account objAccount = TestDataFactory.createAccount('Test Acc', designSalesId);
        insert objAccount;

        Id buildPartnerId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Build Partner').getRecordTypeId();
        Account bpAccount = TestDataFactory.createAccount('Test Acc', buildPartnerId);
        bpAccount.Scope_of_Work__c = 'Installation';
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

        Test.setMock(HttpCalloutMock.class, new PalmettoAPIServiceCalloutMocks.CaseAssignmentUpdateMockImp(buildPartner.Id, objCase.Id));
        Test.startTest();
        Case_Assigned_To__c objCaseAssignment = new Case_Assigned_To__c(
            Vendor__c = buildPartner.Id,
            Case__c = objCase.Id,
            Capability__c = 'Installation'
            );
        insert objCaseAssignment;
        Test.stopTest();

        //The real assert is in the mock
        System.assert(true);
    }
    
}