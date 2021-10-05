@isTest
private class BatchToCreatePTOCaseTest
{
    static testMethod void unitTest(){
        string account_recordtype_id = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Residential - Customer').getRecordTypeId();
        Account objAccount = TestDataFactory.createAccount('Harbor Energy',account_recordtype_id);
        insert objAccount;
        
        Contact objContact = TestDataFactory.createContact('Urvashi', 'Babbar', objAccount.Id);
        objContact.Email = 'test@test.com';
        insert objContact;
        
        
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
        objOpportunity.Phone_Textey__c = '1234567890';
        insert objOpportunity;
        
        objOpportunity.Loan_Term__c = '30';
        objOpportunity.Installation_Complete_Date__c = Date.today().addDays(-45);
        update objOpportunity;
        
        Test.startTest();
            new BatchToCreatePTOCase().execute(null);
        Test.stopTest();
    }
    
    static testMethod void unitTest2(){
        string account_recordtype_id = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Residential - Customer').getRecordTypeId();
        Account objAccount = TestDataFactory.createAccount('Harbor Energy',account_recordtype_id);
        insert objAccount;
        
        Contact objContact = TestDataFactory.createContact('Urvashi', 'Babbar', objAccount.Id);
        insert objContact;
        
        
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
        
        objOpportunity.Loan_Term__c = '30';
        objOpportunity.Installation_Complete_Date__c = Date.today().addDays(-60);
        update objOpportunity;
        
        Test.startTest();
            new BatchToCreatePTOCase().execute(null);
        Test.stopTest();
    }
    
    static testMethod void unitTest3(){
        string account_recordtype_id = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Residential - Customer').getRecordTypeId();
        Account objAccount = TestDataFactory.createAccount('Harbor Energy',account_recordtype_id);
        insert objAccount;
        
        Contact objContact = TestDataFactory.createContact('Urvashi', 'Babbar', objAccount.Id);
        insert objContact;
        
        
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
        objOpportunity.Phone_Textey__c = '1234567890';
        insert objOpportunity;
        
        objOpportunity.Loan_Term__c = '30';
        objOpportunity.Installation_Complete_Date__c = Date.today().addDays(-60);
        update objOpportunity;
        
        try{
            new BatchToCreatePTOCase().execute(null);
        } catch(Exception e){}
    }
}