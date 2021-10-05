@isTest
private class CommissionToBeProcessedSchedularTest
{
	private static testmethod void commissionToBeProcessedTest()
    {
        string account_recordtype_id = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Residential - Customer').getRecordTypeId();
        Account acc = TestDataFactory.createAccount('Harbor Energy',account_recordtype_id);
        insert acc;
        Contact cont = TestDataFactory.createContact('Test','O1', acc.id);
        cont.Title = 'Leadership';
        insert cont;
        List<Opportunity> opp_list = new List<Opportunity>();
        string opp_recordtype_id = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('3rd Party - Design Sales').getRecordTypeId();
        Opportunity opp_1 = TestDataFactory.createOpportunity(opp_recordtype_id, 'Test 1', acc.id, '17. Install Ready', 'Alabama');
        opp_1.LeadSource = '3rd Party Provider';
        opp_1.Lead_Source_Type__c = 'Channel';
        opp_1.X3rd_Party_Partner__c = 'Harbor Energy';
        opp_1.Financing_Tool__c	= 'Sunlight';
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
        opp_list.add(opp_1);
        /* -------------------------------------------------------*/
        Opportunity opp_2 = TestDataFactory.createOpportunity(opp_recordtype_id, 'Test 2', acc.id, '7a. Contract Received Confirmed', 'Alabama');
        opp_2.LeadSource = '3rd Party Provider';
        opp_2.Lead_Source_Type__c = 'Channel';
        opp_2.Financing_Tool__c	= 'Sunlight';
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
        opp_list.add(opp_2);
        /*--------------------------------------- */
        Opportunity opp_3 = TestDataFactory.createOpportunity(opp_recordtype_id, 'Test 3', acc.id, '22. PTO', 'Alabama');
        opp_3.LeadSource = '3rd Party Provider';
        opp_3.Lead_Source_Type__c = 'Channel';
        opp_3.Financing_Tool__c	= 'Sunlight';
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
        opp_list.add(opp_3);
        /*--------------------------------------------------*/
        Opportunity opp_4 = TestDataFactory.createOpportunity(opp_recordtype_id, 'Test 3', acc.id, 'Cancelled', 'Alabama');
        opp_4.Reason_for_loss__c = 'Cancelled with Finance Partner';
        opp_4.LeadSource = '3rd Party Provider';
        opp_4.Lead_Source_Type__c = 'Channel';
        opp_4.X3rd_Party_Partner__c = 'Harbor Energy';
        opp_4.Financing_Tool__c	= 'Sunlight';
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
        opp_list.add(opp_4);
        /*--------------------------------------------*/
        Opportunity opp_5 = TestDataFactory.createOpportunity(opp_recordtype_id, 'Test 1', acc.id, '17. Install Ready', 'Alabama');
        opp_5.LeadSource = '3rd Party Provider';
        opp_5.Lead_Source_Type__c = 'Channel';
        opp_5.X3rd_Party_Partner__c = 'Harbor Energy';
        opp_5.Financing_Tool__c	= 'Sunlight';
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
        opp_list.add(opp_5);
        /*--------------------------------------------------------------*/
        Opportunity opp_6 = TestDataFactory.createOpportunity(opp_recordtype_id, 'Test 1', acc.id, '17. Install Ready', 'Alabama');
        opp_6.LeadSource = '3rd Party Provider';
        opp_6.Lead_Source_Type__c = 'Channel';
        opp_6.X3rd_Party_Partner__c = '360 Total Solutions LLC';
        opp_6.Financing_Tool__c	= 'Sunlight';
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
        opp_list.add(opp_6);
        insert opp_list;
        opp_1.Contract_Received_Confirmed_Date__c = system.Date.today().addDays(-6);
        update opp_1;
        opp_5.Contract_Received_Confirmed_Date__c = system.Date.today().addDays(-6);
        update opp_5;
        opp_6.Contract_Received_Confirmed_Date__c = system.Date.today().addDays(-6);
        update opp_6;
        /*----------------------------------------------------*/
        
        Commission_plan__c commission_plan_1 = TestDataFactory.createCommissionPlan('CP Alabama');
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
        Commission__c commission_1 = new Commission__c();
        commission_1.Opportunity__c = opp_1.id;
        commission_1.Commission_Plan__c = commission_plan_1.id;
       
        insert commission_1;
        /*------------------------------------------ */
        Commission__c commission_2 = new Commission__c();
        commission_2.Opportunity__c = opp_2.id;
        commission_2.Commission_Plan__c = commission_plan_1.id;
        insert commission_2;
        /*------------------------------------------ */
        Commission__c commission_3 = new Commission__c();
        commission_3.Opportunity__c = opp_3.id;
        commission_3.Commission_Plan__c = commission_plan_1.id;
        
        insert commission_3;
        /*------------------------------------------ */
        Commission__c commission_4 = new Commission__c();
        commission_4.Opportunity__c = opp_4.id;
        commission_4.Commission_Plan__c = commission_plan_1.id;
        insert commission_4;
        /*------------------------------------------ */
        Commission__c commission_5 = new Commission__c();
        commission_5.Opportunity__c = opp_5.id;
        commission_5.Commission_Plan__c = commission_plan_1.id;
        insert commission_5;
        /*------------------------------------------ */
        Commission__c commission_6 = new Commission__c();
        commission_6.Opportunity__c = opp_6.id;
        commission_6.Commission_Plan__c = commission_plan_1.id;
        insert commission_6;
        test.startTest();
        String CRON_EXP = '0 0 * * * ?'; 
        String jobId = System.schedule('Commission', CRON_EXP, new CommissionToBeProcessedSchedular());
        try
        {
            integer i = 1/0;
        }
        catch(exception ex)
        {
            CommissionHandler.sendErrorEmail('test@gmail.com',ex);
        }
        test.stopTest();
    }
}