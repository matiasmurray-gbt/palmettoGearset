@isTest
private class LeadHandlerTest
{
    static testMethod void unitTest(){
        Id buildOnlyLeadId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Build Only').getRecordTypeId();
        Lead objLead = new Lead();
        objLead.FirstName = 'test';
        objLead.LastName = 'test';
        objLead.Email = 'test@test.com';
        objLead.Company = 'X';
        objLead.Scope_of_Work__c = 'Installation';
        objLead.RecordTypeId = buildOnlyLeadId;
        insert objLead;
    }
}