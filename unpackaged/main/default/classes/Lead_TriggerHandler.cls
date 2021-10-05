public class Lead_TriggerHandler {
    public static void leadConversion(list<Lead> Ld)
    {
        system.debug('TESTING');
        boolean isFirstRun = true;
        LeadStatus convertStatus = [select MasterLabel from LeadStatus where IsConverted = true and MasterLabel = 'Convert' ];
       List<Database.LeadConvert> leadConverts = new List<Database.LeadConvert>();
        if (isFirstRun == true){
            system.debug('FIRSTRUN' +isFirstRun);
        for(Lead newleads : Ld)
        {
            if(!newleads.isConverted && newleads.Status == 'Convert' && newleads.Test_Account__c == false) 
            {
                Database.LeadConvert lc = new database.LeadConvert();
                string AccName = newleads.Name;
                lc.setLeadId(newleads.Id);
                lc.setConvertedStatus(convertStatus.MasterLabel);
                leadConverts.add(lc);
                system.debug('Counts InsideTriggerCounts');
            }
        }
             isFirstRun = false;
        }    
           
        if (!leadConverts.isEmpty()) {
          List<Database.LeadConvertResult> lcr = Database.convertLead(leadConverts);
            system.debug('CONVERSION Point');
     }
            
    }
}