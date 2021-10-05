@isTest

private with sharing class CommissionTriggerHandlerTest{
    
    static testmethod void unitTest(){
        TriggerConfiguration__c objTriggerConfigurationCS = new TriggerConfiguration__c();
        objTriggerConfigurationCS.Name = 'LGCY API trigger';
        objTriggerConfigurationCS.Active__c = true;
        insert objTriggerConfigurationCS;

        
        
        Account objAccount = new Account();
        objAccount.Name = 'Test 1';
        insert objAccount;
        
        Contact objContact = TestDataFactory.createContact('Urvashi', 'Babbar', objAccount.Id);
        insert objContact;
        
        string opp_recordtype_id = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('3rd Party - Design Sales').getRecordTypeId();
        Opportunity objOpportunity = TestDataFactory.createOpportunity(opp_recordtype_id, 'Test 2', objAccount.id, '7a. Contract Received Confirmed', 'Alabama');
        objOpportunity.LeadSource = '3rd Party Provider';
        objOpportunity.Lead_Source_Type__c = 'Channel';
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
        insert objOpportunity;
        
        Commission_Plan__c objCommissionPlan = TestDataFactory.createCommissionPlan('TEST');
        objCommissionPlan.Opportunity__c = objOpportunity.Id;
        insert objCommissionPlan;
        
        Commission__c objCommission = new Commission__c();
        objCommission.Commission_Plan__c = objCommissionPlan.Id;
        objCommission.Opportunity__c = objOpportunity.id;
        insert objCommission;
        
        update objCommission;
        
        PalmettoAPIService.sendCommissionData(new Set<Id>{objCommission.Id});
    }
}