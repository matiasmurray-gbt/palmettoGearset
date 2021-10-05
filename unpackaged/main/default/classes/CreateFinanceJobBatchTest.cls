@isTest
private class CreateFinanceJobBatchTest
{
    static testMethod void unitTest(){
        Id designSalesId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('3rd Party - Design Sales').getRecordTypeId();
        Account objAccount = TestDataFactory.createAccount('Test Acc', designSalesId);
        objAccount.celigo_sfnsio__Account_Balance__c = 100;
        insert objAccount;
         
        Id designSalesOppId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('3rd Party - Design Sales').getRecordTypeId();
        Opportunity objOpp = TestDataFactory.createOpportunity(designSalesOppId, 'Test opp', objAccount.Id, '12. Install Complete' , 'NY');
        objOpp.Installation_Complete_Date__c = Date.today();
        objOpp.Contract_Received_Date__c = Date.today();
        objOpp.Financing_Tool__c = 'Loanpal';
        insert objOpp;
        
        Database.executeBatch(new CreateFinanceJobBatch());
    }
}