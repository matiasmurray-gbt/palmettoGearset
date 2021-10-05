@isTest
public class JobHandlerTest {

    @TestSetup
    static void setup(){
        Id designSalesId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('3rd Party - Design Sales').getRecordTypeId();
        Account anAccount = TestDataFactory.createAccount('Palmetto Acc', designSalesId);
        INSERT anAccount;
        
        Id oppDesignSalesId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('3rd Party - Design Sales').getRecordTypeId();
        Opportunity anOpportunity = TestDataFactory.createOpportunity(oppDesignSalesId, 'Test Opp', anAccount.Id, '1. Appointment Set', 'Alabama');
        INSERT anOpportunity;
        
        Vendor__c aVendor = new Vendor__c();
        aVendor.Name = 'Test Vendor';
        INSERT aVendor;
        
        BOM__c aBom = new BOM__c();
        aBom.Opportunity__c = anOpportunity.Id;
        INSERT aBom;
        
        List<Job__c> jobsToInsert = new List<Job__c>();
        List<RecordType> jobRecordTypes = [
            SELECT Id, DeveloperName
            FROM RecordType
            WHERE Sobjecttype = 'Job__c'
            AND DeveloperName != 'System_Activation'
            AND IsActive = TRUE
        ];
        
        for (RecordType aRecordType : jobRecordTypes) {
            Job__c aJob = new Job__c();
            aJob.Name = 'Test Job ' + aRecordType.DeveloperName;
            aJob.Opportunity__c = anOpportunity.Id;
            aJob.RecordTypeId = aRecordType.Id;
            aJob.Automation__c = true;
            jobsToInsert.add(aJob);
        }

        INSERT jobsToInsert;
    }
    //updateBuildPartner
    @IsTest
    static void updateBuildPartner_GetVendorOnOpp(){
        TriggerConfiguration__c jobApiCall = new TriggerConfiguration__c();
        jobApiCall.Name = 'Job Assignment API Trigger';
        jobApiCall.Active__c = true;
        insert jobApiCall;
        
        Vendor__c aVendor = new Vendor__c();
        aVendor.Name = 'Test Vendor 2';
        aVendor.Stage__c = 'Active';
        INSERT aVendor;

        Job__c aJob = [
            SELECT Id, Build_Partner__c
            FROM Job__c
            WHERE Opportunity__r.Name = 'Palmetto Acc - Opportunity'
            AND RecordType.DeveloperName = 'Installation_Scheduling'
            LIMIT 1
        ];

        Test.startTest();
        aJob.Build_Partner__c = aVendor.Id;
        UPDATE aJob;
        Test.stopTest();

        Opportunity verifyOpp = [
            SELECT Id, Vendor__c
            FROM Opportunity
            WHERE Name = 'Palmetto Acc - Opportunity'
            LIMIT 1
        ];

        System.assertEquals(aJob.Build_Partner__c, verifyOpp.Vendor__c, 'Job Build Partner does not match with Opp Vendor');
    }

    //updateNoticeToProceedMilestone
    @IsTest
    static void updateJobFlowStatus_GetMilestoneUpdated(){
        Job__c aJob = [
            SELECT Id, Build_Partner__c
            FROM Job__c
            WHERE Opportunity__r.Name = 'Palmetto Acc - Opportunity'
            AND RecordType.DeveloperName = 'Financing'
            LIMIT 1
        ];

        Test.startTest();
        aJob.Flow_Status__c = 'Notice to Proceed';
        UPDATE aJob;
        Test.stopTest();
        Project_Milestone__c verifyMilestone = [
            SELECT Id, Lease_Loan_Notice_to_Proceed_Milestone__c
            FROM Project_Milestone__c 
            WHERE Opportunity__r.Name = 'Palmetto Acc - Opportunity'
            LIMIT 1
        ];
        System.assertEquals(Datetime.now().date(), verifyMilestone.Lease_Loan_Notice_to_Proceed_Milestone__c.date(), 'Date on Milestone does not match');
    }
    //updateFlowStatusOnSupplyChain
    @IsTest
    static void updateInstallationDate_GetFlowStatus(){
        Job__c aJob = [
            SELECT Id
            FROM Job__c
            WHERE Opportunity__r.Name = 'Palmetto Acc - Opportunity'
            AND RecordType.DeveloperName = 'Installation_Scheduling'
            LIMIT 1
        ];

        Test.startTest();
        aJob.Tentative_Installation_Start_Date__c = Date.today();
        UPDATE aJob;
        Test.stopTest();

        Job__c verifyJob = [
            SELECT Id, Flow_Status__c
            FROM Job__c
            WHERE Opportunity__r.Name = 'Palmetto Acc - Opportunity'
            AND RecordType.DeveloperName = 'Supply_Chain'
            LIMIT 1
        ];

        System.assertEquals('Start Date for Bulk Materials Order Queued', verifyJob.Flow_Status__c);
    }
    //updateFlowStatusOnSupplyChain3
    @IsTest
    static void updateInstallationDate_GetFlowStatus2(){
        Job__c aJob = [
            SELECT Id
            FROM Job__c
            WHERE Opportunity__r.Name = 'Palmetto Acc - Opportunity'
            AND RecordType.DeveloperName = 'Installation_Scheduling'
            LIMIT 1
        ];

        Test.startTest();
        aJob.Installation_Start_Date__c = Date.today();
        UPDATE aJob;
        Test.stopTest();

        Job__c verifyJob = [
            SELECT Id, Flow_Status__c
            FROM Job__c
            WHERE Opportunity__r.Name = 'Palmetto Acc - Opportunity'
            AND RecordType.DeveloperName = 'Supply_Chain'
            LIMIT 1
        ];

        System.assertEquals('Start Date for Materials Delivery Committed', verifyJob.Flow_Status__c);
    }

    //updateFlowStatusOnSupplyChain3
    @IsTest
    static void updateInstallationDate_GetFlowStatus3(){
        Job__c aJob = [
            SELECT Id
            FROM Job__c
            WHERE Opportunity__r.Name = 'Palmetto Acc - Opportunity'
            AND RecordType.DeveloperName = 'Installation_Scheduling'
            LIMIT 1
        ];

        aJob.Installation_Start_Date__c = Date.today();
        UPDATE aJob;

        Test.startTest();
        aJob.Installation_Reschedule_Reason__c = 'Customer requested';
        aJob.Installation_Start_Date__c = Date.today().addDays(1);
        UPDATE aJob;
        Test.stopTest();

        Job__c verifyJob = [
            SELECT Id, Flow_Status__c
            FROM Job__c
            WHERE Opportunity__r.Name = 'Palmetto Acc - Opportunity'
            AND RecordType.DeveloperName = 'Supply_Chain'
            LIMIT 1
        ];

        System.assertEquals('Materials Delivery Exception', verifyJob.Flow_Status__c);
    }

    //updateFieldsonOpp
    @IsTest
    static void updateSupplyChainJob_GetOppFieldUpdated(){
        Job__c aJob = [
            SELECT Id
            FROM Job__c
            WHERE Opportunity__r.Name = 'Palmetto Acc - Opportunity'
            AND RecordType.DeveloperName = 'Supply_Chain'
            LIMIT 1
        ];

        Test.startTest();
        aJob.Fulfillment_Method__c = 'Will Call';
        UPDATE aJob;
        Test.stopTest();

        Opportunity verifyOpp = [
            SELECT Id, Fulfillment_Method__c
            FROM Opportunity
            WHERE Name = 'Palmetto Acc - Opportunity'
            LIMIT 1
        ];
        
        System.assertEquals(aJob.Fulfillment_Method__c, verifyOpp.Fulfillment_Method__c);
    }

    //updateInterconnectionMilestones

    @IsTest
    static void updateInterconnectionJob_GetMilestoneUpdated(){
        Job__c aJob = [
            SELECT Id, Resubmitted_Date__c
            FROM Job__c
            WHERE Opportunity__r.Name = 'Palmetto Acc - Opportunity'
            AND RecordType.DeveloperName = 'Interconnection'
            LIMIT 1
        ];

        Test.startTest();
        aJob.Flow_Status__c = 'Submitted';
        UPDATE aJob;
        Test.stopTest();


        Project_Milestone__c aProjectMilestone = [
            SELECT Id, Interconnection_Application_Submitted__c
            FROM Project_Milestone__c 
            WHERE Opportunity__r.Name = 'Palmetto Acc - Opportunity'
            LIMIT 1
        ];

        System.assertEquals(Datetime.now().date(), aProjectMilestone.Interconnection_Application_Submitted__c.date());
    }

    //updateInstallationMilestone
    @IsTest
    static void updateJobFlowStatus_GetInstallationReadyOnMilestone(){
        Job__c aJob = [
            SELECT Id, Build_Partner__c
            FROM Job__c
            WHERE Opportunity__r.Name = 'Palmetto Acc - Opportunity'
            AND RecordType.DeveloperName = 'Installation_Scheduling'
            LIMIT 1
        ];

        Test.startTest();
        aJob.Flow_Status__c = 'New- Pending Scheduling';
        UPDATE aJob;
        Test.stopTest();

        Project_Milestone__c verifyMilestone = [
            SELECT Id, Installation_Ready_Milestone__c
            FROM Project_Milestone__c 
            WHERE Opportunity__r.Name = 'Palmetto Acc - Opportunity'
            LIMIT 1
        ];
        
        System.assertEquals(Datetime.now().date(), verifyMilestone.Installation_Ready_Milestone__c.date());
    }

    //updatePTOMilestone
    @IsTest
    static void updateJobFlowStatus_GetPTOSubmittedOnMilestone(){
        

        Job__c aJob = [
            SELECT Id, Build_Partner__c
            FROM Job__c
            WHERE Opportunity__r.Name = 'Palmetto Acc - Opportunity'
            AND RecordType.DeveloperName = 'PTO'
            LIMIT 1
        ];
        
        Test.startTest();
        aJob.Flow_Status__c = 'Submitted';
        UPDATE aJob;
        Test.stopTest();

        Project_Milestone__c verifyMilestone = [
            SELECT Id, PTO_Submitted_Milestone__c
            FROM Project_Milestone__c 
            WHERE Opportunity__r.Name = 'Palmetto Acc - Opportunity'
            LIMIT 1
        ];
        
        System.assertEquals(Datetime.now().date(), verifyMilestone.PTO_Submitted_Milestone__c.date());
        
    }

    //updateFinancingMilestone

    @IsTest
    static void updateJobFlowStatus_GetLeasLoanM1OnMilestone(){
        Job__c aJob = [
            SELECT Id, Build_Partner__c
            FROM Job__c
            WHERE Opportunity__r.Name = 'Palmetto Acc - Opportunity'
            AND RecordType.DeveloperName = 'Financing'
            LIMIT 1
        ];
        
        Test.startTest();
        aJob.Flow_Status__c = 'M1 - Approved';
        UPDATE aJob;
        Test.stopTest();

        Project_Milestone__c verifyMilestone = [
            SELECT Id, Lease_Loan_M1_Approval_Milestone__c
            FROM Project_Milestone__c 
            WHERE Opportunity__r.Name = 'Palmetto Acc - Opportunity'
            LIMIT 1
        ];
        
        System.assertEquals(Datetime.now().date(), verifyMilestone.Lease_Loan_M1_Approval_Milestone__c.date());
    }

    @IsTest
    static void updateJobFlowStatus_GetInspectionScheduledOnMilestone(){
        Job__c aJob = [
            SELECT Id, Build_Partner__c
            FROM Job__c
            WHERE Opportunity__r.Name = 'Palmetto Acc - Opportunity'
            AND RecordType.DeveloperName = 'Inspection'
            LIMIT 1
        ];
        
        Test.startTest();
        aJob.Flow_Status__c = 'Inspection Scheduled';
        UPDATE aJob;
        Test.stopTest();

        Project_Milestone__c verifyMilestone = [
            SELECT Id, Inspection_Scheduled_Milestone__c
            FROM Project_Milestone__c 
            WHERE Opportunity__r.Name = 'Palmetto Acc - Opportunity'
            LIMIT 1
        ];
        
        System.assertEquals(Datetime.now().date(), verifyMilestone.Inspection_Scheduled_Milestone__c.date());
    }

    //preventPermitReceivedFlowStatus
    @IsTest
    static void updateJobFlowStatus_GetError(){
        Job__c aJob = [
            SELECT Id, Build_Partner__c
            FROM Job__c
            WHERE Opportunity__r.Name = 'Palmetto Acc - Opportunity'
            AND RecordType.DeveloperName = 'Permitting'
            LIMIT 1
        ];
        
        Test.startTest();
        aJob.Flow_Status__c = 'Permit Received';
        Database.SaveResult updateJob = Database.update(aJob, false);
        Test.stopTest();

        System.assertEquals(1, updateJob.getErrors().size());
    }

    //preventPermittingJob
    @IsTest
    static void insertPermittingJob_GetError(){
        Opportunity anOpportunity = [
            SELECT Id
            FROM Opportunity
            WHERE Name = 'Palmetto Acc - Opportunity'
            LIMIT 1
        ];

        Test.startTest();
        Id permittingId = Schema.SObjectType.Job__c.getRecordTypeInfosByDeveloperName().get('Permitting').getRecordTypeId();    
        Job__c aJob = new Job__c();
        aJob.Name = 'Test Job Permitting';
        aJob.Opportunity__c = anOpportunity.Id;
        aJob.RecordTypeId = permittingId;
        Database.SaveResult insertJob = Database.insert(aJob, false);
        Test.stopTest();
        
        System.assertEquals(1, insertJob.getErrors().size());
    }

    //preventSiteApprovalJob
    @IsTest
    static void insertSiteApprovalJob_GetError(){
        Opportunity anOpportunity = [
            SELECT Id
            FROM Opportunity
            WHERE Name = 'Palmetto Acc - Opportunity'
            LIMIT 1
        ];

        Test.startTest();
        Id siteApprovalId = Schema.SObjectType.Job__c.getRecordTypeInfosByDeveloperName().get('Design').getRecordTypeId();    
        Job__c aJob = new Job__c();
        aJob.Name = 'Test Job Design';
        aJob.Opportunity__c = anOpportunity.Id;
        aJob.RecordTypeId = siteApprovalId;
        Database.SaveResult insertJob = Database.insert(aJob, false);
        Test.stopTest();
        
        System.assertEquals(1, insertJob.getErrors().size());
    }

    //updatePermittingMilestone
    @IsTest
    static void updateJobFlowStatus_GetPermitSubmittedOnMilestone(){
        Job__c aJob = [
            SELECT Id
            FROM Job__c
            WHERE Opportunity__r.Name = 'Palmetto Acc - Opportunity'
            AND RecordType.DeveloperName = 'Permitting'
            LIMIT 1
        ];
        
        Test.startTest();
        aJob.Flow_Status__c = 'Permit Submitted';
        UPDATE aJob;
        Test.stopTest();

        Project_Milestone__c verifyMilestone = [
            SELECT Id, Permit_Submitted_Milestone__c
            FROM Project_Milestone__c 
            WHERE Opportunity__r.Name = 'Palmetto Acc - Opportunity'
            LIMIT 1
        ];
        
        System.assertEquals(Datetime.now().date(), verifyMilestone.Permit_Submitted_Milestone__c.date());
    }

    //updateDesignCompletedMilestone
    @IsTest
    static void updateJobFlowStatus_GetDesignCompletedOnMilestone(){
        Job__c aJob = [
            SELECT Id
            FROM Job__c
            WHERE Opportunity__r.Name = 'Palmetto Acc - Opportunity'
            AND RecordType.DeveloperName = 'Design'
            LIMIT 1
        ];
        
        Test.startTest();
        aJob.Flow_Status__c = 'Site Approved';
        UPDATE aJob;
        Test.stopTest();

        Project_Milestone__c verifyMilestone = [
            SELECT Id, Design_Completed_Milestone__c
            FROM Project_Milestone__c 
            WHERE Opportunity__r.Name = 'Palmetto Acc - Opportunity'
            LIMIT 1
        ];
        
        System.assertEquals(Datetime.now().date(), verifyMilestone.Design_Completed_Milestone__c.date());
    }

    //updateEnergyBillMilestone
    @IsTest
    static void updateJobUsageVerification_GetEnergyOnMilestone(){
       Job__c aJob = [
           SELECT Id
           FROM Job__c
           WHERE Opportunity__r.Name = 'Palmetto Acc - Opportunity'
           AND RecordType.DeveloperName = 'Document_Verification'
           LIMIT 1
       ];
        
        Test.startTest();
        aJob.Usage_Verification_Complete__c = Date.today();
        UPDATE aJob;
        Test.stopTest();    
        Project_Milestone__c verifyMilestone = [
            SELECT Id, Energy_Bill_checked__c, Energy_Usage_Verification_Milestone__c
            FROM Project_Milestone__c 
            WHERE Opportunity__r.Name = 'Palmetto Acc - Opportunity'
            LIMIT 1
        ];
        
        System.assertEquals(Datetime.now().date(), verifyMilestone.Energy_Bill_checked__c.date());
        System.assertEquals(Datetime.now().date(), verifyMilestone.Energy_Usage_Verification_Milestone__c.date());
     }

    //updateSurveyCompleteMilestone
    @IsTest
    static void updateJobFlowStatus_GetSurveyFieldsOnMilestone(){
        Job__c aJob = [
            SELECT Id
            FROM Job__c
            WHERE Opportunity__r.Name = 'Palmetto Acc - Opportunity'
            AND RecordType.DeveloperName = 'SiteSurvey'
            LIMIT 1
        ];
        
        Test.startTest();
        aJob.Flow_Status__c = 'Survey Complete';
        UPDATE aJob;
        Test.stopTest();

        Project_Milestone__c verifyMilestone = [
            SELECT Id, Survey_Complete_Confirmed__c, Site_Survey_Completed_Milestone__c
            FROM Project_Milestone__c 
            WHERE Opportunity__r.Name = 'Palmetto Acc - Opportunity'
            LIMIT 1
        ];
        
        System.assertEquals(Datetime.now().date(), verifyMilestone.Survey_Complete_Confirmed__c.date());
        System.assertEquals(Datetime.now().date(), verifyMilestone.Site_Survey_Completed_Milestone__c.date());
    }

    //updateOppStage
    @IsTest
    static void updateJobFlowStatus_GetOppAndMilestoneUpdated(){
        Job__c aJob = [
            SELECT Id
            FROM Job__c
            WHERE Opportunity__r.Name = 'Palmetto Acc - Opportunity'
            AND RecordType.DeveloperName = 'Business_Processing'
            LIMIT 1
        ];
        
        Test.startTest();
        aJob.Flow_Status__c = 'Contract Processing Completed';
        UPDATE aJob;
        Test.stopTest();    

        Opportunity verifyOpp = [
           SELECT Id, StageName
           FROM Opportunity
           WHERE Name = 'Palmetto Acc - Opportunity'
           LIMIT 1
        ];

        Project_Milestone__c verifyMilestone = [
            SELECT Id, Contract_Received_Milestone__c, Contract_Received_Confirmed_Milestone__c
            FROM Project_Milestone__c 
            WHERE Opportunity__r.Name = 'Palmetto Acc - Opportunity'
            LIMIT 1
        ];

        System.assertEquals('7. Contract Received', verifyOpp.StageName);
        System.assertEquals(Datetime.now().date(), verifyMilestone.Contract_Received_Milestone__c.date());
        //System.assertEquals(Datetime.now().date(), verifyMilestone.Contract_Received_Confirmed_Milestone__c.date());
    }

    //updateOppData
    @IsTest
    static void updateJobHOA_GetOppHOA(){
        Job__c aJob = [
            SELECT Id
            FROM Job__c
            WHERE Opportunity__r.Name = 'Palmetto Acc - Opportunity'
            AND RecordType.DeveloperName = 'HOA'
            LIMIT 1
        ];

        Test.startTest();
        aJob.HOA_Approval_Not_Required__c = 'HO Bypass';
        UPDATE aJob;
        Test.stopTest();  

        Opportunity verifyOpp = [
           SELECT Id, HOA_Approval_Not_Required__c
           FROM Opportunity
           WHERE Name = 'Palmetto Acc - Opportunity'
           LIMIT 1
        ];

        System.assertEquals(aJob.HOA_Approval_Not_Required__c, verifyOpp.HOA_Approval_Not_Required__c);
    }

    //changeFlowStatusOnFinOpsFromDV
    @IsTest
    static void updateJobFinancier_GetFinancingJobFlowStatus(){
        Job__c aJob = [
            SELECT Id
            FROM Job__c
            WHERE Opportunity__r.Name = 'Palmetto Acc - Opportunity'
            AND RecordType.DeveloperName = 'Document_Verification'
            LIMIT 1
        ];

        Test.startTest();
        aJob.Financier_M0_Submitted__c = true;
        UPDATE aJob;
        Test.stopTest();  

        Job__c verifyJob = [
            SELECT Id, Flow_Status__c
            FROM Job__c
            WHERE Opportunity__r.Name = 'Palmetto Acc - Opportunity'
            AND RecordType.DeveloperName = 'Financing'
            LIMIT 1
        ];

        System.assertEquals('M0 - Submitted', verifyJob.Flow_Status__c);
    }

    //changeFlowStatusOnFinOps
    @IsTest
    static void updateJobFlowStatus_GetFinancingJobFlowStatus(){
        Job__c aJob = [
            SELECT Id
            FROM Job__c
            WHERE Opportunity__r.Name = 'Palmetto Acc - Opportunity'
            AND RecordType.DeveloperName = 'Job_Close_Out'
            LIMIT 1
        ];

        Test.startTest();
        aJob.Flow_Status__c = 'QC Approved - Field Remedies Needed';
        UPDATE aJob;
        Test.stopTest();  

        Job__c verifyJob = [
            SELECT Id, Flow_Status__c
            FROM Job__c
            WHERE Opportunity__r.Name = 'Palmetto Acc - Opportunity'
            AND RecordType.DeveloperName = 'Financing'
            LIMIT 1
        ];

        System.assertEquals('M1 - Pending Submittal', verifyJob.Flow_Status__c);
    }

    //rejectJCOJob
    @IsTest
    static void updateJobFlowStatus_GetJCOFlowStatus(){
        Job__c aJob = [
            SELECT Id
            FROM Job__c
            WHERE Opportunity__r.Name = 'Palmetto Acc - Opportunity'
            AND RecordType.DeveloperName = 'Financing'
            LIMIT 1
        ];

        Test.startTest();
        aJob.Customer_Signature__c = Date.today();
        aJob.Other__c = Date.today();
        aJob.Contract_Loan_Match__c = Date.today();
        aJob.Blocker_Documentation_Notes__c = 'Text';
        aJob.Layout_Design__c = Date.today();
        aJob.Revised_Work_Order__c = Date.today();
        aJob.Shade_Report__c = Date.today();
        aJob.Design_Other__c = Date.today();
        aJob.Quote__c = Date.today();
        aJob.Flow_Status__c = 'M1 - Kickback';
        aJob.Punchlist_Items__c = Date.today();
        aJob.Field_Other__c = Date.today();
        aJob.Field_Photos__c = Date.today();
        aJob.Flow_Status__c = 'M1 - Kickback';
        aJob.Design_Notes__c = 'Text';
        UPDATE aJob;
        Test.stopTest();  

        Job__c verifyJob = [
            SELECT Id, Flow_Status__c
            FROM Job__c
            WHERE Opportunity__r.Name = 'Palmetto Acc - Opportunity'
            AND RecordType.DeveloperName = 'Job_Close_Out'
            LIMIT 1
        ];

        System.assertEquals('Rejected - Pending Correction', verifyJob.Flow_Status__c);
    }

    //closeJCOJob
    @IsTest
    static void updateJobFlowStatus_GetJCOClosed(){
        Job__c aJob = [
            SELECT Id
            FROM Job__c
            WHERE Opportunity__r.Name = 'Palmetto Acc - Opportunity'
            AND RecordType.DeveloperName = 'Financing'
            LIMIT 1
        ];

        Test.startTest();
        aJob.Job_Status__c = 'Closed';
        UPDATE aJob;
        Test.stopTest();  

        Job__c verifyJob = [
            SELECT Id, Job_Status__c
            FROM Job__c
            WHERE Opportunity__r.Name = 'Palmetto Acc - Opportunity'
            AND RecordType.DeveloperName = 'Job_Close_Out'
            LIMIT 1
        ];

        System.assertEquals('Closed', verifyJob.Job_Status__c);
    }

    //updateDocumentationNotes
    @IsTest
    static void updateJobDocNotes_GetOppNotesUpdated(){
        Job__c aJob = [
            SELECT Id
            FROM Job__c
            WHERE Opportunity__r.Name = 'Palmetto Acc - Opportunity'
            AND RecordType.DeveloperName = 'Financing'
            LIMIT 1
        ];

        Test.startTest();
        aJob.Documentation_Notes__c = 'Test';
        UPDATE aJob;
        Test.stopTest();  

        Opportunity verifyOpp = [
           SELECT Id, Customer_Satisfaction_Install_Notes__c
           FROM Opportunity
           WHERE Name = 'Palmetto Acc - Opportunity'
           LIMIT 1
        ];

        System.assert(verifyOpp.Customer_Satisfaction_Install_Notes__c != null);
    }
    /*
    //updateAppNumber
    @IsTest
    static void updateIncentivesJob_GetJobUpdated(){
        Job__c aJob = [
            SELECT Id
            FROM Job__c
            WHERE Opportunity__r.Name = 'Palmetto Acc - Opportunity'
            AND RecordType.DeveloperName = 'Incentives'
            LIMIT 1
        ];

        Test.startTest();
        aJob.App__c = 'Test';
        UPDATE aJob;
        Test.stopTest();

        Job__c verifyJob = [
            SELECT Id, App__c
            FROM Job__c
            WHERE Opportunity__r.Name = 'Palmetto Acc - Opportunity'
            AND RecordType.DeveloperName = 'Incentives'
            LIMIT 1
        ];

        System.assertEquals(ajob.App__c, verifyJob.App__c);
    }
    */
    //updateDocumentVerificationMilestone
    @IsTest
    static void updateDocVerificationJob_GetMilestoneUpdated(){
        Job__c aJob = [
            SELECT Id
            FROM Job__c
            WHERE Opportunity__r.Name = 'Palmetto Acc - Opportunity'
            AND RecordType.DeveloperName = 'Document_Verification'
            LIMIT 1
        ];

        Test.startTest();
        aJob.ICA_Docs__c = Date.today();
        aJob.Utility_Bill_Upload_within_2_months__c = Date.today();
        aJob.HOA_Disclosure__c = Date.today();
        aJob.Flow_Status__c = 'Document Verification - Document Reviewed CRC completed';
        UPDATE aJob;
        Test.stopTest();

        Project_Milestone__c verifyMilestone = [
            SELECT Id, ICA_Documents_On_File_Date_Milestone__c, Utility_Bill_on_File_Date_Milestone__c, 
            HOA_Disclosure_On_File_Date_Milestone__c, All_Documentation_Reviewed_and_Confirmed__c
            FROM Project_Milestone__c 
            WHERE Opportunity__r.Name = 'Palmetto Acc - Opportunity'
            LIMIT 1
        ];

        System.assertEquals(Datetime.now().date(), verifyMilestone.ICA_Documents_On_File_Date_Milestone__c.date());
        System.assertEquals(Datetime.now().date(), verifyMilestone.Utility_Bill_on_File_Date_Milestone__c.date());
        System.assertEquals(Datetime.now().date(), verifyMilestone.HOA_Disclosure_On_File_Date_Milestone__c.date());
        System.assertEquals(Datetime.now().date(), verifyMilestone.All_Documentation_Reviewed_and_Confirmed__c.date());
    }

    
    //createJobRecord
    /*
    @IsTest
    static void insertOppAndJobs_GetJobsUpdated(){
        Id designSalesId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('3rd Party - Design Sales').getRecordTypeId();
        Account anAccount = TestDataFactory.createAccount('Palmetto Acc 2', designSalesId);
        INSERT anAccount;
        
        Id oppDesignSalesId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('3rd Party - Design Sales').getRecordTypeId();
        Opportunity anOpportunity = TestDataFactory.createOpportunity(oppDesignSalesId, 'Test Opp', anAccount.Id, '1. Appointment Set', 'New Jersey');
        INSERT anOpportunity;

        List<RecordType> jobRecordTypes = [
            SELECT Id, DeveloperName
            FROM RecordType
            WHERE Sobjecttype = 'Job__c'
            AND DeveloperName IN ('Design', 'Document_Verification')
        ];

        List<Job__c> jobsToInsert = new List<Job__c>();

        for (RecordType aRecordType : jobRecordTypes) {
            Job__c aJob = new Job__c();
            aJob.Name = 'Test Job ' + aRecordType.DeveloperName;
            aJob.Opportunity__c = anOpportunity.Id;
            aJob.RecordTypeId = aRecordType.Id;
            aJob.Automation__c = true;
            if(aRecordType.DeveloperName == 'Design') {
                aJob.Flow_Status__c = 'Final Review';
            }
            if(aRecordType.DeveloperName == 'Document_Verification') {
                aJob.Utility_Bill_Upload_within_2_months__c = Date.today();
                aJob.Usage_Verification_Complete__c = Date.today();
                aJob.ICA_Docs__c = Date.today();
            }
            jobsToInsert.add(aJob);
        }

        Test.startTest();
        INSERT jobsToInsert;
        Test.stopTest();
        
        List<Job__c> verifyJobs = [
            SELECT Id, Flow_Status__c
            FROM Job__c
            WHERE Opportunity__c = :anOpportunity.Id
            AND RecordType.DeveloperName = 'Interconnection'
        ];

        System.assertEquals(1, verifyJobs.size());
        System.assertEquals('Pending Submission', verifyJobs[0].Flow_Status__c);
    }
    */

    //populateContractReceived
    @IsTest
    static void insertFinancingJob_GetJobUpdated(){
        Opportunity anOpportunity = [
            SELECT Id, HOA_Approval_Not_Required__c
            FROM Opportunity
            WHERE Name = 'Palmetto Acc - Opportunity'
            LIMIT 1
        ];

        Job__c businessProcessingJob = [
            SELECT Id
            FROM Job__c
            WHERE Opportunity__c = :anOpportunity.Id
            AND RecordType.DeveloperName = 'Business_Processing'
            LIMIT 1
        ];
        businessProcessingJob.Days_Since_Contract_Received__c = 2;
        businessProcessingJob.Loan_Term__c = 'Test';
        businessProcessingJob.APR__c = 'Test';
        UPDATE businessProcessingJob;

        Test.startTest();
        Id financingId = Schema.SObjectType.Job__c.getRecordTypeInfosByDeveloperName().get('Financing').getRecordTypeId();    
        Job__c aJob = new Job__c();
        aJob.Name = 'Job Financing';
        aJob.Opportunity__c = anOpportunity.Id;
        aJob.RecordTypeId = financingId;
        aJob.Automation__c = true;
        INSERT aJob;
        Test.stopTest();

        Job__c verifyJob = [
            SELECT Id, Days_Since_Contract_Received__c, Loan_Term__c, APR__c
            FROM Job__c
            WHERE Opportunity__c = :anOpportunity.Id
            AND RecordType.DeveloperName = 'Financing'
            AND Name = 'Job Financing'
            LIMIT 1
        ];

        System.assertEquals(businessProcessingJob.Days_Since_Contract_Received__c, verifyJob.Days_Since_Contract_Received__c);
        System.assertEquals(businessProcessingJob.Loan_Term__c, verifyJob.Loan_Term__c);
        System.assertEquals(businessProcessingJob.APR__c, verifyJob.APR__c);
    }

    @IsTest
    static void updateSiteApprovalJob_GetInterconnectionCreated(){
        List<Account> accounts = [
            SELECT Id
            FROM Account
        ];
        Account anAccount = accounts[0];

        Id oppDesignSalesId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('3rd Party - Design Sales').getRecordTypeId();
        Opportunity anOpportunity = TestDataFactory.createOpportunity(oppDesignSalesId, 'Test Opp', anAccount.Id, '1. Appointment Set', 'Alabama');
        INSERT anOpportunity;

        List<Project_Milestone__c> projectMilestones = [
            SELECT ID
            FROM Project_Milestone__c
            WHERE Opportunity__c = :anOpportunity.Id
        ];
        Project_Milestone__c aProjectMilestone = projectMilestones[0];
        aProjectMilestone.All_Documentation_Reviewed_and_Confirmed__c = Date.today();
        UPDATE aProjectMilestone;

        Job__c siteApprovalJob = new Job__c();
        siteApprovalJob.Name = 'Test';
        siteApprovalJob.Opportunity__c = anOpportunity.Id;
        siteApprovalJob.Automation__c = true;
        INSERT siteApprovalJob;
        
        Test.startTest();
        siteApprovalJob.Flow_Status__c = 'Professional Engineering Stamp';
        UPDATE siteApprovalJob;
        Test.stopTest();

        List<Job__c> verifyJob = [
            SELECT Id
            FROM Job__c
            WHERE Opportunity__c = :anOpportunity.Id
            AND RecordType.DeveloperName = 'Interconnection'
        ];

        System.assertEquals(1, verifyJob.size());
    }

        //populateContractReceivedConfirmedMilestone
        @IsTest
        static void updateJobFlowStatus_GetContractReceivedMilestone(){
            Job__c aJob = [
                SELECT Id
                FROM Job__c
                WHERE Opportunity__r.Name = 'Palmetto Acc - Opportunity'
                AND RecordType.DeveloperName = 'Document_Verification'
                LIMIT 1
            ];
            
            Test.startTest();
            aJob.Flow_Status__c = 'Document Verification - Document Reviewed CRC Completed';
            UPDATE aJob;
            Test.stopTest();    
    
            Project_Milestone__c verifyMilestone = [
                SELECT Id, Contract_Received_Confirmed_Milestone__c
                FROM Project_Milestone__c 
                WHERE Opportunity__r.Name = 'Palmetto Acc - Opportunity'
                LIMIT 1
            ];
    
            System.assertEquals(Datetime.now().date(), verifyMilestone.Contract_Received_Confirmed_Milestone__c.date());
        }
}