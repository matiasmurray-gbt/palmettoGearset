@isTest
private Class Lead_Test 
{
    static testMethod void Test_LeadConvert(){
        Lead testLead = new Lead(
            FirstName='Demo10',
            LastName = 'Demo10 UnitTest',
            Email = 'test@gmail.com',
            Status='Open',
            company='x',
            street='1211 E I-40 Service Rd',
            city='Columbus',
            State='Ohio',
            Country = 'United States',
            LeadSource = '3rd Party Provider',
            Sub_Market__c = 'Atlanta',
            Utility_Provider__c = 'A & N Electric Coop',
            Appointment_Date__c = date.ValueOf('2019-03-09')
        );
        insert  testLead;
        testlead.Status = 'Convert';
        update testLead;
    }
}