@isTest
public with sharing class CommissionTrackerControllerLgtngTest {

    @isTest
    public static void getMilestonesData() {
		
		List<String> selectedAllMilestones = new List<String>{'M1', 'M2', 'M3', 'Clawbacks'};
		List<String> selectedProviders = new List<String>();
		String mode = null;
		Date fromDate = null;
		Date toDate = null;
		Boolean showPaidMilestones = false;

		CommissionTrackerControllerLgtng.DashboardData data = 
			CommissionTrackerControllerLgtng.getMilestonesData(selectedAllMilestones,selectedProviders,mode,fromDate,toDate,showPaidMilestones);

		System.assertNotEquals(null, data.data);
		System.assertEquals(1, data.thirdPartyProviders.size());
    }
	@isTest
    public static void getM1Data() {
		List<String> selectedAllMilestones = new List<String>{'M1'};
		List<String> selectedProviders = new List<String>();
		String mode = 'Commission to be processed';
		Date fromDate = System.today().addDays(-7);
		Date toDate = System.today();
		Boolean showPaidMilestones = false;

		CommissionTrackerControllerLgtng.DashboardData data = 
			CommissionTrackerControllerLgtng.getMilestonesData(selectedAllMilestones,selectedProviders,mode,fromDate,toDate,showPaidMilestones);

		System.assertNotEquals(null, data.data);
		System.assertEquals(1, data.thirdPartyProviders.size());
    }

	@isTest
	public static void getM2Data() {
		
		List<String> selectedAllMilestones = new List<String>{'M2'};
		List<String> selectedProviders = new List<String>();
		String mode = 'Commission to be processed';
		Date fromDate = System.today().addDays(-7);
		Date toDate = System.today();
		Boolean showPaidMilestones = false;

		CommissionTrackerControllerLgtng.DashboardData data = 
			CommissionTrackerControllerLgtng.getMilestonesData(selectedAllMilestones,selectedProviders,mode,fromDate,toDate,showPaidMilestones);

		System.assertNotEquals(null, data.data);
		System.assertEquals(1, data.thirdPartyProviders.size());
    }
	@isTest
	public static void getM3Data() {
		
		List<String> selectedAllMilestones = new List<String>{'M3'};
		List<String> selectedProviders = new List<String>();
		String mode = 'Commission to be processed';
		Date fromDate = System.today().addDays(-7);
		Date toDate = System.today();
		Boolean showPaidMilestones = false;

		CommissionTrackerControllerLgtng.DashboardData data = 
			CommissionTrackerControllerLgtng.getMilestonesData(selectedAllMilestones,selectedProviders,mode,fromDate,toDate,showPaidMilestones);

		System.assertNotEquals(null, data.data);
		System.assertEquals(1, data.thirdPartyProviders.size());
    }
	@isTest
	public static void getClawbackData() {
		
		List<String> selectedAllMilestones = new List<String>{'Clawbacks'};
		List<String> selectedProviders = new List<String>();
		String mode = 'Commission to be processed';
		Date fromDate = System.today().addDays(-7);
		Date toDate = System.today();
		Boolean showPaidMilestones = false;

		CommissionTrackerControllerLgtng.DashboardData data = 
			CommissionTrackerControllerLgtng.getMilestonesData(selectedAllMilestones,selectedProviders,mode,fromDate,toDate,showPaidMilestones);

		System.assertNotEquals(null, data.data);
		System.assertEquals(1, data.thirdPartyProviders.size());
    }

    @isTest
    public static void processMilestones() {

		List<Id> commissionsListIds = new List<Id>();

		commissionsListIds.add(commission_1.Id);
		commissionsListIds.add(commission_2.Id);
		commissionsListIds.add(commission_3.Id);
		commissionsListIds.add(commission_4.Id);
		commissionsListIds.add(commission_5.Id);
		commissionsListIds.add(commission_6.Id);

		CommissionTrackerControllerLgtng.CommissionsWrapper result = CommissionTrackerControllerLgtng.processMilestones(commissionsListIds);

		System.assertEquals('OK', result.message);
		System.assertEquals(null, result.Commissions);
    }
	@isTest
    public static void failToProcessMilestones() {

		List<Id> commissionsListIds = new List<Id>();

		CommissionTrackerControllerLgtng.CommissionsWrapper result = CommissionTrackerControllerLgtng.processMilestones(commissionsListIds);

		System.assertEquals('Commission/s couldn\'t be updated. Because either all selected commissions are already processed for their current milestone or finance tool and initial payment doesn\'t meet the criteria', result.message);
		System.assertEquals(null, result.Commissions);
    }
	@isTest
    public static void successButSomeCommissionsFailtedToProcessMilestones() {

		List<Id> commissionsListIds = new List<Id>();

		commissionsListIds.add(commission_7.Id);
		commissionsListIds.add(commission_8.Id);

		CommissionTrackerControllerLgtng.CommissionsWrapper result = CommissionTrackerControllerLgtng.processMilestones(commissionsListIds);

		System.assertEquals('OK', result.message);
		System.assertEquals(1, result.Commissions.size());
    }

    @isTest
    public static void addPaidDateToCommissions() {

		List<Id> commissionsListIds = new List<Id>();

		commissionsListIds.add(commission_7.Id);
		commissionsListIds.add(commission_1.Id);
		commissionsListIds.add(commission_3.Id);
		commissionsListIds.add(commission_4.Id);

		Date aDate = System.today();

		CommissionTrackerControllerLgtng.CommissionsWrapper result = CommissionTrackerControllerLgtng.addPaidDateToCommissions(commissionsListIds, aDate);

		System.assertEquals('OK', result.message);
		System.assertEquals(3, result.Commissions.size());
    }

    @isTest
    public static void unprocessMilestones() {

		List<Id> commissionsListIds = new List<Id>();

		commissionsListIds.add(commission_6.Id);
		commissionsListIds.add(commission_7.Id);

		CommissionTrackerControllerLgtng.CommissionsWrapper result = CommissionTrackerControllerLgtng.unprocessCommissions(commissionsListIds);

		System.assertEquals('OK', result.message);
    }

    @isTest
    public static void unproccessNegatives() {
		
		List<CommissionTrackerControllerLgtng.ProviderCommissionWrapper> providerWrapperList = new List<CommissionTrackerControllerLgtng.ProviderCommissionWrapper>();
		List<Commission__c> commissionList = new List<Commission__c>{commission_1, commission_2, commission_3};
		CommissionTrackerControllerLgtng.ProviderCommissionWrapper providerWrapper1 = new CommissionTrackerControllerLgtng.ProviderCommissionWrapper();
		providerWrapper1.CommissionsList = commissionList;
		providerWrapperList.add(providerWrapper1);

		CommissionTrackerControllerLgtng.unproccessNegatives(providerWrapperList);
		
    }

    @isTest
    public static void getEmailsAndContactsFromProvider() {

		List<String> accountList = new List<String>{'Harbor Energy'};

		List<CommissionTrackerControllerLgtng.ProviderEmailWrapper> providerEmailWrapper = 
			CommissionTrackerControllerLgtng.getEmailsAndContactsFromProvider(accountList);
		
		System.assertEquals('Harbor Energy', providerEmailWrapper[0].ProviderName);
		System.assertEquals('Active', providerEmailWrapper[0].ProviderStatus);
		System.assertEquals('Test O1', providerEmailWrapper[0].ContactNames);
		System.assertEquals('test@testing.com', providerEmailWrapper[0].ContactEmails);
    }

    @isTest
    public static void sendEmailToProvidersWithoutCommissions() {

		List<CommissionTrackerControllerLgtng.SendEmailWrapper> providersList = new List<CommissionTrackerControllerLgtng.SendEmailWrapper>();
		List<CommissionTrackerControllerLgtng.SendEmailWrapper> providersWithoutCommissions = new List<CommissionTrackerControllerLgtng.SendEmailWrapper>();
		CommissionTrackerControllerLgtng.SendEmailWrapper wrapper1 = new CommissionTrackerControllerLgtng.SendEmailWrapper();
		wrapper1.CommissionResult = 9999;
        wrapper1.ProviderName = 'Harbor Energy';
        wrapper1.ProviderStatus = 'Active';
        wrapper1.ContactEmails = 'test@testing.com';
        wrapper1.PaidMilestone = true;
        wrapper1.ContactNames = 'Test O1';
		providersWithoutCommissions.add(wrapper1);

		List<String> selectedAllmilestone = new List<String>{'M1','M2','M3','Clawbacks'};

		Date fromDate = System.today().addDays(-10);
		Date toDate = System.today();
		
		String result = CommissionTrackerControllerLgtng.sendEmailToProviders(selectedAllmilestone,fromDate,toDate,providersList,providersWithoutCommissions);

		System.assertEquals('OK', result);
    }
	@isTest
    public static void sendEmailToProviders() {

		List<CommissionTrackerControllerLgtng.SendEmailWrapper> providersList = new List<CommissionTrackerControllerLgtng.SendEmailWrapper>();
		List<CommissionTrackerControllerLgtng.SendEmailWrapper> providersWithoutCommissions = new List<CommissionTrackerControllerLgtng.SendEmailWrapper>();

		List<String> selectedAllmilestone = new List<String>{'M1','M2','M3','Clawbacks'};

		CommissionTrackerControllerLgtng.SendEmailWrapper wrapper1 = new CommissionTrackerControllerLgtng.SendEmailWrapper();
		wrapper1.CommissionResult = 9999;
        wrapper1.ProviderName = 'Harbor Energy';
        wrapper1.ProviderStatus = 'Active';
        wrapper1.ContactEmails = 'test@testing.com';
        wrapper1.PaidMilestone = true;
        wrapper1.ContactNames = 'Test O1';
		providersList.add(wrapper1);

		Date fromDate = System.today().addDays(-10);
		Date toDate = System.today();
		
		String result = CommissionTrackerControllerLgtng.sendEmailToProviders(selectedAllmilestone,fromDate,toDate,providersList,providersWithoutCommissions);

		System.assertEquals('OK', result);
    }

    static Account anAccount;
    static Opportunity opp_1;
	static Opportunity opp_2;
	static Opportunity opp_3;
	static Opportunity opp_4;
	static Opportunity opp_5;
	static Opportunity opp_6;
	static Opportunity opp_7;
	static Opportunity opp_8;
	static List<Opportunity> opp_list;
	static Commission_plan__c commission_plan_1;
    static Commission__c commission_1;
	static Commission__c commission_2;
	static Commission__c commission_3;
	static Commission__c commission_4;
	static Commission__c commission_5;
	static Commission__c commission_6;
	static Commission__c commission_7;
	static Commission__c commission_8;
    static Contact contactOne;
    static Contact contactTwo;
	static User anUser;
	static Profile userProfile;
	static String account_recordtype_id;
	static String opp_recordtype_id;

    static { 
		account_recordtype_id = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Residential - Customer').getRecordTypeId();

        anAccount = TestDataFactory.createAccount('Harbor Energy',account_recordtype_id);
        anAccount.Channel_Partner_Status__c = 'Active';
        insert anAccount;

        Contact cont = TestDataFactory.createContact('Test','O1', anAccount.id);
        cont.Title = 'Leadership';
		cont.Email = 'test@testing.com';
        insert cont;

        opp_list = new List<Opportunity>();
        opp_recordtype_id = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('3rd Party - Design Sales').getRecordTypeId();
        opp_1 = TestDataFactory.createOpportunity(opp_recordtype_id, 'Test 1', anAccount.id, '17. Install Ready', 'Alabama');
        opp_1.LeadSource = '3rd Party Provider';
        opp_1.Lead_Source_Type__c = 'Channel';
        opp_1.X3rd_Party_Partner__c = 'Harbor Energy';
        opp_1.Financing_Tool__c = 'Sunlight';
        opp_1.Loan_Term__c = '20';
        opp_1.Proposal_Created__c = true;
        opp_1.Engineering_Created__c = true;
        opp_1.Final_Design_Created_Date__c = system.Date.today();
        opp_1.Number_of_Arrays__c = 1;
        opp_1.Contract_Received_Confirmed__c= true;
        opp_1.Contract_Received_Confirmed_Date__c = system.Date.today().addDays(-5);
        opp_1.Amount = 30000;
        opp_1.Number_of_Solar_Panels__c  = 25;
        opp_1.Panel_Type__c = 'Q.PEAK-G4.1 300';
        opp_1.Panel_Wattage__c = 300;
        opp_1.Installation_Complete_Date__c = Date.today();
        opp_list.add(opp_1);
        /* -------------------------------------------------------*/
        opp_2 = TestDataFactory.createOpportunity(opp_recordtype_id, 'Test 2', anAccount.id, '7a. Contract Received Confirmed', 'Alabama');
        opp_2.LeadSource = '3rd Party Provider';
        opp_2.Lead_Source_Type__c = 'Channel';
        opp_2.Financing_Tool__c = 'Sunlight';
        opp_2.X3rd_Party_Partner__c = 'Harbor Energy';
        opp_2.Loan_Term__c = '20';
        opp_2.Proposal_Created__c = true;
        opp_2.Engineering_Created__c = true;
        opp_2.Final_Design_Created_Date__c = system.Date.today();
        opp_2.Number_of_Arrays__c = 1;
        opp_2.Contract_Received_Confirmed__c= true;
        opp_2.Contract_Received_Confirmed_Date__c = system.Date.today().addDays(-5);
        opp_2.Amount = 30000;
        opp_2.Number_of_Solar_Panels__c  = 25;
        opp_2.Panel_Type__c = 'Q.PEAK-G4.1 300';
        opp_2.Panel_Wattage__c = 300;
        opp_2.Installation_Complete_Date__c = Date.today();
        opp_list.add(opp_2);
        /*--------------------------------------- */
        opp_3 = TestDataFactory.createOpportunity(opp_recordtype_id, 'Test 3', anAccount.id, '22. PTO', 'Alabama');
        opp_3.LeadSource = '3rd Party Provider';
        opp_3.Lead_Source_Type__c = 'Channel';
        opp_3.Financing_Tool__c = 'Sunlight';
        opp_3.X3rd_Party_Partner__c = 'Simple Solar';
        opp_2.Loan_Term__c = '20';
        opp_3.Proposal_Created__c = true;
        opp_3.Engineering_Created__c = true;
        opp_3.Final_Design_Created_Date__c = system.Date.today();
        opp_3.Number_of_Arrays__c = 1;
        opp_3.Contract_Received_Confirmed__c= true;
        opp_3.Contract_Received_Confirmed_Date__c = system.Date.today().addDays(-5);
        opp_3.Amount = 30000;
        opp_3.Number_of_Solar_Panels__c  = 25;
        opp_3.Panel_Type__c = 'Q.PEAK-G4.1 300';
        opp_3.Panel_Wattage__c = 300;
        opp_3.Installation_Complete_Date__c = Date.today();
        opp_list.add(opp_3);
        /*--------------------------------------------------*/
        opp_4 = TestDataFactory.createOpportunity(opp_recordtype_id, 'Test 3', anAccount.id, 'Cancelled', 'Alabama');
        opp_4.Reason_for_loss__c = 'Cancelled with Finance Partner';
        opp_4.LeadSource = '3rd Party Provider';
        opp_4.Lead_Source_Type__c = 'Channel';
        opp_4.X3rd_Party_Partner__c = 'Team Solar';
        opp_4.Financing_Tool__c = 'Sunlight';
        opp_4.Loan_Term__c = '20';
        opp_4.Proposal_Created__c = true;
        opp_4.Engineering_Created__c = true;
        opp_4.Final_Design_Created_Date__c = system.Date.today();
        opp_4.Number_of_Arrays__c = 1;
        opp_4.Contract_Received_Confirmed__c= true;
        opp_4.Contract_Received_Confirmed_Date__c = system.Date.today().addDays(-5);
        opp_4.Amount = 30000;
        opp_4.Number_of_Solar_Panels__c  = 25;
        opp_4.Panel_Type__c = 'Q.PEAK-G4.1 300';
        opp_4.Panel_Wattage__c = 300;
        opp_4.Installation_Complete_Date__c = Date.today();
        opp_list.add(opp_4);
        /*--------------------------------------------*/
        opp_5 = TestDataFactory.createOpportunity(opp_recordtype_id, 'Test 1', anAccount.id, '17. Install Ready', 'Alabama');
        opp_5.LeadSource = '3rd Party Provider';
        opp_5.Lead_Source_Type__c = 'Channel';
        opp_5.X3rd_Party_Partner__c = 'Harbor Energy';
        opp_5.Financing_Tool__c = 'Sunlight';
        opp_5.Loan_Term__c = '20';
        opp_5.Proposal_Created__c = true;
        opp_5.Engineering_Created__c = true;
        opp_5.Final_Design_Created_Date__c = system.Date.today();
        opp_5.Number_of_Arrays__c = 1;
        opp_5.Contract_Received_Confirmed__c= true;
        opp_5.Contract_Received_Confirmed_Date__c = system.Date.today().addDays(-5);
        opp_5.Amount = 30000;
        opp_5.Number_of_Solar_Panels__c  = 25;
        opp_5.Panel_Type__c = 'Q.PEAK-G4.1 300';
        opp_5.Panel_Wattage__c = 300;
        opp_5.Installation_Complete_Date__c = Date.today();
        opp_list.add(opp_5);
        /*--------------------------------------------------------------*/
        opp_6 = TestDataFactory.createOpportunity(opp_recordtype_id, 'Test 1', anAccount.id, '17. Install Ready', 'Alabama');
        opp_6.LeadSource = '3rd Party Provider';
        opp_6.Lead_Source_Type__c = 'Channel';
        opp_6.X3rd_Party_Partner__c = '360 Total Solutions LLC';
        opp_6.Financing_Tool__c = 'Sunlight';
        opp_6.Loan_Term__c = '20';
        opp_6.Proposal_Created__c = true;
        opp_6.Engineering_Created__c = true;
        opp_6.Final_Design_Created_Date__c = system.Date.today();
        opp_6.Number_of_Arrays__c = 1;
        opp_6.Contract_Received_Confirmed__c= true;
        opp_6.Contract_Received_Confirmed_Date__c = system.Date.today().addDays(-5);
        opp_6.Amount = 30000;
        opp_6.Number_of_Solar_Panels__c  = 25;
        opp_6.Panel_Type__c = 'Q.PEAK-G4.1 300';
        opp_6.Panel_Wattage__c = 300;
        opp_6.Installation_Complete_Date__c = Date.today();
        opp_list.add(opp_6);

		opp_7 = TestDataFactory.createOpportunity(opp_recordtype_id, 'Test 1', anAccount.id, '19. Install Completed', 'Alabama');
        opp_7.LeadSource = '3rd Party Provider';
        opp_7.Lead_Source_Type__c = 'Channel';
        opp_7.X3rd_Party_Partner__c = 'SunSolar';
        opp_7.Financing_Tool__c = 'Sunlight';
        opp_7.Loan_Term__c = '20';
        opp_7.Proposal_Created__c = true;
        opp_7.Engineering_Created__c = true;
        opp_7.Final_Design_Created_Date__c = system.Date.today();
        opp_7.Number_of_Arrays__c = 1;
        opp_7.Contract_Received_Confirmed__c= true;
        opp_7.Contract_Received_Confirmed_Date__c = system.Date.today().addDays(-5);
        opp_7.Amount = 30000;
        opp_7.Number_of_Solar_Panels__c  = 25;
        opp_7.Panel_Type__c = 'Q.PEAK-G4.1 300';
        opp_7.Panel_Wattage__c = 300;
        opp_7.Installation_Complete_Date__c = Date.today();
        opp_list.add(opp_7);

		opp_8 = TestDataFactory.createOpportunity(opp_recordtype_id, 'Test 1', anAccount.id, '19. Install Completed', 'Alabama');
        opp_8.LeadSource = '3rd Party Provider';
        opp_8.Lead_Source_Type__c = 'Channel';
        opp_8.X3rd_Party_Partner__c = '360 Total Solutions LLC';
        opp_8.Financing_Tool__c = 'Cash';
        opp_8.Loan_Term__c = '20';
        opp_8.Proposal_Created__c = true;
        opp_8.Engineering_Created__c = true;
        opp_8.Final_Design_Created_Date__c = system.Date.today();
        opp_8.Number_of_Arrays__c = 1;
        opp_8.Contract_Received_Confirmed__c= true;
        opp_8.Contract_Received_Confirmed_Date__c = system.Date.today().addDays(-5);
        opp_8.Amount = 30000;
        opp_8.Number_of_Solar_Panels__c  = 25;
        opp_8.Panel_Type__c = 'Q.PEAK-G4.1 300';
        opp_8.Panel_Wattage__c = 300;
        opp_8.Installation_Complete_Date__c = Date.today();
        opp_list.add(opp_8);
        insert opp_list;

        opp_1.Contract_Received_Confirmed_Date__c = system.Date.today().addDays(-6);
        update opp_1;

        opp_5.Contract_Received_Confirmed_Date__c = system.Date.today().addDays(-6);
        update opp_5;

        opp_6.Contract_Received_Confirmed_Date__c = system.Date.today().addDays(-6);
        update opp_6;

        /*----------------------------------------------------*/
        
        commission_plan_1 = TestDataFactory.createCommissionPlan('CP Alabama');
        commission_plan_1.Location__c = 'Alabama';
        commission_plan_1.User__c = UserInfo.getUserId();
        commission_plan_1.Channel_Partner_Account__c = anAccount.id;
        commission_plan_1.X3rd_Party_Partner__c = 'Harbor Energy';
        commission_plan_1.Base_6kW__c = 2500;
        commission_plan_1.X6kW__c = 2500;
        commission_plan_1.Milestone_1_Percent__c = 30;
        commission_plan_1.Milestone_2_Percent__c = 55;
        commission_plan_1.Milestone_3_Percent__c = 15;
        insert commission_plan_1;

        commission_1 = new Commission__c();
        commission_1.Opportunity__c = opp_1.id;
        commission_1.Commission_Plan__c = commission_plan_1.id;
       
        insert commission_1;
        /*------------------------------------------ */
        commission_2 = new Commission__c();
        commission_2.Opportunity__c = opp_2.id;
        commission_2.Commission_Plan__c = commission_plan_1.id;
        insert commission_2;
        /*------------------------------------------ */
        commission_3 = new Commission__c();
        commission_3.Opportunity__c = opp_3.id;
        commission_3.Commission_Plan__c = commission_plan_1.id;
        
        insert commission_3;
        /*------------------------------------------ */
        commission_4 = new Commission__c();
        commission_4.Opportunity__c = opp_4.id;
        commission_4.Commission_Plan__c = commission_plan_1.id;
        insert commission_4;
        /*------------------------------------------ */
        commission_5 = new Commission__c();
        commission_5.Opportunity__c = opp_5.id;
        commission_5.Commission_Plan__c = commission_plan_1.id;
        insert commission_5;
        /*------------------------------------------ */
        commission_6 = new Commission__c();
        commission_6.Opportunity__c = opp_6.id;
        commission_6.Commission_Plan__c = commission_plan_1.id;
        insert commission_6;

		commission_7 = new Commission__c();
        commission_7.Opportunity__c = opp_7.id;
        commission_7.Commission_Plan__c = commission_plan_1.id;
		commission_7.Milestone_2_Processed__c = true;
        insert commission_7;

		commission_8 = new Commission__c();
		commission_8.Opportunity__c = opp_8.id;
        commission_8.Commission_Plan__c = commission_plan_1.id;
		commission_8.Milestone_2_Processed__c = true;
        insert commission_8;
    }
}