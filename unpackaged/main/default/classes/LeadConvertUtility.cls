public class LeadConvertUtility {

    public static Set<Id> cLeadIds = New Set<Id>();
    
    public static void convertSalesRabitLeads(Map<Id,Lead> cLeads){
        List<Database.LeadConvert> conLeads = new List<Database.LeadConvert>();
        LeadStatus convertStatus = [select MasterLabel from LeadStatus where IsConverted = true limit 1];
        //loop through map an dmake sure this isnt recursive for some reason
        for(Id key : cLeads.keyset()){
           if(cLeadIds.contains(key)){
                system.debug('found a duplicate : ' + key);
                cLeads.remove(key);
           }
        }
        //loop through map and build out new leadconvert objects
        for(Id key : cLeads.keyset()){
            cLeadIds.add(key);
            Database.LeadConvert lc = new Database.LeadConvert();
            String optyName = cLeads.get(key).Name;
            lc.setLeadId(key);
            lc.setOpportunityName(optyName);
            lc.setConvertedStatus(convertStatus.MasterLabel);           
            conLeads.add(lc);
                
        }
        //check to see if list is not empty and then convert leads
        if (!conLeads.isEmpty()) {
          List<Database.LeadConvertResult> lcr = Database.convertLead(conLeads);
          if(lcr != null){
              system.debug('Leads converted : ');
              system.debug(lcr);
          }
        }
        
        
    }
}