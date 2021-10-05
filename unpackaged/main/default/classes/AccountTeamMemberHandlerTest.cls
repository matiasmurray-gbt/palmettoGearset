@isTest
public with sharing class AccountTeamMemberHandlerTest {
    @isTest
    private static void testOppTMisCreatedOnAccTMInsert() {
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

        
        Id oppDesignSalesId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('3rd Party - Design Sales').getRecordTypeId();
        Opportunity objOpportunity = TestDataFactory.createOpportunity(oppDesignSalesId, 'Test Opp', objAccount.Id, '1. Appointment Set', 'Alabama');
        objOpportunity.Financing_Tool__c = 'SunRun';
        objOpportunity.Installation_Complete_Date__c = Date.today().addDays(5);
        objOpportunity.Location__c = 'Pennsylvania';
        objOpportunity.Vendor__c = buildPartner.Id;
        insert objOpportunity;
        
        AccountTeamMember objATM = new AccountTeamMember(UserId = u.Id, AccountId = bpAccount.Id, TeamMemberRole = 'Market Manager', State__c = 'Alabama;Connecticut;Pennsylvania');
        Test.startTest();
        insert objATM;
        Test.stopTest();

        OpportunityTeamMember objOTM;
        objOTM = [SELECT Id, TeamMemberRole, OpportunityId FROM OpportunityTeamMember WHERE OpportunityId = :objOpportunity.Id];

        System.assertNotEquals(null, objOTM, 'Opp team member was not created');
        System.assertEquals('Market Manager', objOTM.TeamMemberRole, 'Opp team member was not created');
        System.assertEquals(objOpportunity.Id, objOTM.OpportunityId, 'Opp team member was not created');
    }

    @isTest
    private static void testOppTMisDeletedOnAccTMDeletion() {
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

        
        Id oppDesignSalesId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('3rd Party - Design Sales').getRecordTypeId();
        Opportunity objOpportunity = TestDataFactory.createOpportunity(oppDesignSalesId, 'Test Opp', objAccount.Id, '1. Appointment Set', 'Alabama');
        objOpportunity.Financing_Tool__c = 'SunRun';
        objOpportunity.Installation_Complete_Date__c = Date.today().addDays(5);
        objOpportunity.Location__c = 'Pennsylvania';
        objOpportunity.Vendor__c = buildPartner.Id;
        insert objOpportunity;
        
        AccountTeamMember objATM = new AccountTeamMember(UserId = u.Id, AccountId = bpAccount.Id, TeamMemberRole = 'Market Manager', State__c = 'Alabama;Connecticut;Pennsylvania');
        insert objATM;
        List<OpportunityTeamMember> objOTM = new List<OpportunityTeamMember>();
        objOTM = [SELECT Id FROM OpportunityTeamMember WHERE OpportunityId = :objOpportunity.Id];
        Test.startTest();
        delete objATM;
        Test.stopTest();

        List<OpportunityTeamMember> upObjOTM = new List<OpportunityTeamMember>();
        upObjOTM = [SELECT Id FROM OpportunityTeamMember WHERE OpportunityId = :objOpportunity.Id];

        System.assertEquals(1, objOTM.size(), 'Opp team member needed for test was not created');
        System.assertEquals(true, upObjOTM.isEmpty(), 'Opp team member was not deleted properly');
    }

    @isTest
    private static void testAccTeamMemberAddState() {
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

        
        Id oppDesignSalesId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('3rd Party - Design Sales').getRecordTypeId();
        Opportunity objOpportunity = TestDataFactory.createOpportunity(oppDesignSalesId, 'Test Opp', objAccount.Id, '1. Appointment Set', 'Alabama');
        objOpportunity.Financing_Tool__c = 'SunRun';
        objOpportunity.Installation_Complete_Date__c = Date.today().addDays(5);
        objOpportunity.Location__c = 'Alabama';
        objOpportunity.Vendor__c = buildPartner.Id;
        insert objOpportunity;
        
        AccountTeamMember objATM = new AccountTeamMember(UserId = u.Id, AccountId = bpAccount.Id, TeamMemberRole = 'Market Manager', State__c = 'Connecticut;Pennsylvania');
        insert objATM; 

        // Actual test
        Test.startTest();
        objATM.State__c = 'Alabama;Connecticut;Pennsylvania';
        update objATM;
        Test.stopTest();
    
        // Asserts
        List<OpportunityTeamMember> objOTM = new List<OpportunityTeamMember>();
        objOTM = [SELECT Id, TeamMemberRole, OpportunityId FROM OpportunityTeamMember WHERE OpportunityId = :objOpportunity.Id];

        System.assertEquals(1, objOTM.size(),'Opp team member was not created');
        System.assertEquals('Market Manager', objOTM[0].TeamMemberRole,'Opp team member was not created');
        System.assertEquals(objOpportunity.Id, objOTM[0].OpportunityId,'Opp team member was not created');
    }

    @isTest
    private static void testAccTeamMemberRemoveState() {
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

        
        Id oppDesignSalesId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('3rd Party - Design Sales').getRecordTypeId();
        Opportunity objOpportunity = TestDataFactory.createOpportunity(oppDesignSalesId, 'Test Opp', objAccount.Id, '1. Appointment Set', 'Alabama');
        objOpportunity.Financing_Tool__c = 'SunRun';
        objOpportunity.Installation_Complete_Date__c = Date.today().addDays(5);
        objOpportunity.Location__c = 'Alabama';
        objOpportunity.Vendor__c = buildPartner.Id;
        insert objOpportunity;
        
        AccountTeamMember objATM = new AccountTeamMember(UserId = u.Id, AccountId = bpAccount.Id, TeamMemberRole = 'Market Manager', State__c = 'Alabama;Connecticut;Pennsylvania');
        insert objATM;

        List<OpportunityTeamMember> objOTM = new List<OpportunityTeamMember>();
        objOTM = [SELECT Id FROM OpportunityTeamMember WHERE OpportunityId = :objOpportunity.Id];

        // Actual test
        Test.startTest();
        objATM.State__c = 'Connecticut;Pennsylvania';
        update objATM;
        Test.stopTest();
    
        // Asserts
        List<OpportunityTeamMember> upObjOTM = new List<OpportunityTeamMember>();
        upObjOTM = [SELECT Id FROM OpportunityTeamMember WHERE OpportunityId = :objOpportunity.Id];

        System.assertEquals(1, objOTM.size(), 'Opp team member needed for test was not created');
        System.assertEquals(true, upObjOTM.isEmpty(), 'Opp team member was not deleted properly');
    }

    @isTest
    private static void testAccTeamMemberChangeRoleToMarketManager() {
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

        
        Id oppDesignSalesId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('3rd Party - Design Sales').getRecordTypeId();
        Opportunity objOpportunity = TestDataFactory.createOpportunity(oppDesignSalesId, 'Test Opp', objAccount.Id, '1. Appointment Set', 'Alabama');
        objOpportunity.Financing_Tool__c = 'SunRun';
        objOpportunity.Installation_Complete_Date__c = Date.today().addDays(5);
        objOpportunity.Location__c = 'Alabama';
        objOpportunity.Vendor__c = buildPartner.Id;
        insert objOpportunity;
        
        AccountTeamMember objATM = new AccountTeamMember(UserId = u.Id, AccountId = bpAccount.Id, TeamMemberRole = 'Project Manager', State__c = 'Alabama;Connecticut;Pennsylvania');
        insert objATM; 

        // Actual test
        Test.startTest();
        objATM.TeamMemberRole = 'Market Manager';
        update objATM;
        Test.stopTest();
    
        // Asserts
        List<OpportunityTeamMember> objOTM = new List<OpportunityTeamMember>();
        objOTM = [SELECT Id, TeamMemberRole, OpportunityId FROM OpportunityTeamMember WHERE OpportunityId = :objOpportunity.Id];

        System.assertEquals(1, objOTM.size(),'Opp team member was not created');
        System.assertEquals('Market Manager', objOTM[0].TeamMemberRole,'Opp team member was not created');
        System.assertEquals(objOpportunity.Id, objOTM[0].OpportunityId,'Opp team member was not created');
    }

    @isTest
    private static void testAccTeamMemberChangeRoleFromMarketManager() {
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

        
        Id oppDesignSalesId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('3rd Party - Design Sales').getRecordTypeId();
        Opportunity objOpportunity = TestDataFactory.createOpportunity(oppDesignSalesId, 'Test Opp', objAccount.Id, '1. Appointment Set', 'Alabama');
        objOpportunity.Financing_Tool__c = 'SunRun';
        objOpportunity.Installation_Complete_Date__c = Date.today().addDays(5);
        objOpportunity.Location__c = 'Pennsylvania';
        objOpportunity.Vendor__c = buildPartner.Id;
        insert objOpportunity;
        
        AccountTeamMember objATM = new AccountTeamMember(UserId = u.Id, AccountId = bpAccount.Id, TeamMemberRole = 'Market Manager', State__c = 'Alabama;Connecticut;Pennsylvania');
        insert objATM;

        List<OpportunityTeamMember> objOTM = new List<OpportunityTeamMember>();
        objOTM = [SELECT Id FROM OpportunityTeamMember WHERE OpportunityId = :objOpportunity.Id];

        // Actual test
        Test.startTest();
        objATM.TeamMemberRole = 'Project Manager';
        update objATM;
        Test.stopTest();
    
        // Asserts
        List<OpportunityTeamMember> upObjOTM = new List<OpportunityTeamMember>();
        upObjOTM = [SELECT Id FROM OpportunityTeamMember WHERE OpportunityId = :objOpportunity.Id];

        System.assertEquals(1, objOTM.size(), 'Opp team member needed for test was not created');
        System.assertEquals(true, upObjOTM.isEmpty(), 'Opp team member was not deleted properly');
    }
}