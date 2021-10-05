@isTest
private class OpportunityHandlerTest
{
    static testMethod void unitTest(){
        Opportunity_Field_List__c objOpportunityFieldListCS = new Opportunity_Field_List__c();
        objOpportunityFieldListCS.Name = 'Loan_Term__c';
        insert objOpportunityFieldListCS;
        
        TriggerConfiguration__c objTriggerConfigurationCS = new TriggerConfiguration__c();
        objTriggerConfigurationCS.Name = 'Refresh Commissions';
        objTriggerConfigurationCS.Active__c = true;
        insert objTriggerConfigurationCS;
        
        objTriggerConfigurationCS = new TriggerConfiguration__c();
        objTriggerConfigurationCS.Name = 'Stage backward validation';
        objTriggerConfigurationCS.Active__c = true;
        insert objTriggerConfigurationCS;
    
        string account_recordtype_id = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Residential - Customer').getRecordTypeId();
        Account objAccount = TestDataFactory.createAccount('Harbor Energy',account_recordtype_id);
        insert objAccount;
        
        Contact objContact = TestDataFactory.createContact('Urvashi', 'Babbar', objAccount.Id);
        insert objContact;
        
        Dealer_Fee_Product__c objProduct = new Dealer_Fee_Product__c();
        objProduct.State__c = 'New Jersey';
        objProduct.APR__c = '3.49%';
        objProduct.Financing_Tool__c = 'Sunlight';
        objProduct.Classification__c = 'Commissions';
        objProduct.Loan_Term__c = '20';
        insert objProduct;
        
        objProduct = new Dealer_Fee_Product__c();
        objProduct.State__c = 'New Jersey';
        objProduct.APR__c = '3.49%';
        objProduct.Financing_Tool__c = 'Sunlight';
        objProduct.Classification__c = 'Internal';
        objProduct.Loan_Term__c = '20';
        insert objProduct;
        
        List<Opportunity> opp_list = new List<Opportunity>();
        string opp_recordtype_id = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('3rd Party - Design Sales').getRecordTypeId();
        Opportunity objOpportunity = TestDataFactory.createOpportunity(opp_recordtype_id, 'Test 2', objAccount.id, '7a. Contract Received Confirmed', 'Alabama');
        objOpportunity.LeadSource = '3rd Party Provider';
        objOpportunity.Lead_Source_Type__c = 'Channel';
        objOpportunity.Customer_Type__c = 'Residential - Customer';
        objOpportunity.Financing_Tool__c  = 'Sunlight';
        objOpportunity.X3rd_Party_Partner__c = 'Harbor Energy';
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
        objOpportunity.APR__c = '3.49%';
        objOpportunity.Location__c = 'New Jersey';
        insert objOpportunity;
        
        List<Job__c> lstJobToInsert = new List<Job__c>();
        Id financingId = Schema.SObjectType.Job__c.getRecordTypeInfosByName().get('Financing').getRecordTypeId();
        Job__c objJob = new Job__c();
        objJob.Opportunity__c = objOpportunity.Id;
        objJob.RecordTypeId = financingId;
        objJob.Automation__c = true;
        lstJobToInsert.add(objJob);
        
        objJob = new Job__c();
        objJob.Opportunity__c = objOpportunity.Id;
        objJob.RecordTypeId = financingId;
        objJob.Automation__c = true;
        lstJobToInsert.add(objJob);
        
        insert lstJobToInsert;
        
        
        objOpportunity.StageName = '13. Engineering Design Complete';
        objOpportunity.Panel_Wattage__c = 12;
        objOpportunity.Number_of_Solar_Panels__c = 12;
        update objOpportunity;
        
        try{
            objOpportunity.StageName = '17. Install Ready';
            update objOpportunity;
        } catch(Exception e){}
        
        Commission_Plan__c objCommissionPlan = TestDataFactory.createCommissionPlan('TEST');
        objCommissionPlan.Opportunity__c = objOpportunity.Id;
        insert objCommissionPlan;
        
        Commission__c objCommission = new Commission__c();
        objCommission.Commission_Plan__c = objCommissionPlan.Id;
        objCommission.Opportunity__c = objOpportunity.id;
        insert objCommission;
        
        objOpportunity.Loan_Term__c = '30';
        objOpportunity.Installation_Complete_Date__c = Date.today().addDays(5);
        objOpportunity.StageName = '22. PTO';
        objOpportunity.Install_Completed__c = true;
        objOpportunity.Install_Ready__c = true;
        objOpportunity.Install_Ready_Date__c = Date.today().addDays(-5);
        update objOpportunity;
        
        Backward_Validation_Exclude_List__c objValidationCS = new Backward_Validation_Exclude_List__c();
        objValidationCS.Name = 'test';
        insert objValidationCS;
        
        try{
            objOpportunity.StageName = '1. Appointment Set';
            update objOpportunity;
        } catch(Exception e){}
    } 
    
    static testMethod void unitTest2(){
        Test.setMock(HttpCalloutMock.class, new HomeMockHttpResponseGenerator());
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
        objOpportunity.Opp_Primary_Contact__c = objContact.Id;
        insert objOpportunity;
        
        Commission_Plan__c objCommissionPlan = TestDataFactory.createCommissionPlan('TEST');
        objCommissionPlan.Opportunity__c = objOpportunity.Id;
        insert objCommissionPlan;
        
        Commission__c objCommission = new Commission__c();
        objCommission.Commission_Plan__c = objCommissionPlan.Id;
        objCommission.Opportunity__c = objOpportunity.id;
        objCommission.Process_Early_M3_Payment__c = true;
        insert objCommission;
        
        objOpportunity.Loan_Term__c = '30';
        objOpportunity.Installation_Complete_Date__c = Date.today().addDays(5);
        objOpportunity.StageName = '2. Contract Signed';
        update objOpportunity;
        
                
        PalmettoAPIService.sendOppData(new Set<Id>{objOpportunity.Id});
        new OpportunityRefreshBatch().execute(null);
        
        BOM__c objBom = new Bom__c();
        objBom.Opportunity__c = objOpportunity.Id;
        objBom.Part_Number__c = '123';
        insert objBom;
        
        objOpportunity.StageName = '17. Install Ready';
        update objOpportunity;
        
        Id financingId = Schema.SObjectType.Job__c.getRecordTypeInfosByDeveloperName().get('Financing').getRecordTypeId();
        Job__c objJob = new Job__c();
        objJob.Opportunity__c = objOpportunity.Id;
        objJob.RecordTypeId = financingId;
        objJob.Type__c = 'SunRun';
        objJob.Flow_Status__c = 'M2 - Pending Submittal';
        objJob.Automation__c = true;
        insert objJob;
        
        
        try{
            objOpportunity.StageName = '19. Install Completed';
        } catch(Exception e){}
        
        Dealer_Fee_Product__c objProduct = new Dealer_Fee_Product__c();
        objProduct.State__c = 'New Jersey';
        objProduct.APR__c = '3.49%';
        objProduct.Financing_Tool__c = 'SunRun';
        objProduct.Classification__c = 'Commissions';
        objProduct.Loan_Term__c = '20';
        insert objProduct;
        
        
        objOpportunity.Install_Ready_Date__c = Date.today();
        objOpportunity.Financing_Tool__c = 'SunRun';
        objOpportunity.StageName = '21. Inspection Complete';
        objOpportunity.Install_Completed__c = true;
        objOpportunity.Install_Ready__c = true;
        objOpportunity.Install_Ready_Date__c = Date.today().addDays(-5);
        update objOpportunity;
        
        objOpportunity.System_Size_kW__c = 47;
        update objOpportunity;
    }    
    
    static testMethod void unitTest3(){
        TriggerConfiguration__c objTriggerConfigCS = new TriggerConfiguration__c();
        objTriggerConfigCS.Name = 'Order API Trigger';
        objTriggerConfigCS.Active__c = true;
        insert objTriggerConfigCS;
    
        Id buildOnlyLeadId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Build Only').getRecordTypeId();
        Lead objLead = new Lead();
        objLead.FirstName = 'test';
        objLead.LastName = 'test';
        objLead.Email = 'test@test.com';
        objLead.Company = 'X';
        objLead.Scope_of_Work__c = 'Permit and Installation';
        objLead.RecordTypeId = buildOnlyLeadId;
        insert objLead;
        
        Vendor__c objVendor = new Vendor__c();
        objVendor.Name = 'Test';
        insert objVendor;
        
        Service_Agreement__c objServiceAgreement = new Service_Agreement__c();
        objServiceAgreement.Vendor__c = objVendor.Id;
        objServiceAgreement.State__c = 'Alabama';
        insert objServiceAgreement;
        
        Pricing_Detail__c objPricingDetail = new Pricing_Detail__c();
        objPricingDetail.Service_Agreement__c = objServiceAgreement.Id;
        insert objPricingDetail;
        
        List<Opportunity> lstOpp = [SELECT Id from Opportunity];
        System.assertEquals(lstOpp.size(), 1);
        
        lstOpp[0].Vendor__c = objVendor.Id;
        lstOpp[0].Location__c = 'Alabama';
        lstOpp[0].Schedule_System_Activation_Walk_Through__c = true;
        update lstOpp;
    } 

    @isTest
    public static void testOppTeamMembesIsCreatedOnInsert(){
        Test.setMock(HttpCalloutMock.class, new HomeMockHttpResponseGenerator());
        // Test data setup
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User u = new User(Alias = 'standt', Email='opptriggertestuser@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='opptriggertestuser@testorg.com');
        insert u;
        
        Id buildPartnerId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Build Partner').getRecordTypeId();
        Account bpAccount = TestDataFactory.createAccount('Test Acc', buildPartnerId);
        insert bpAccount;

        Id designSalesId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('3rd Party - Design Sales').getRecordTypeId();
        Account objAccount = TestDataFactory.createAccount('Test Acc', designSalesId);
        insert objAccount;

        Vendor__c buildPartner = new Vendor__c(Name = 'Test BP', Account__c = bpAccount.Id);
        insert buildPartner;

        AccountTeamMember objATM = new AccountTeamMember(UserId = u.Id, AccountId = bpAccount.Id, TeamMemberRole = 'Market Manager', State__c = 'Alabama;Connecticut;Pennsylvania');
        insert objATM;
        
        Id oppDesignSalesId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('3rd Party - Design Sales').getRecordTypeId();
        Opportunity objOpportunity = TestDataFactory.createOpportunity(oppDesignSalesId, 'Test Opp', objAccount.Id, '1. Appointment Set', 'Alabama');
        objOpportunity.Financing_Tool__c = 'SunRun';
        objOpportunity.Installation_Complete_Date__c = Date.today().addDays(5);
        objOpportunity.Location__c = 'Pennsylvania';
        objOpportunity.Vendor__c = buildPartner.Id;

        Test.startTest();
        insert objOpportunity;
        Test.stopTest();

        OpportunityTeamMember objOTM = [SELECT Id, TeamMemberRole FROM OpportunityTeamMember WHERE OpportunityId = :objOpportunity.Id];

        System.assertNotEquals(null, objOTM);
        System.assertEquals('Market Manager', objOTM.TeamMemberRole);
    }

    @isTest
    public static void testOppTeamMembesIsUpdatedOnChange(){
        Test.setMock(HttpCalloutMock.class, new HomeMockHttpResponseGenerator());
        // Test data setup
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User u = new User(Alias = 'standt', Email='opptriggertestuser@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='opptriggertestuser@testorg.com');
        insert u;
        User u2 = new User(Alias = 'standt', Email='opptriggertestuser2@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='opptriggertestuser2@testorg.com');
        insert u2;
        
        Id buildPartnerId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Build Partner').getRecordTypeId();
        Account bpAccount = TestDataFactory.createAccount('Test Acc', buildPartnerId);
        insert bpAccount;
        Account bpAccount2 = TestDataFactory.createAccount('Test Acc 2', buildPartnerId);
        insert bpAccount2;

        Vendor__c buildPartner = new Vendor__c(Name = 'Test BP', Account__c = bpAccount.Id);
        insert buildPartner;
        Vendor__c buildPartner2 = new Vendor__c(Name = 'Test BP', Account__c = bpAccount2.Id);
        insert buildPartner2;

        AccountTeamMember objATM = new AccountTeamMember(UserId = u.Id, AccountId = bpAccount.Id, TeamMemberRole = 'Market Manager', State__c = 'Alabama;Connecticut;Pennsylvania');
        insert objATM;

        AccountTeamMember objATM2 = new AccountTeamMember(UserId = u2.Id, AccountId = bpAccount2.Id, TeamMemberRole = 'Market Manager', State__c = 'Alabama;Connecticut;Pennsylvania');
        insert objATM2;

        Id designSalesId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('3rd Party - Design Sales').getRecordTypeId();
        Account objAccount = TestDataFactory.createAccount('Test Acc', designSalesId);
        insert objAccount;

        
        Id oppDesignSalesId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('3rd Party - Design Sales').getRecordTypeId();
        Opportunity objOpportunity = TestDataFactory.createOpportunity(oppDesignSalesId, 'Test Opp', objAccount.Id, '1. Appointment Set', 'Alabama');
        objOpportunity.Financing_Tool__c = 'SunRun';
        objOpportunity.Installation_Complete_Date__c = Date.today().addDays(5);
        objOpportunity.Location__c = 'Pennsylvania';
        objOpportunity.Vendor__c = buildPartner.Id;
        insert objOpportunity;

        Test.startTest();
        objOpportunity.Vendor__c = buildPartner2.Id;
        update objOpportunity;
        Test.stopTest();

        OpportunityTeamMember[] objOTM = [SELECT Id, TeamMemberRole, UserId FROM OpportunityTeamMember WHERE OpportunityId = :objOpportunity.Id];

        System.assertNotEquals(null, objOTM);
        System.assertEquals(1, objOTM.size());
        System.assertEquals('Market Manager', objOTM[0].TeamMemberRole);
        System.assertEquals(u2.Id, objOTM[0].UserId);
    }

    @isTest
    static void testOpportunityAmountIsChanged(){
        Id designSalesId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('3rd Party - Design Sales').getRecordTypeId();
        Account anAccount = TestDataFactory.createAccount('Palmetto Acc', designSalesId);
        insert anAccount;
        
        Id oppDesignSalesId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('3rd Party - Design Sales').getRecordTypeId();
        Opportunity anOpportunity = TestDataFactory.createOpportunity(oppDesignSalesId, 'Test Opp', anAccount.Id, '1. Appointment Set', 'Alabama');
        anOpportunity.Amount = 100;
        insert anOpportunity;

        Id financingId = Schema.SObjectType.Job__c.getRecordTypeInfosByDeveloperName().get('Financing').getRecordTypeId();    
        Job__c aJob = new Job__c();
        aJob.Name = 'FinOps Job';
        aJob.Opportunity__c = anOpportunity.Id;
        aJob.RecordTypeId = financingId;
        aJob.Automation__c = true;
        aJob.Flow_Status__c = 'Notice to Proceed';
        insert aJob;

        Test.startTest();
        anOpportunity.Amount = 101;
        update anOpportunity;
        Test.stopTest();

        Job__c updatedJob = [SELECT Id, Flow_Status__c FROM Job__c WHERE Id = :aJob.Id];
        System.assertEquals('M0 - Pending NTP', updatedJob.Flow_Status__c);
    }
}