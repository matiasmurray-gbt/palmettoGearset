@isTest(seeAllData=true)
private class ServiceAgreementHandlerTest
{
    static testMethod void unitTest(){
        Vendor__c objVendor = new Vendor__c();
        objVendor.Name = 'Test';
        objVendor.Stage__c = 'Account Approved';
        objVendor.Email__c = 'test@test.com';
        objVendor.Mobile__c = '1234567899';
        insert objVendor;
        
        Service_Agreement__c objServiceAgreement = new Service_Agreement__c();
        objServiceAgreement.Vendor__c = objVendor.Id;
        insert objServiceAgreement;
        Test.startTest();
        try{
            objServiceAgreement.Active_MSA_Flag__c = true;
            update objServiceAgreement;
            
            new ServiceProviderHandler().onAfterInsert(null);
        } catch(Exception e){}
        Test.stopTest();
    }
}