@isTest
public with sharing class RadiusHandlerTest {
    @TestSetup
    static void setup(){
        Id designSalesId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('3rd Party - Design Sales').getRecordTypeId();
        Account anAccount = TestDataFactory.createAccount('Palmetto Acc', designSalesId);
        INSERT anAccount;
        
        Id oppDesignSalesId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('3rd Party - Design Sales').getRecordTypeId();
        Opportunity anOpportunity = TestDataFactory.createOpportunity(oppDesignSalesId, 'Test Opp', anAccount.Id, '1. Appointment Set', 'Alabama');
        anOpportunity.Utility__c = 'Austin Energy';
        INSERT anOpportunity;
        
        TriggerConfiguration__c aTriggerConfiguration = new TriggerConfiguration__c(Name= 'Order API Trigger',Active__c = true);
        INSERT aTriggerConfiguration;

        Product2 aProduct = new Product2();
        aProduct.Name = 'PV-000001';
        aProduct.ProductCode = 'PV-000001';
        INSERT aProduct;

        BOM__c aBom = new BOM__c();
        aBom.Opportunity__c = anOpportunity.Id;
        aBom.Part_Number2__c = aProduct.Id;
        INSERT aBom;

    }
    @IsTest
    static void unitTest1(){
        

        Project_Milestone__c aProjectMilestone = [
            SELECT Id 
            FROM Project_Milestone__c 
            WHERE Opportunity__r.Name = 'Palmetto Acc - Opportunity'
            LIMIT 1
        ];

        Test.startTest();
        aProjectMilestone.Survey_Complete_Confirmed__c = Datetime.now().addDays(1);
        aProjectMilestone.Energy_Bill_checked__c = Datetime.now();
        aProjectMilestone.Contract_Received_Milestone__c = Datetime.now();
        UPDATE aProjectMilestone;
        Test.stopTest();

        Project_Milestone__c verifyMilestone = [
            SELECT Id, Design_Queued_Milestone__c, Survey_Complete_Confirmed__c
            FROM Project_Milestone__c 
            WHERE Opportunity__r.Name = 'Palmetto Acc - Opportunity'
            LIMIT 1
        ];

        System.assertEquals(verifyMilestone.Survey_Complete_Confirmed__c, verifyMilestone.Design_Queued_Milestone__c);
    }

    @IsTest
    static void unitTest2(){
        Project_Milestone__c aProjectMilestone = [
            SELECT Id, Design_Queued_Milestone__c
            FROM Project_Milestone__c 
            WHERE Opportunity__r.Name = 'Palmetto Acc - Opportunity'
            LIMIT 1
        ];

        Opportunity anOpportunity = [
            SELECT Id
            FROM Opportunity
            WHERE Name = 'Palmetto Acc - Opportunity'
        ];

        Test.startTest();
        anOpportunity.Financing_Tool__c = 'Sunlight';
        UPDATE anOpportunity;
        aProjectMilestone.Design_Queued_Milestone__c = Datetime.now();
        UPDATE aProjectMilestone;
        Test.stopTest();

        List<Job__c> verifyJob = [
            SELECT Id
            FROM Job__c
            WHERE Opportunity__r.Name = 'Palmetto Acc - Opportunity'
            AND (RecordType.DeveloperName = 'Design' OR RecordType.DeveloperName = 'Financing')
        ];
        
        System.assertEquals(2, verifyJob.size());
        
    }

    @IsTest
    static void unitTest3(){
        Project_Milestone__c aProjectMilestone = [
            SELECT Id, Design_Queued_Milestone__c
            FROM Project_Milestone__c 
            WHERE Opportunity__r.Name = 'Palmetto Acc - Opportunity'
            LIMIT 1
        ];

        Test.startTest();
        aProjectMilestone.Design_Completed_Milestone__c = Datetime.now();
        UPDATE aProjectMilestone;
        Test.stopTest();

        List<Job__c> verifyJob = [
            SELECT Id
            FROM Job__c
            WHERE Opportunity__r.Name = 'Palmetto Acc - Opportunity'
            AND RecordType.DeveloperName = 'Permitting'
        ];
        
        System.assertEquals(1, verifyJob.size());
    }

    @IsTest
    static void unitTest4(){
        Opportunity anOpportunity = [
            SELECT Id
            FROM Opportunity
            WHERE Name = 'Palmetto Acc - Opportunity'
            LIMIT 1
        ];

        Id supplyChainId = Schema.SObjectType.Job__c.getRecordTypeInfosByDeveloperName().get('Supply_Chain').getRecordTypeId();   
        Job__c supplyChainJob = new Job__c();
        supplyChainJob.RecordTypeId = supplyChainId;
        supplyChainJob.Opportunity__c = anOpportunity.Id;
        INSERT supplyChainJob;

        Project_Milestone__c aProjectMilestone = [
            SELECT Id, Design_Queued_Milestone__c
            FROM Project_Milestone__c 
            WHERE Opportunity__r.Name = 'Palmetto Acc - Opportunity'
            LIMIT 1
        ];

        Test.startTest();
        aProjectMilestone.Design_Completed_Milestone__c = Datetime.now();
        UPDATE aProjectMilestone;
        Test.stopTest();

        List<Job__c> verifyJob = [
            SELECT Id, Flow_Status__c
            FROM Job__c
            WHERE Opportunity__r.Name = 'Palmetto Acc - Opportunity'
            AND RecordType.DeveloperName = 'Supply_Chain'
        ];
        
        System.assertEquals('Design / BOM Complete', verifyJob[0].Flow_Status__c);
    }

    @IsTest
    static void unitTest5(){
        Project_Milestone__c aProjectMilestone = [
            SELECT Id, Design_Queued_Milestone__c
            FROM Project_Milestone__c 
            WHERE Opportunity__r.Name = 'Palmetto Acc - Opportunity'
            LIMIT 1
        ];

        Test.startTest();
        aProjectMilestone.Permit_Submitted_Milestone__c = Datetime.now();
        UPDATE aProjectMilestone;
        Test.stopTest();

        List<Job__c> verifyJob = [
            SELECT Id
            FROM Job__c
            WHERE Opportunity__r.Name = 'Palmetto Acc - Opportunity'
            AND RecordType.DeveloperName = 'Installation_Scheduling'
        ];
        
        System.assertEquals(1, verifyJob.size());
    }

    @IsTest
    static void unitTest6(){
        Project_Milestone__c aProjectMilestone = [
            SELECT Id, Design_Queued_Milestone__c
            FROM Project_Milestone__c 
            WHERE Opportunity__r.Name = 'Palmetto Acc - Opportunity'
            LIMIT 1
        ];

        Test.startTest();
        aProjectMilestone.Installation_Completed_Milestone__c = Datetime.now();
        UPDATE aProjectMilestone;
        Test.stopTest();

        List<Job__c> verifyJob = [
            SELECT Id
            FROM Job__c
            WHERE Opportunity__r.Name = 'Palmetto Acc - Opportunity'
            AND RecordType.DeveloperName = 'Inspection'
        ];
        
        System.assertEquals(1, verifyJob.size());
    }

    @IsTest
    static void unitTest7(){
        Opportunity anOpportunity = [
            SELECT Id
            FROM Opportunity
            WHERE Name = 'Palmetto Acc - Opportunity'
            LIMIT 1
        ];

        Id supplyChainId = Schema.SObjectType.Job__c.getRecordTypeInfosByDeveloperName().get('Supply_Chain').getRecordTypeId();   
        Job__c supplyChainJob = new Job__c();
        supplyChainJob.RecordTypeId = supplyChainId;
        supplyChainJob.Opportunity__c = anOpportunity.Id;
        INSERT supplyChainJob;

        Project_Milestone__c aProjectMilestone = [
            SELECT Id, Design_Queued_Milestone__c
            FROM Project_Milestone__c 
            WHERE Opportunity__r.Name = 'Palmetto Acc - Opportunity'
            LIMIT 1
        ];

        Test.startTest();
        aProjectMilestone.Installation_Completed_Milestone__c = Datetime.now();
        UPDATE aProjectMilestone;
        Test.stopTest();

        List<Job__c> verifyJob = [
            SELECT Id, Flow_Status__c
            FROM Job__c
            WHERE Opportunity__r.Name = 'Palmetto Acc - Opportunity'
            AND RecordType.DeveloperName = 'Supply_Chain'
        ];
        
        System.assertEquals('Fulfilled', verifyJob[0].Flow_Status__c);
    }

    @IsTest
    static void unitTest8(){
        Project_Milestone__c aProjectMilestone = [
            SELECT Id, Design_Queued_Milestone__c
            FROM Project_Milestone__c 
            WHERE Opportunity__r.Name = 'Palmetto Acc - Opportunity'
            LIMIT 1
        ];

        Test.startTest();
        aProjectMilestone.Contract_Signed_Milestone__c = Datetime.now();
        UPDATE aProjectMilestone;
        Test.stopTest();

        List<Job__c> verifyJob = [
            SELECT Id
            FROM Job__c
            WHERE Opportunity__r.Name = 'Palmetto Acc - Opportunity'
            AND RecordType.DeveloperName = 'Supply_Chain'
        ];
        
        System.assertEquals(1, verifyJob.size());
    }

    @IsTest
    static void unitTest9(){
        Opportunity anOpportunity = [
            SELECT Id
            FROM Opportunity
            WHERE Name = 'Palmetto Acc - Opportunity'
        ];
        
        Project_Milestone__c aProjectMilestone = [
            SELECT Id, Design_Queued_Milestone__c
            FROM Project_Milestone__c 
            WHERE Opportunity__r.Name = 'Palmetto Acc - Opportunity'
            LIMIT 1
        ];

        Test.startTest();
        aProjectMilestone.Inspection_Complete_Milestone__c = Datetime.now();
        UPDATE aProjectMilestone;
        Test.stopTest();

        List<Job__c> verifyJob = [
            SELECT Id
            FROM Job__c
            WHERE Opportunity__r.Name = 'Palmetto Acc - Opportunity'
            AND RecordType.DeveloperName = 'PTO'
        ];
        
        System.assertEquals(1, verifyJob.size());
    }

    @IsTest
    static void unitTest10(){
        Project_Milestone__c aProjectMilestone = [
            SELECT Id
            FROM Project_Milestone__c 
            WHERE Opportunity__r.Name = 'Palmetto Acc - Opportunity'
            LIMIT 1
        ];

        Opportunity anOpportunity = [
            SELECT Id
            FROM Opportunity
            WHERE Name = 'Palmetto Acc - Opportunity'
        ];

        Test.startTest();
        aProjectMilestone.Permit_Received_Milestone__c = Datetime.now();
        UPDATE aProjectMilestone;
        Test.stopTest();

        List<Case> verifyCaseList = [
            SELECT Id 
            FROM CASE
            WHERE Opportunity__r.Name = 'Palmetto Acc - Opportunity'
        ];

        System.assertEquals(2, verifyCaseList.size());
        
    }

    @IsTest
    static void unitTest11(){
        Project_Milestone__c aProjectMilestone = [
            SELECT Id
            FROM Project_Milestone__c 
            WHERE Opportunity__r.Name = 'Palmetto Acc - Opportunity'
            LIMIT 1
        ];

        Opportunity anOpportunity = [
            SELECT Id
            FROM Opportunity
            WHERE Name = 'Palmetto Acc - Opportunity'
        ];

        anOpportunity.Inverter_1__c = 'Test';
        UPDATE anOpportunity;
        
        BOM__c aBom = [
            SELECT Id
            FROM BOM__c 
            WHERE Opportunity__r.Name = 'Palmetto Acc - Opportunity'
            LIMIT 1
        ];

        Product2 aProduct = new Product2();
        aProduct.Name = 'IN-000002';
        aProduct.ProductCode = 'IN-000002';
        INSERT aProduct;

        aBom.Part_Number2__c = aProduct.Id;
        UPDATE aBom;

        Test.startTest();
        aProjectMilestone.Permit_Received_Milestone__c = Datetime.now();
        UPDATE aProjectMilestone;
        Test.stopTest();

        List<Case> verifyCaseList = [
            SELECT Id, Subject
            FROM Case
            WHERE Opportunity__r.Name = 'Palmetto Acc - Opportunity'
        ];

        System.assertEquals(3, verifyCaseList.size());
        
    }
    
    @IsTest
    static void unitTest12(){
        List<Project_Milestone__c> projectMilestones = [
            SELECT Id
            FROM Project_Milestone__c 
            WHERE Opportunity__r.Name = 'Palmetto Acc - Opportunity'
        ];
        
        Project_Milestone__c aProjectMilestone = projectMilestones[0];
        aProjectMilestone.All_Documentation_Reviewed_and_Confirmed__c = Datetime.now();
        UPDATE aProjectMilestone;
        
        Test.startTest();
        aProjectMilestone.Design_Completed_Milestone__c = Datetime.now();
        UPDATE aProjectMilestone;
        Test.stopTest();

        List<Job__c> verifyJobList = [
            SELECT Id
            FROM Job__c
            WHERE Opportunity__r.Name = 'Palmetto Acc - Opportunity'
            AND RecordType.DeveloperName = 'Interconnection'
        ];

        System.assertEquals(1, verifyJobList.size());
    }

    @IsTest
    static void testStateCertificationJobCreation(){
        List<Project_Milestone__c> projectMilestones = [
            SELECT Id
            FROM Project_Milestone__c 
            WHERE Opportunity__r.Name = 'Palmetto Acc - Opportunity'
        ];
        
        Project_Milestone__c aProjectMilestone = projectMilestones[0];
        
        Test.startTest();
        aProjectMilestone.Design_Completed_Milestone__c = Datetime.now();
        UPDATE aProjectMilestone;
        Test.stopTest();

        List<Job__c> verifyJobList = [
            SELECT Id
            FROM Job__c
            WHERE Opportunity__r.Name = 'Palmetto Acc - Opportunity'
            AND RecordType.DeveloperName = 'State_Certification'
        ];

        System.assertEquals(1, verifyJobList.size());
    }
}