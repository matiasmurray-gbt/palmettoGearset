public class DispatchTriggerHandler {

    public static boolean firstRun = true;
    private static Boolean runTriggers = true;
    /* Method to disable triggers by setting boolean to false */
    public static void disableTriggers() { runTriggers = false; }
    /* Method to enable triggers by setting boolean to true */
    public static void enableTriggers() { runTriggers = true; }
    /* Method that returns the value of boolean to determine if trigger is run or not */
    public static Boolean triggersEnabled() { return runTriggers; }
    public class spException extends Exception {}
    public class techException extends Exception {}
    public class jobException extends Exception {}


    public static void ServiceProviderToDispatch(List<dispconn__Service_Provider__c> newList,List<dispconn__Service_Provider__c> oldList, Map<Id,dispconn__Service_Provider__c> newMap, Map<Id,dispconn__Service_Provider__c> oldMap){
        String config;
        // hardcoding this here as custom settings only allows up to 255 chars. If necessary will look later to create custom object to remove hard coding.
        if (dispconn__Dispatch_CS__c.getInstance('DISPATCH_API_PROD_OR_SANDBOX').dispconn__value__c == 'SANDBOX') {
            config = '{"organization_customer":{"app":{"enableAvailabilityForBooking":true}},"organization_dispatcher":{"app":{"enableAvailabilityForBooking":true},"notifications":{"email":{"events":{"user__created":{"templates":{"id":"d-283d7a39acc5440dae851420dfec4d0b","body":"[PALM] User Created"}}}}}},"organization_technician":{"notifications":{"email":{"events":{"user__created":{"templates":{"id":"d-283d7a39acc5440dae851420dfec4d0b","body":"[PALM] User Created"}}}}}}}';
        } else {
            config = '{"organization_customer":{"app":{"enableAvailabilityForBooking":true}},"organization_dispatcher":{"app":{"enableAvailabilityForBooking":true},"notifications":{"email":{"events":{"user__created":{"templates":{"id":"d-9d35b7f06e6247fbb8e665720bcd2d8a","body":"[PALM] User Created"}}}}}},"organization_technician":{"notifications":{"email":{"events":{"user__created":{"templates":{"id":"d-9d35b7f06e6247fbb8e665720bcd2d8a","body":"[PALM] User Created"}}}}}}}';
        }
        for(dispconn__Service_Provider__c extSP : newList) {
            extSP.dispconn__config__c = config;
        }
    }

    public static void JobToDispatch(List<Scheduling__c> newList,List<Scheduling__c> oldList, Map<Id,Scheduling__c> newMap, Map<Id,Scheduling__c> oldMap){
        if (!firstRun) { return; }
        firstRun = false;

        Set<Id> schedulingIds = new Set<Id>();
        Set<Id> jobIds = new Set<Id>();   
        Set<Id> contactIds = new Set<Id>();
        Set<Id> opportunityIds = new Set<Id>();
        Set<String> contractorIds = new Set<String>();
        map<string, string> contractors;
        List<Scheduling__c> newListRelevant = new List<Scheduling__c>();
        List<dispconn.DispatchUtils.Log> logs = new List<dispconn.DispatchUtils.Log>{};
        for(Scheduling__c wo: newList) {
            schedulingIds.add(wo.Id);
            opportunityIds.add(wo.Opportunity__c);
            jobIds.add(wo.Job__c);
            newListRelevant.add(wo);
        }
        if (newListRelevant.size() > 0 ) {
            List<Opportunity> opps = [SELECT Id, Utility__c, Preferred_Language__c, X18_Character_Opportunity_ID__c, Financing_Tool__c, Meter_Number_NGrid__c,
                                            Panel_Type__c, Inverter_1__c, Inverter_2__c, System_Size_Calculated_kW__c, Panel_Wattage__c, Number_of_Solar_Panels__c,
                                            Roof_Quality__c, Roof_Type__c, Electrical_Panel_Amperage__c, Structural_Electrical_Upgrade_Quote__c, Tree_Removal_Other_Adder__c,
                                            Trenching_Distance__c, Trenching_Adder__c, Roofing_Adder__c, Electrical_Upgrade_Adder__c, Customer_Type__c, Contact__c, 
                                            Phone_Textey__c, Work_Order_Number__c, Installation_Team__c, Location__c, StageName,
                                            (SELECT Id, Name, Part_Number__c, Part_Description__c, Quantity__c FROM BOMs__r),
                                            (SELECT Name, Url, ParentId FROM Googledocs),
                                            (SELECT Title, Body, ParentId FROM Notes WHERE IsPrivate=False) 
                                        FROM Opportunity WHERE Id IN :opportunityIds
                                        AND (StageName like '%Install Ready%' OR StageName like '%Install Scheduled%')];

            map<Id, Opportunity> mapOpps = new map<Id, Opportunity>();
            for(Opportunity o: opps) {
                contactIds.add(o.Contact__c);
                mapOpps.put(o.Id, o);
                contractorIds.add(o.Installation_Team__c);
                contractorIds.add(o.Location__c);    // for jobs, location determines the contractor
            }

            List<Job__c> jobs = new List<Job__c>();
            if (!jobIds.isEmpty()) {
                jobs = [SELECT Id, Complex_Electrical_Layout__c, AHJ__c, Structural__c, No_Satellite_Imagery__c, Rep_Request__c, Customer_Request__c,
                               Additional_Electrical_Photos_Needed__c, Additional_Structural_Photos_Needed__c, Additional_Roof_Photos_Needed__c
                        FROM Job__c WHERE Id IN :jobIds];
            }
            map<Id, Job__c> mapJobs = new map<Id, Job__c>();
            for(Job__c o: jobs) {
                mapJobs.put(o.Id, o);
            }            

            List<dispconn__Job__c> dispJobs = [SELECT Id, Ext_Job__c, dispconn__Field_Tech__c FROM dispconn__Job__c WHERE Ext_Job__c IN :schedulingIds];
            map<string, dispconn__Job__c> mapDispJobs = new map<string, dispconn__Job__c>();
            for(dispconn__Job__c j: dispJobs) {
                mapDispJobs.put(j.Ext_Job__c, j);
            }

            List<dispconn__Service_Provider__c> dispSPs = [SELECT Id, Name, dispconn__timezone2__c
                                                           FROM dispconn__Service_Provider__c 
                                                           WHERE Name IN :contractorIds];
            map<string, dispconn__Service_Provider__c> mapDispSPs = new map<string, dispconn__Service_Provider__c>();
            for(dispconn__Service_Provider__c sp: dispSPs) {
                mapDispSPs.put(sp.Name, sp);
            }
            List<Contact> contacts = [SELECT FirstName, LastName, Email, MailingStreet, MailingCity, MailingPostalCode, MailingState, MailingCountry
                                FROM Contact WHERE Id IN :contactIds];
            map<Id, Contact> mapContacts = new map<Id, Contact>(contacts);
            // Create a list for updating
            List<dispconn__Job__c> dispJobsUpdate = new List<dispconn__Job__c>();
            for (Scheduling__c extJob : newListRelevant) {
                try {
                    dispconn__Job__c dispJob;
                    dispJob = mapDispJobs.get(extJob.Id);
                    Opportunity opp = mapOpps.get(extJob.Opportunity__c);
                    if (opp == Null) {
                        throw new jobException('Opportunity not in correct stage for processing');
                    }         
                    Job__c job = mapJobs.get(extJob.Job__c);
                    Boolean hasJob = True;
                    if (job == Null) {
                        hasJob = False;
                    }
                    Boolean newJob = false;
                    if (dispJob == Null) {
                        dispJob = new dispconn__Job__c();
                        dispJob.dispconn__Status__c = 'New';
                        newJob = true;
                    }
                    dispJob.Ext_Job__c = extJob.Id;
                    dispJob.dispconn__Last_Sync_Response__c = 'Pending Sync:'+DateTime.now();
                    dispJob.dispconn__Synced__c = False;
                    dispconn__Service_Provider__c sp;
                    if (hasJob) {
                        sp = mapDispSPs.get(opp.Location__c);    
                    } else {
                        sp = mapDispSPs.get(opp.Installation_Team__c);
                    }
                    if (sp == null) {  
                        throw new jobException('Not a valid contractor. Please create the contractor under Service Providers and save again after doing so.');
                    }                        
                    dispJob.dispconn__Service_Provider__c = sp.Id;
                    String jobType = Schema.SObjectType.Scheduling__c.getRecordTypeInfosById().get(extjob.RecordTypeId).getname().split(' ')[0];

                    /* CONTACT INFO */
                    Contact contact = mapContacts.get(opp.Contact__c);
                    if (contact == null) {
                        throw new jobException('Exception: Object not linked to the job');
                    }
                    String firstName = contact.FirstName;
                    if (!String.isBlank(firstName)) {
                        dispJob.dispconn__First_Name__c = firstName.left(50);
                    }    
                    String lastName = contact.LastName;
                    if (!String.isBlank(lastName)) {
                        dispJob.dispconn__Last_Name__c = lastName.left(50);
                    }
                    String mobilePhone = opp.Phone_Textey__c;
                    if (!String.isBlank(mobilePhone)) {
                        dispJob.dispconn__Mobile__c = mobilePhone.left(14);
                    }
                    if (!String.isBlank(contact.Email)) {
                        dispJob.dispconn__Email__c = contact.Email;
                    }
                    if (hasJob) {
                        dispJob.dispconn__SF_Job_Id__c = jobType + '-' + job.Id;
                    } else {
                        dispJob.dispconn__SF_Job_Id__c = jobType + '-' + opp.X18_Character_Opportunity_ID__c;
                    }
                    /* JOB ADDRESS */
                    dispJob.dispconn__Address_Street__c      = contact.MailingStreet;
                    dispJob.dispconn__Address_City__c        = contact.MailingCity;
                    dispJob.dispconn__Address_State__c       = contact.MailingState;
                    dispJob.dispconn__Address_Postal_Code__c = contact.MailingPostalCode;

                    /* JOB TITLE */
                    dispJob.dispconn__Title__c = extJob.Name + ' (' + firstName + ' ' + lastName + ')';

                    Date serviceDate = extJob.Installation_Scheduled_Date__c;
                    if (serviceDate != null && newJob) {
                        DateTime schedDateTime = DateTime.newInstance(serviceDate,Time.newInstance(7,0,0,0));
                        schedDateTime = timeZoneOffset(sp.dispconn__timezone2__c,schedDateTime,true);
                        dispJob.dispconn__Scheduled_Date__c = schedDateTime;
                        dispJob.dispconn__Estimated_Duration__c = 3;
                    }
                    /* JOB DESCRIPTION */
                    String descr = '';
                    if (hasJob) {
                        descr += formatText('Complex Electrical Layout', String.valueOf(job.Complex_Electrical_Layout__c), True);
                        descr += formatText('AHJ', String.valueOf(job.AHJ__c), True);
                        descr += formatText('Structural', String.valueOf(job.Structural__c), True);
                        descr += formatText('No Satellite Imagery', String.valueOf(job.No_Satellite_Imagery__c), True);
                        descr += formatText('Rep Request', String.valueOf(job.Rep_Request__c), True);
                        descr += formatText('Customer Request', String.valueOf(job.Customer_Request__c), True);
                        descr += formatText('Additional Electrical Photos Needed', String.valueOf(job.Additional_Electrical_Photos_Needed__c), True);
                        descr += formatText('Additional Structural Photos Needed', String.valueOf(job.Additional_Structural_Photos_Needed__c), True);
                        descr += formatText('Additional Roof Photos Needed', String.valueOf(job.Additional_Roof_Photos_Needed__c), True);
                        descr += blankIfNull(extJob.Installation_Notes__c) + '\n\n';
                        descr += formatText('Utility Provider', opp.Utility__c, True);
                        descr += formatText('Preferred Language', opp.Preferred_Language__c, True);
                        descr += formatText('Work Order #', opp.Work_Order_Number__c, True);
                        descr += formatText('Panel Type', opp.Panel_Type__c, True);
                        descr += formatText('Inverter 1', opp.Inverter_1__c, True);
                        descr += formatText('Inverter 2', opp.Inverter_2__c, True);
                        descr += formatText('System Size Calculated (kW)', String.valueOf(opp.System_Size_Calculated_kW__c), True);
                        descr += formatText('Panel Wattage', String.valueOf(opp.Panel_Wattage__c), True);
                        descr += formatText('Number of Solar Panels', String.valueOf(opp.Number_of_Solar_Panels__c), True);
                    } else {
                        descr += blankIfNull(extJob.Installation_Notes__c) + '\n\n';
                        //descr += formatText('Notes', extJob.Site_Survey_Notes__c, True);
                        descr += formatText('Utility Provider', opp.Utility__c, True);
                        descr += formatText('Preferred Language', opp.Preferred_Language__c, True);
                        descr += formatText('Work Order #', opp.Work_Order_Number__c, True);
                        descr += formatText('Financing Tool', opp.Financing_Tool__c, True);
                        descr += formatText('Meter Number (Ngrid)', opp.Meter_Number_NGrid__c, True);
                        descr += formatText('Panel Type', opp.Panel_Type__c, True);
                        descr += formatText('Inverter 1', opp.Inverter_1__c, True);
                        descr += formatText('Inverter 2', opp.Inverter_2__c, True);
                        descr += formatText('System Size Calculated (kW)', String.valueOf(opp.System_Size_Calculated_kW__c), True);
                        descr += formatText('Panel Wattage', String.valueOf(opp.Panel_Wattage__c), True);
                        descr += formatText('Number of Solar Panels', String.valueOf(opp.Number_of_Solar_Panels__c), True);
                        descr += formatText('Roof Quality', opp.Roof_Quality__c, True);
                        descr += formatText('Roof Type', opp.Roof_Type__c, True);
                        descr += formatText('Electrical Panel Amperage', String.valueOf(opp.Electrical_Panel_Amperage__c), True);
                        descr += formatText('Trenching Distance', String.valueOf(opp.Trenching_Distance__c), True);
                        descr += formatText('Structural Upgrade Adder', String.valueOf(opp.Structural_Electrical_Upgrade_Quote__c), True);
                        descr += formatText('Tree Removal Adder', String.valueOf(opp.Tree_Removal_Other_Adder__c), True);
                        descr += formatText('Trenching Adder', String.valueOf(opp.Trenching_Adder__c), True);
                        descr += formatText('Roofing Adder', String.valueOf(opp.Roofing_Adder__c), True);
                        descr += formatText('Electrical Upgrade Adder', String.valueOf(opp.Electrical_Upgrade_Adder__c), True);
                    }

                    descr += '\n\n### BOMs:';
                    if (opp.BOMs__r.size() > 0) {
                        descr += '\n\nName | Part # | Desc | Qty ';
                        descr +=   '\n---- | ------ | ---- | :-:';                            
                        for (BOM__c BOM : opp.BOMs__r) {
                            descr += '\n'+ blankIfNull(BOM.Name) + ' | '
                            + blankIfNull(BOM.Part_Number__c) + ' | '
                            + blankIfNull(BOM.Part_Description__c) + ' | '
                            + String.valueOf(BOM.Quantity__c);
                        }
                    }

                    if (opp.Googledocs.size() > 0) {
                        descr += '\n\n### Docs:';
                        for (Googledoc note: opp.Googledocs) {
                            descr += '\n* [' + note.Name + ']('+note.Url +')\n';    
                        }
                    }

                    if (opp.Notes.size() > 0) {
                        descr += '\n\n### Notes:';
                        for (Note note: opp.Notes) {
                            descr += '\n* ' + note.Body +'\n';    
                        }
                    }                    

                    dispJob.dispconn__Description__c = descr;

                    /* SERVICE TYPE */
                    if (!String.isBlank(opp.Customer_Type__c)) {
                            dispJob.dispconn__Service_Type__c = jobType;
                    }
                    dispJob.dispconn__Custom_Fields__c = '{"'+jobType+'":"true"}';

                    if (oldMap == null || extJob.Status__c != oldMap.get(extJob.Id).Status__c) {
                        if (extJob.Status__c == 'Completed') { 
                            dispJob.dispconn__Status__c = 'Completed';
                        } else if (extJob.Status__c == 'Canceled') { 
                            dispJob.dispconn__Status__c = 'Canceled';
                        } 
                    } 
                    dispJobsUpdate.add(dispJob);
                } catch (jobException e) {
                    System.debug('Dispatch: '+e.getMessage());
                    log('info', 'job', e.getMessage(), extJob, logs);
                }
            }
            if (!dispJobsUpdate.isEmpty()) {
                upsert dispJobsUpdate;
            }
        }
        if (!logs.isEmpty()) {
            dispconn.DispatchUtils.writeLog(logs);
        }
    }

    public static void NoteFromToDispatch(List<Note> newList){
        if (!firstRun) { return; }
        firstRun = false;
        
        // Gather Note Parent Ids for Dispatch Jobs
        map<string, Note> mapNotes = new map<string, Note>();
        for(Note nte: newList) {
            if (nte.Id != Null && nte.ParentId != Null) {
                Schema.sObjectType entityType = nte.parentId.getSObjectType();
                if (entityType == dispconn__Job__c.sObjectType) {
                    mapNotes.put(nte.ParentId, nte);
                }
            }
        }
        // Get Dispatch Job records based on Note Parent Ids
        List<dispconn__Job__c> dispatchJobs = [SELECT Id, Ext_Job__c FROM dispconn__Job__c WHERE Id IN :mapNotes.KeySet()];
        // Create a list for Inserting
        List<Note> noteList = new List<Note>();
        // Create Note records for mapped object
        for(dispconn__Job__c dj: dispatchJobs) {
            Note sourceNote = mapNotes.get(dj.Id);
            Note n = new Note();
            n.ParentId = dj.Ext_Job__c;
            n.Title = sourceNote.Title;
            n.Body = sourceNote.Body;
            noteList.add(n);
        }
        if(noteList.size() > 0) {
            insert noteList;
        }
    }

    public static void OpportunityToDispatch(Map<Id,Opportunity> newMap){
        List<Scheduling__c> scheduleUpdateList = new List<Scheduling__c>();
        List<Opportunity> opps = [SELECT Id, (SELECT Id FROM Scheduling__r) FROM Opportunity WHERE Id IN :newMap.keySet()];
        for(Opportunity opp : opps) {
            for (Scheduling__c schedule : opp.scheduling__r) {
                scheduleUpdateList.add(new Scheduling__c(Id=schedule.Id, Schedule_Updated__c = DateTime.now()));
            }
        }
        if(scheduleUpdateList.size() > 0) {
            update scheduleUpdateList;
        }
    }

    public static void BOMToDispatch(List<BOM__c> newList, List<BOM__c> oldList, Boolean isDelete){
        List<BOM__c> m = newList;
        if (isDelete) {
            m = oldList;
        }
        Set<Id> opportunityIds = new Set<Id>();
        for(BOM__C bom: newList) {
            opportunityIds.add(bom.Opportunity__c);
        }
        List<Scheduling__c> scheduleUpdateList = new List<Scheduling__c>();
        List<Opportunity> opps = [SELECT Id, (SELECT Id FROM Scheduling__r) FROM Opportunity WHERE Id IN :opportunityIds];
        for(Opportunity opp : opps) {
            for (Scheduling__c schedule : opp.scheduling__r) {
                scheduleUpdateList.add(new Scheduling__c(Id=schedule.Id, Schedule_Updated__c = DateTime.now()));
            }
        }
        if(scheduleUpdateList.size() > 0) {
            update scheduleUpdateList;
        }
    }

    public static void JobFromDispatch(List<dispconn__Job__c> newList,List<dispconn__Job__c> oldList, Map<Id,dispconn__Job__c> newMap, Map<Id,dispconn__Job__c> oldMap){
        if (!firstRun) { return; }
        firstRun = false;
        Set<Id> dispJobIds = new Set<Id>();
        for(dispconn__Job__c j: newList) {
            dispJobIds.add(j.Id);
        }        
        map<Id, dispconn__Job__c> mapDispJobs;
        List<dispconn__Job__c> dispJobs = [SELECT Ext_Job__r.Job__c, dispconn__Service_Provider__r.dispconn__timezone2__c
                                           FROM dispconn__Job__c WHERE Id IN :dispJobIds];
        mapDispJobs = new map<Id, dispconn__Job__c>(dispJobs);

        List<Scheduling__c> extSchedulingsUpdate = new List<Scheduling__c>();
        List<Job__c> extJobsUpdate = new List<Job__c>();
        for(dispconn__Job__c dispJob: newList) {
            Scheduling__c extScheduling = new Scheduling__c(Id=dispJob.Ext_Job__c);

            if (dispJob.dispconn__Status__c == 'Paused') {
                extScheduling.Status__c = 'Paused';
            } 
            else if (dispJob.dispconn__Status__c == 'Completed') { 
                if (dispJob.dispconn__Completed_Time__c != oldMap.get(dispJob.Id).dispconn__Completed_Time__c) { 
                    extScheduling.Status__c = 'Completed';
                    extScheduling.Installation_Completed_Date__c = Date.valueOf(dispJob.dispconn__Completed_Time__c);
                }  
            }  
            else if (dispJob.dispconn__Scheduled_Date__c != oldMap.get(dispJob.Id).dispconn__Scheduled_Date__c) { 
                extScheduling.Status__c = 'Scheduled'; 
                extScheduling.Installation_Scheduled_Date__c = Date.valueOf(dispJob.dispconn__Scheduled_Date__c);
                dispconn__job__c dispJobAddtl = mapDispJobs.get(dispJob.Id);
                Job__c extJob;
                if (dispJobAddtl.Ext_Job__r.Job__c != Null) {
                    extJob = new Job__c(Id=dispJobAddtl.Ext_Job__r.Job__c);
                    extJob.Physical_Site_Survey_Schedule_Date__c = Date.valueOf(dispJob.dispconn__Scheduled_Date__c);
                    extJob.Physical_Site_Survey_Time__c = timeZoneOffset(dispJob.dispconn__Service_Provider__r.dispconn__timezone2__c,dispJob.dispconn__Scheduled_Date__c,false).time();
                    extJobsUpdate.add(extJob);
                }                
            }
            else if (dispJob.dispconn__Status__c != oldMap.get(dispJob.Id).dispconn__Status__c) { 
                extScheduling.Status__c = dispJob.dispconn__Status__c; 
            }            
            extSchedulingsUpdate.add(extScheduling);
        }
        if (!extSchedulingsUpdate.isEmpty()) {
            upsert extSchedulingsUpdate;
        }
        if (!extJobsUpdate.isEmpty()) {
            upsert extJobsUpdate;
        }        
    }
    
    private static void log(String level, String entity, String message, Scheduling__c wo, List<dispconn.DispatchUtils.Log> logs) {
        logs.add(new dispconn.DispatchUtils.Log(level,entity,'map','To Dispatch:'+wo.Id+'/'+wo.Name + ' ' + message));
    }

    private static String formatText(String title, String value, Boolean newLine) {
        return '* **' + title + '**: ' + blankIfNull(value) + (newLine ? '\n\n' : '');
    }

    private static String blankIfNull(String value) {
        return (!String.isBlank(value) ? value : '');
    }

    private static DateTime timeZoneOffset(String tz, DateTime dt, Boolean toDispatch) {
        Integer direction = (toDispatch ? 1:-1);
        Integer millisecs = UserInfo.getTimeZone().getOffset(dt); // default time zone offset 
        try {
            millisecs -= Timezone.getTimeZone(tz).getOffset(dt);  // shift by location time zone
        } catch (Exception e) {
            // not set up default to EST
            millisecs -= Timezone.getTimeZone('America/New_York').getOffset(dt);
        }
        return dt.addSeconds((millisecs/1000)*direction);
    }
    
    
}