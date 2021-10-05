@isTest
public with sharing class CommissionTrackerExportLgtngTest {
	@isTest
	private static void getReportForCommissionsToBeProcessed() {

		Date fromDateUnformatted = system.today().addDays(-5);
		String fromDate = fromDateUnformatted.format();
		Date toDateUnformatted = system.today();
		String toDate = toDateUnformatted.format();
		String selectedProvider = '\'Harbor Energy\',\'360 Total Solutions LLC\'';
		String milestone = 'M1;M2;M3;Clawbacks';
		Integer reportType = 1;
		Boolean paidMilestone = true;
		
		test.startTest();
		String result = CommissionTrackerExportControllerLgtng.getReport(fromDate, toDate, selectedProvider, milestone, reportType, paidMileStone);
		test.stopTest();

		System.assertEquals(true, result.contains(fromDate));
		System.assertEquals(true, result.contains(toDate));
	}
	@isTest
	private static void getReportForCommissionsProcessed() {

		Date fromDateUnformatted = system.today().addDays(-5);
		String fromDate = fromDateUnformatted.format();
		Date toDateUnformatted = system.today();
		String toDate = toDateUnformatted.format();
		String selectedProvider = '\'Harbor Energy\',\'360 Total Solutions LLC\'';
		String milestone = 'M1;M2;M3;Clawbacks';
		Integer reportType = 2;
		Boolean paidMilestone = true;
		
		test.startTest();
		String result = CommissionTrackerExportControllerLgtng.getReport(fromDate, toDate, selectedProvider, milestone, reportType, paidMileStone);
		test.stopTest();

		System.assertEquals(true, result.contains(fromDate));
		System.assertEquals(true, result.contains(toDate));
	}

	@isTest
	private static void getReportForPaidCommissions() {

		Date fromDateUnformatted = system.today().addDays(-5);
		String fromDate = fromDateUnformatted.format();
		Date toDateUnformatted = system.today();
		String toDate = toDateUnformatted.format();
		String selectedProvider = '\'Harbor Energy\',\'360 Total Solutions LLC\'';
		String milestone = 'M1;M2;M3;Clawbacks';
		Integer reportType = 3;
		Boolean paidMilestone = true;
		
		test.startTest();
		String result = CommissionTrackerExportControllerLgtng.getReport(fromDate, toDate, selectedProvider, milestone, reportType, paidMileStone);
		test.stopTest();

		System.assertEquals(true, result.contains(fromDate));
		System.assertEquals(true, result.contains(toDate));
	}

	static String account_recordtype_id;
	static Account acc;
	static Account acc2;
	static Contact cont;
	static Contact con2;
	static Contact cont3;
	static Contact con4;
	static List<Opportunity> opp_list;
	static string opp_recordtype_id;
	static Opportunity opp_1;
	static Opportunity opp_2;
	static Opportunity opp_3;
	static Opportunity opp_4;
	static Opportunity opp_5;
	static Opportunity opp_6;
	static Opportunity opp_7;
	static Opportunity opp_8;
	static Commission_plan__c commission_plan_1;
	static Commission__c commission_1;
	static Commission__c commission_2;
	static Commission__c commission_3;
	static Commission__c commission_4;
	static Commission__c commission_5;
	static Commission__c commission_6;
	static Commission__c commission_7;
	static Commission__c commission_8;
	static Commission__c commission_9;
	static Commission__c commission_10;
	static Commission__c commission_11;
	static Commission__c commission_12;
	static Commission__c commission_13;
	static Commission__c commission_14;
	static Commission__c commission_15;
	static Commission__c commission_16;
	static Commission__c commission_17;
	static Commission__c commission_18;
	static Commission__c commission_19;
	static Commission__c commission_20;

	static {
		account_recordtype_id = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Residential - Customer').getRecordTypeId();
         acc = TestDataFactory.createAccount('Harbor Energy',account_recordtype_id);
        acc.Channel_Partner_Status__c = 'Active';
        insert acc;

        acc2 = TestDataFactory.createAccount('360 Total Solutions LLC',account_recordtype_id);
        acc2.Channel_Partner_Status__c = 'Active';
        insert acc2;

        cont = TestDataFactory.createContact('Test','O1', acc.id);
        cont.Title = 'Leadership';
        cont.email = 'test1@gmai.com';
        insert cont;

        con2 = TestDataFactory.createContact('Test','O2', acc.id);
        con2.Title = 'Leadership';
        con2.email = 'test2@gmai.com';
        insert con2;

        cont3 = TestDataFactory.createContact('Test','O3', acc2.id);
        cont3.Title = 'Leadership';
        cont3.email = 'test3@gmai.com';
        insert cont3;

        con4 = TestDataFactory.createContact('Test','O4', acc2.id);
        con4.Title = 'Leadership';
        con4.email = 'test4@gmai.com';
        insert con4;

        opp_list = new List<Opportunity>();
        opp_recordtype_id = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('3rd Party - Design Sales').getRecordTypeId();
        opp_1 = TestDataFactory.createOpportunity(opp_recordtype_id, 'Test 1', acc.id, '17. Install Ready', 'Alabama');
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
        opp_2 = TestDataFactory.createOpportunity(opp_recordtype_id, 'Test 2', acc.id, '7a. Contract Received Confirmed', 'Alabama');
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
        opp_3 = TestDataFactory.createOpportunity(opp_recordtype_id, 'Test 3', acc.id, '22. PTO', 'Alabama');
        opp_3.LeadSource = '3rd Party Provider';
        opp_3.Lead_Source_Type__c = 'Channel';
        opp_3.Financing_Tool__c = 'Sunlight';
        opp_3.X3rd_Party_Partner__c = 'Harbor Energy';
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
        opp_4 = TestDataFactory.createOpportunity(opp_recordtype_id, 'Test 3', acc.id, 'Cancelled', 'Alabama');
        opp_4.Reason_for_loss__c = 'Cancelled with Finance Partner';
        opp_4.LeadSource = '3rd Party Provider';
        opp_4.Lead_Source_Type__c = 'Channel';
        opp_4.X3rd_Party_Partner__c = 'Harbor Energy';
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
        opp_5 = TestDataFactory.createOpportunity(opp_recordtype_id, 'Test 1', acc.id, '17. Install Ready', 'Alabama');
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
        opp_6 = TestDataFactory.createOpportunity(opp_recordtype_id, 'Test 1', acc.id, '17. Install Ready', 'Alabama');
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
        /*--------------------------------------------------------------*/
        opp_7 = TestDataFactory.createOpportunity(opp_recordtype_id, 'Test 1', acc.id, '17. Install Ready', 'Alabama');
        opp_7.LeadSource = '3rd Party Provider';
        opp_7.Lead_Source_Type__c = 'Channel';
        opp_7.X3rd_Party_Partner__c = '360 Total Solutions LLC';
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

		opp_8 = TestDataFactory.createOpportunity(opp_recordtype_id, 'Test 1', acc.id, '19. Install Completed', 'Alabama');
        opp_8.LeadSource = '3rd Party Provider';
        opp_8.Lead_Source_Type__c = 'Channel';
        opp_8.X3rd_Party_Partner__c = '360 Total Solutions LLC';
        opp_8.Financing_Tool__c = 'Sunlight';
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
        /*----------------------------------------------------*/
        
        commission_plan_1 = TestDataFactory.createCommissionPlan('CP Alabama');
        commission_plan_1.Location__c = 'Alabama';
        commission_plan_1.User__c = UserInfo.getUserId();
        commission_plan_1.Channel_Partner_Account__c = acc.id;
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
        commission_1.Milestone_1_Processed_Date__c = system.date.Today();
        commission_1.Milestone_1_Processed__c = true;
        insert commission_1;
        /*------------------------------------------ */
        commission_2 = new Commission__c();
        commission_2.Opportunity__c = opp_2.id;
        commission_2.Commission_Plan__c = commission_plan_1.id;
        commission_2.Milestone_1_Processed_Date__c = system.date.Today();
        commission_2.Milestone_1_Processed__c = true;
        insert commission_2;
        /*------------------------------------------ */
        commission_3 = new Commission__c();
        commission_3.Opportunity__c = opp_3.id;
        commission_3.Milestone_2_Processed_Date__c = system.date.Today();
        commission_3.Milestone_2_Processed__c = true;
        commission_3.Commission_Plan__c = commission_plan_1.id;
        insert commission_3;
        /*------------------------------------------ */
        commission_4 = new Commission__c();
        commission_4.Opportunity__c = opp_4.id;
        commission_4.Commission_Plan__c = commission_plan_1.id;
        commission_4.Milestone_3_Processed_Date__c = system.date.Today();
        commission_4.Milestone_3_Processed__c = true;
        insert commission_4;
        /*------------------------------------------ */
        commission_5 = new Commission__c();
        commission_5.Opportunity__c = opp_5.id;
        commission_5.Commission_Plan__c = commission_plan_1.id;
        commission_5.M1_Clawback_Processed_Date__c = system.date.Today();
        commission_5.M1_Clawback_Complete__c = true;
        insert commission_5;
        /*------------------------------------------ */
        commission_6 = new Commission__c();
        commission_6.Opportunity__c = opp_6.id;
        commission_6.Commission_Plan__c = commission_plan_1.id;
        commission_6.Milestone_1_Processed_Date__c = system.date.Today();
        commission_6.Milestone_1_Processed__c = true;
        insert commission_6;
        /*------------------------------------------ */
        commission_7 = new Commission__c();
        commission_7.Opportunity__c = opp_3.id;
        commission_7.Commission_Plan__c = commission_plan_1.id;
        commission_7.Milestone_2_Processed_Date__c = system.date.Today();
        commission_7.Milestone_2_Processed__c = true;
        insert commission_7;
        /*------------------------------------------ */
        commission_8 = new Commission__c();
        commission_8.Opportunity__c = opp_7.id;
        commission_8.Milestone_2_Processed_Date__c = system.date.Today();
        commission_8.Milestone_2_Processed__c = true;
        insert commission_8;
        /*------------------------------------------ */
        commission_9 = new Commission__c();
        commission_9.Opportunity__c = opp_3.id;
        commission_9.Commission_Plan__c = commission_plan_1.id;
        commission_9.Milestone_3_Processed_Date__c = system.date.Today();
        commission_9.Milestone_3_Processed__c = true;
        insert commission_9;
         /*------------------------------------------ */
        commission_10 = new Commission__c();
        commission_10.Opportunity__c = opp_7.id;
        commission_10.Milestone_3_Processed_Date__c = system.date.Today();
        commission_10.Milestone_3_Processed__c = true;
        insert commission_10;
        /*------------------------------------------ */
        commission_11 = new Commission__c();
        commission_11.Opportunity__c = opp_3.id;
        commission_11.Commission_Plan__c = commission_plan_1.id;
        commission_11.M1_Clawback_Processed_Date__c = system.date.Today();
        commission_11.M1_Clawback_Complete__c = true;
        insert commission_11;
         /*------------------------------------------ */
        commission_12 = new Commission__c();
        commission_12.Opportunity__c = opp_7.id;
        commission_12.M1_Clawback_Processed_Date__c = system.date.Today();
        commission_12.M1_Clawback_Complete__c = true;
        insert commission_12;

		commission_13 = new Commission__c();
        commission_13.Opportunity__c = opp_7.id;
        commission_13.Commission_Plan__c = commission_plan_1.id;
        commission_13.Milestone_1_Paid_Date__c = system.date.today().addDays(-3);
		commission_13.Milestone_1_Paid__c = true;
        insert commission_13;
		//Paid commission M2 
		commission_14 = new Commission__c();
        commission_14.Opportunity__c = opp_7.id;
        commission_14.Commission_Plan__c = commission_plan_1.id;
        commission_14.Milestone_1_Paid_Date__c = system.date.today().addDays(-3);
		commission_14.Milestone_1_Paid__c = true;
		insert commission_14;

		commission_17 = new Commission__c();
        commission_17.Opportunity__c = opp_8.id;
        commission_17.Commission_Plan__c = commission_plan_1.id;
        commission_17.Milestone_2_Paid_Date__c = system.date.today().addDays(-3);
		commission_17.Milestone_2_Paid__c = true;
		insert commission_17;

		commission_18 = new Commission__c();
        commission_18.Opportunity__c = opp_7.id;
        commission_18.Commission_Plan__c = commission_plan_1.id;
        commission_18.Milestone_3_Paid_Date__c = system.date.today().addDays(-3);
		commission_18.Milestone_3_Paid__c = true;
        insert commission_18;
		//Paid Commission M3
		commission_15 = new Commission__c();
        commission_15.Opportunity__c = opp_3.id;
        commission_15.Commission_Plan__c = commission_plan_1.id;
        commission_15.Milestone_3_Paid_Date__c = system.date.today().addDays(-3);
		commission_15.Milestone_3_Paid__c = true;
        insert commission_15;

		commission_19 = new Commission__c();
        commission_19.Opportunity__c = opp_7.id;
        commission_19.Commission_Plan__c = commission_plan_1.id;
        commission_19.Milestone_3_Paid_Date__c = system.date.today().addDays(-3);
		commission_19.Milestone_3_Paid__c = true;
        insert commission_19;

		commission_20 = new Commission__c();
        commission_20.Opportunity__c = opp_7.id;
        commission_20.Commission_Plan__c = commission_plan_1.id;
        commission_20.Milestone_3_Paid_Date__c = system.date.today().addDays(-3);
		commission_20.Milestone_3_Paid__c = true;
        insert commission_20;
		//Paid Commission Clawback
		commission_16 = new Commission__c();
        commission_16.Opportunity__c = opp_4.id;
        commission_16.Commission_Plan__c = commission_plan_1.id;
        commission_16.M1_Clawback_Applied_to_Balance_Paid_Date__c = system.date.today().addDays(-3);
		commission_16.M1_Clawback_Applied_Paid__c = true;
        insert commission_16;
	}
}