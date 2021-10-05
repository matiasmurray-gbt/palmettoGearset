public class Account_TriggerHandler {
    public static void AccountRefferal(list<Account> Acct)
    {
        Map<String, Id> AccountMap = new Map<String, Id>();         
        for(Account acmap : [select Referral_Code__c,id from Account where Referral_Code__c != ''])
        {
            AccountMap.put(acmap.Referral_Code__c,acmap.Id);
        }
        for(Account newac : Acct)
        {
            if(AccountMap.containskey(newac.Referral_By_Code__c) && newac.Referral_By_Code__c != '')
            {
                newac.Accountreferral__c = AccountMap.get(newac.Referral_By_Code__c);
            }
        }
    }
}