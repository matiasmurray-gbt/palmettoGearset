@isTest
private Class Account_Test {
    static testMethod void Test_Account()
    {
        Account Test = New Account(
            Name = 'TestAccount',
            Referral_Code__c = '23453',
            Referral_By_Code__c = '12345'
        );
        insert Test;
        Account Test2 = New Account(
            Name = 'TestAccount2',
            Referral_Code__c = '25438',
            Referral_By_Code__c = '23453'
        );
        insert Test2;
        Test2 = [select Name,Referral_Code__c,Referral_By_Code__c,Accountreferral__c from Account where Id =:Test2.id];
        //system.assertEquals(Test2.Accountreferral__c, Test.Id)
        
    }
    
}