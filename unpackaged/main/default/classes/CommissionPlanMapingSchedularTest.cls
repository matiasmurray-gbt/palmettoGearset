@isTest
private class CommissionPlanMapingSchedularTest 
{
    private static testmethod void asssignCommissionPlan()
    {
        string account_recordtype_id = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Residential - Customer').getRecordTypeId();
        Account acc = TestDataFactory.createAccount('Harbor Energy',account_recordtype_id);
        insert acc;
        Account acc2 = TestDataFactory.createAccount('360 Total Solutions LLC',account_recordtype_id);
        insert acc2;
        Contact cont = TestDataFactory.createContact('Test','O1', acc.id);
        cont.Title = 'Leadership';
        cont.email = 'test1@gmai.com';
        insert cont;
        List<Opportunity> opp_list = new List<Opportunity>();
        string opp_recordtype_id = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('3rd Party - Design Sales').getRecordTypeId();
        Opportunity opp_1 = TestDataFactory.createOpportunity(opp_recordtype_id, 'Test 2', acc.id, '7a. Contract Received Confirmed', 'Alabama');
        opp_1.LeadSource = '3rd Party Provider';
        opp_1.Lead_Source_Type__c = 'Channel';
        opp_1.Customer_Type__c = 'Residential - Customer';
        opp_1.Financing_Tool__c = 'Sunlight';
        opp_1.X3rd_Party_Partner__c = 'Harbor Energy';
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
        opp_1.Test_Account__c = false;
        opp_1.Channel_Partner__c = acc.Id;
        opp_list.add(opp_1);
        /*------------------------------------------------*/
        Opportunity opp_2 = TestDataFactory.createOpportunity(opp_recordtype_id, 'Test 2', acc.id, '7a. Contract Received Confirmed', 'Alabama');
        opp_2.LeadSource = '3rd Party Provider';
        opp_2.Lead_Source_Type__c = 'Channel';
        opp_2.Customer_Type__c = 'Residential - Customer';
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
        opp_2.Test_Account__c = false;
        opp_2.Channel_Partner__c = acc.Id;
        opp_list.add(opp_2);
        /*-----------------------------------------------------------------*/
        /*------------------------------------------------*/
        Opportunity opp_3 = TestDataFactory.createOpportunity(opp_recordtype_id, 'Test 2', acc.id, '7a. Contract Received Confirmed', 'Alabama');
        opp_3.LeadSource = '3rd Party Provider';
        opp_3.Lead_Source_Type__c = 'Independent';
        opp_3.Customer_Type__c = 'Residential - Customer';
        opp_3.Financing_Tool__c = 'Sunlight';
        opp_3.X3rd_Party_Partner__c = 'Harbor Energy';
        opp_3.Loan_Term__c = '20';
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
        opp_3.Test_Account__c = false;
        opp_3.Channel_Partner__c = acc.Id;
        opp_list.add(opp_3);
        insert opp_list;
        opp_1.LeadSource = '3rd Party Provider';
        opp_1.StageName = '7. Contract Received';
        update opp_1;
        opp_2.LeadSource = '3rd Party Provider';
        opp_2.StageName = '7. Contract Received';
        update opp_2;
        opp_3.LeadSource = '3rd Party Provider';
        opp_3.StageName = '7. Contract Received';
        opp_3.Lead_Source_Type__c = 'Independent';
        update opp_3;
        /*-----------------------------------------------*/
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
        /*--------------------------------------------------------------*/
        Commission_plan__c commission_plan_2 = TestDataFactory.createCommissionPlan('Independent Alchemists Commission Plan');
        commission_plan_2.Location__c = 'Alabama';
        commission_plan_2.User__c = UserInfo.getUserId();
        commission_plan_2.Channel_Partner_Account__c = acc.id;
        commission_plan_2.X3rd_Party_Partner__c = 'Harbor Energy';
        commission_plan_2.Base_6kW__c = 2500;
        commission_plan_2.X6kW__c = 2500;
        commission_plan_2.Milestone_1_Percent__c = 30;
        commission_plan_2.Milestone_2_Percent__c = 55;
        commission_plan_2.Milestone_3_Percent__c = 15;
        insert commission_plan_2;        
        test.startTest();
        String CRON_EXP = '0 0 * * * ?'; 
        String jobId = System.schedule('Commission Plan Mapping Schedular', CRON_EXP, new CommissionPlanMapingSchedular());
        system.debug([SELECT LeadSource,Lead_Source_Type__c,Customer_Type__c,X3rd_Party_Partner__c,Test_Account__c,location__c,RecordTypeId,StageName from opportunity where id = :opp_1.id]);
        try
        {
            integer i = 1/0;
        }
        catch(Exception ex)
        {
            CommissionPlanMapingHandler.sendErrorEmail('test@gmail.com', ex);
        }
        test.stopTest();
    }

    @isTest
    private static void testExceptionIsRised() {
        // Test data setup
        string account_recordtype_id = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Residential - Customer').getRecordTypeId();
        Account acc = TestDataFactory.createAccount('Harbor Energy',account_recordtype_id);
        insert acc;
        Account acc2 = TestDataFactory.createAccount('360 Total Solutions LLC',account_recordtype_id);
        insert acc2;
        Contact cont = TestDataFactory.createContact('Test','O1', acc.id);
        cont.Title = 'Leadership';
        cont.email = 'test1@gmai.com';
        insert cont;
        List<Opportunity> opp_list = new List<Opportunity>();
        string opp_recordtype_id = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('3rd Party - Design Sales').getRecordTypeId();
        Opportunity opp_1 = TestDataFactory.createOpportunity(opp_recordtype_id, 'Test 2', acc.id, '7a. Contract Received Confirmed', 'Alabama');
        opp_1.LeadSource = '3rd Party Provider';
        opp_1.Lead_Source_Type__c = 'Channel';
        opp_1.Customer_Type__c = 'Residential - Customer';
        opp_1.Financing_Tool__c = 'Sunlight';
        opp_1.X3rd_Party_Partner__c = 'Harbor Energy';
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
        opp_1.Test_Account__c = false;
        opp_1.Channel_Partner__c = acc.Id;
        opp_list.add(opp_1);
        /*------------------------------------------------*/
        Opportunity opp_2 = TestDataFactory.createOpportunity(opp_recordtype_id, 'Test 2', acc.id, '7a. Contract Received Confirmed', 'Alabama');
        opp_2.LeadSource = '3rd Party Provider';
        opp_2.Lead_Source_Type__c = 'Channel';
        opp_2.Customer_Type__c = 'Residential - Customer';
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
        opp_2.Test_Account__c = false;
        opp_2.Channel_Partner__c = acc.Id;
        opp_list.add(opp_2);
        /*-----------------------------------------------------------------*/
        /*------------------------------------------------*/
        Opportunity opp_3 = TestDataFactory.createOpportunity(opp_recordtype_id, 'Test 2', acc.id, '7a. Contract Received Confirmed', 'Alabama');
        opp_3.LeadSource = '3rd Party Provider';
        opp_3.Lead_Source_Type__c = 'Independent';
        opp_3.Customer_Type__c = 'Residential - Customer';
        opp_3.Financing_Tool__c = 'Sunlight';
        opp_3.X3rd_Party_Partner__c = 'Harbor Energy';
        opp_3.Loan_Term__c = '20';
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
        opp_3.Test_Account__c = false;
        opp_3.Channel_Partner__c = acc.Id;
        opp_list.add(opp_3);
        insert opp_list;
        opp_1.LeadSource = '3rd Party Provider';
        opp_1.StageName = '7. Contract Received';
        update opp_1;
        opp_2.LeadSource = '3rd Party Provider';
        opp_2.StageName = '7. Contract Received';
        update opp_2;
        opp_3.LeadSource = '3rd Party Provider';
        opp_3.StageName = '7. Contract Received';
        opp_3.Lead_Source_Type__c = 'Independent';
        update opp_3;
        /*-----------------------------------------------*/
        Commission_plan__c commission_plan_1 = TestDataFactory.createCommissionPlan('CP Alabama');
        commission_plan_1.User__c = UserInfo.getUserId();
        commission_plan_1.Location__c = 'Alabama';
        //commission_plan_1.Channel_Partner_Account__c = acc.id;
        commission_plan_1.X3rd_Party_Partner__c = 'Harbor Energy';
        commission_plan_1.Base_6kW__c = 2500;
        commission_plan_1.X6kW__c = 2500;
        commission_plan_1.Milestone_1_Percent__c = 30;
        commission_plan_1.Milestone_2_Percent__c = 55;
        commission_plan_1.Milestone_3_Percent__c = 15;
        insert commission_plan_1;
        /*--------------------------------------------------------------*/
        Commission_plan__c commission_plan_2 = TestDataFactory.createCommissionPlan('Independent Alchemists Commission Plan');
        commission_plan_2.User__c = UserInfo.getUserId();
        commission_plan_2.Location__c = 'Alabama';
        //commission_plan_2.Channel_Partner_Account__c = acc.id;
        commission_plan_2.X3rd_Party_Partner__c = 'Harbor Energy';
        commission_plan_2.Base_6kW__c = 2500;
        commission_plan_2.X6kW__c = 2500;
        commission_plan_2.Milestone_1_Percent__c = 30;
        commission_plan_2.Milestone_2_Percent__c = 55;
        commission_plan_2.Milestone_3_Percent__c = 15;
        insert commission_plan_2;        

    
        // Actual test
        Test.startTest();
        String CRON_EXP = '0 0 * * * ?'; 
        String jobId = System.schedule('Commission Plan Mapping Schedular', CRON_EXP, new CommissionPlanMapingSchedular());
        Test.stopTest();
    
        // Asserts
    }
}