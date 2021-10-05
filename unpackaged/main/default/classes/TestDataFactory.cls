@isTest
public class TestDataFactory 
{	
	public static Opportunity createOpportunity(string reportTypeId,string opp_name,string account_id,string stage,string location)
    {
        Opportunity opp_obj = new Opportunity();
        opp_obj.RecordTypeId = reportTypeId;
        opp_obj.Name = opp_name;
        opp_obj.AccountId = account_id;
        opp_obj.StageName = stage;
        opp_obj.Location__c = location;
        opp_obj.CloseDate = system.Date.today() + 2;
        return opp_obj;
        
    }
    
    public static Account createAccount(string name, string recordType)
    {
        account acc_obj = new Account();
        acc_obj.Name = name;
        acc_obj.RecordTypeId = recordType;
        return acc_obj;
    }
    
    public static Contact createContact(string first_name, string last_name,string account_id)
    {
        Contact cont_obj = new Contact();
    	cont_obj.FirstName = first_name;
        cont_obj.LastName = last_name;
        cont_obj.AccountId = account_id;
        return cont_obj;
    }
    
    public static Commission_Plan__c createCommissionPlan(string name)
    {
        Commission_Plan__c commission_plan_obj = new Commission_Plan__c();
        commission_plan_obj.Name = name;
        return commission_plan_obj;
    }
    
    public List< User > createUsers( integer count )
    {
        system.assert( count > 0 );
        List< User > userList = new List< User >();
        Profile stdProfile = [ select id from profile where name= 'System Admin - Developer' ];
        while( count-- > 0 )
        {
            userList.add( new User( ProfileId = stdProfile.Id, Alias = 'u' + count, IsActive = true, username = 'u@test.com' + count, email = 'u@test.com' + count, LastName = 'u' + count,TimeZonesIdKey = 'GMT', EmailEncodingKey = 'UTF-8', LanguageLocaleKey='en_US', LocalesIdKey = 'en_US' ) );
        }
        insert userList;
        return userList;
    }
}