@isTest
private class PopulateChannelPartnerTest
{
    static testMethod void unitTest(){
        String account_recordtype_id = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Residential - Customer').getRecordTypeId();
        Account acc = TestDataFactory.createAccount('Harbor Energy',account_recordtype_id);
        insert acc;
        
        Contact cont = TestDataFactory.createContact('Test','O1', acc.id);
        cont.Title = 'Leadership';
        cont.email = 'test1@gmai.com';
        insert cont;
        
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
        opp_1.Opp_Primary_Contact__c = cont.Id;
        insert opp_1;
        
        Database.executeBatch(new PopulateChannelPartner());
    }
}