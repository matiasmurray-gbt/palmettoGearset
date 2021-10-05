@isTest
private class DispatchTests
{
    
    public static void productionSettings(String dispatchMethod) {
        Map<String,String> newSettings = new Map<String,String>();
        newSettings.put('DISPATCH_API_PROD_OR_SANDBOX','PRODUCTION');
        newSettings.put('DISPATCH_API_CLIENT_SECRET', 'asdf');
        newSettings.put('DISPATCH_API_CLIENT_ID', 'dsaf');
        newSettings.put('DISPATCH_API_PASSWORD','asfed');
        newSettings.put('DISPATCH_API_WEBHOOK_DEBUG','ON');
        newSettings.put('INTEGRATION_USER_DOMAIN','example.com');
        newSettings.put('DISPATCH_ASSIGN_METHOD', dispatchMethod);
        newSettings.put('LOGGING_KEY', 'xxx');
                
        system.assertNotEquals(newSettings, null);
        Map<String, dispconn__Dispatch_CS__c> settings = dispconn__Dispatch_CS__c.getall();
        List<dispconn__Dispatch_CS__c> updates = new List<dispconn__Dispatch_CS__c>();
        for (String key : newSettings.keySet()) {
            dispconn__Dispatch_CS__c setting = new dispconn__Dispatch_CS__c(Name=key);
            if (settings.containsKey(key)) {
              setting = settings.get(key);
            }
          setting.dispconn__Value__c = newSettings.get(key);
          updates.add(setting);
        }
        upsert updates;
    } 

    public static Account createAccount() {
        Account a = new Account(Name='ABC Corp',
                                BillingStreet='1 Beacon St',
                                BillingState='Massachusetts',
                                BillingCity='Boston',
                                BillingPostalCode='03312');
        //a.RecordTypeId = [SELECT Id FROM RecordType WHERE DeveloperName = 'PersonAccount'].Id;
        system.assertNotEquals(a, null);
        return a;       
    }

    public static Contact createContact(String accountId) {
        Contact o = new Contact(AccountId=accountId,
                                FirstName='John',
                                LastName='Davis',
                                Email = 'customer@abc.com',
                                MailingStreet='1 Beacon St',
                                MailingState='Massachusetts',
                                MailingCity='Boston',
                                MailingPostalCode='03312');
        system.assertNotEquals(o, null);
        return o;       
    }

    public static dispconn__Service_Provider__c createServiceProvider(String name, String phone, String email) {
        dispconn__Service_Provider__c o = new dispconn__Service_Provider__c(name=name,
                                dispconn__Email__c = email,
                                dispconn__Phone__c = phone,
                                dispconn__TimeZone2__c = 'America/New_York'
                                );
        system.assertNotEquals(o, null);
        return o;
    }

    public static Opportunity createOpportunity(String accountId, String contactId, String team) {
        Date d = Date.today();
        Opportunity o = new Opportunity(
                        Name='Test Opp',
                        CloseDate=d,
                        AccountId=accountId,
                        Contact__c=contactId,
                        Installation_Team__c=team,
                        Preferred_Language__c='English',
                        StageName='17. Install Ready',
                        Installation_Start_Date__c=d,
                        Install_Ready_Date__c=d
        );
        system.assertNotEquals(o, null);
        return o;
    }

    public static BOM__c createBOM(String partNum, String oppId) {
        Date d = Date.today();
        BOM__c o = new BOM__c(
                        Part_Description__c='desc',
                        Part_Number__c=partNum,
                        Quantity__c=1,
                        Opportunity__c=oppId
        );
        system.assertNotEquals(o, null);
        return o;
    }

    public static Googledoc createGoogleDoc(String oppId) {
        Date d = Date.today();
        Googledoc o = new Googledoc(
                        Name='name',
                        Url='https://url',
                        ParentId=oppId
        );
        system.assertNotEquals(o, null);
        return o;
    }    


    public static Scheduling__c createScheduling(String oppId) {
        Date d = Date.today();
        Scheduling__c o = new Scheduling__c(
                        Name='Test Scheduling',
                        Opportunity__c=oppId,
                        Installation_Scheduled_Date__c=d,
                        RecordTypeId=Schema.SObjectType.Scheduling__c.getRecordTypeInfosByName().get('Installation Job').getRecordTypeId()
        );
        system.assertNotEquals(o, null);
        return o;
    }    

    public static Note createNote(String parentId,String title) {
        Note a = new Note(Title=title,
                        Body=title,
                        ParentId=parentId);
        system.assertNotEquals(a, null);
        system.debug('*** Notes: '+title);
        return a;
    }    
   
    static void resetTriggerForTest() {
        DispatchTriggerHandler.firstRun = true;  
    }

    @isTest
    static void EndToEnd()
    {
        productionSettings('TECHASSIGN');
        dispconn__Service_Provider__c serviceProvider = createServiceProvider('Eagle', '5552321244', 'customer@abc.com');
        insert serviceProvider;
        Account account = createAccount();
        insert account;
        Contact contact = createContact(account.Id);
        insert contact; 

        Opportunity opp = createOpportunity(account.Id, contact.Id, serviceProvider.Name);
        insert opp;

        BOM__c bom = createBOM('part1', opp.Id);
        insert bom;
        Note note = createNote(opp.Id,'Opp note');
        insert note;

        resetTriggerForTest();
        Scheduling__c extJob = createScheduling(opp.Id);
        insert(extJob);

        dispconn__Job__c dispJob = [select Id, Ext_Job__c from dispconn__Job__c WHERE Ext_Job__c =: extJob.Id];
        system.assertEquals(dispJob.Ext_Job__c, extJob.Id);

        resetTriggerForTest();
        extJob.Status__c = 'Completed';
        update extJob;
        dispJob = [select Id, dispconn__Status__c from dispconn__Job__c WHERE Ext_Job__c =: extJob.Id];
        system.assertEquals('Completed', dispJob.dispconn__Status__c);

        resetTriggerForTest();
        extJob.Status__c = 'Canceled';
        update extJob;
        dispJob = [select Id, dispconn__Status__c from dispconn__Job__c WHERE Ext_Job__c =: extJob.Id];
        system.assertEquals('Canceled', dispJob.dispconn__Status__c);

        // Test update parent opp
        opp.panel_wattage__c = 11;
        update opp;

        // Test update bom on parent
        bom = createBOM('part2', opp.Id);
        insert bom;
       
        // now test updates coming back from Dispatch
        resetTriggerForTest();
        dispJob.dispconn__Scheduled_Date__c = DateTime.now(); 
        update dispJob;
        extJob = [select Id, Status__c from Scheduling__c WHERE Id =: extJob.Id];
        system.assertEquals('Scheduled', extJob.Status__c);

        resetTriggerForTest();
        dispJob.dispconn__Status__c = 'Enroute'; 
        update dispJob;
        extJob = [select Id, Status__c from Scheduling__c WHERE Id =: extJob.Id];
        system.assertEquals('Enroute', extJob.Status__c);
        

        resetTriggerForTest();
        dispJob.dispconn__Status__c = 'Started'; 
        update dispJob;
        extJob = [select Id, Status__c from Scheduling__c WHERE Id =: extJob.Id];
        system.assertEquals('Started', extJob.Status__c);

        resetTriggerForTest();
        dispJob.dispconn__Status__c = 'Completed';
        dispJob.dispconn__Completed_Time__c = DateTime.now(); 
        update dispJob;
        extJob = [select Id, Status__c from Scheduling__c WHERE Id =: extJob.Id];
        system.assertEquals('Completed', extJob.Status__c);        

        resetTriggerForTest();
        dispJob.dispconn__Status__c = 'Paused';
        update dispJob;
        extJob = [select Id, Status__c from Scheduling__c WHERE Id =: extJob.Id];
        system.assertEquals('Paused', extJob.Status__c); 

        resetTriggerForTest();
        dispJob.dispconn__Status__c = 'Canceled';
        update dispJob;
        extJob = [select Id, Status__c from Scheduling__c WHERE Id =: extJob.Id];
        system.assertEquals('Canceled', extJob.Status__c);          

        resetTriggerForTest();
        Note dispNote = createNote(dispJob.Id,'field note');
        insert dispNote;

    }

}