trigger leadEvent on Lead (after insert, after update) {
    
       Map<Id,Lead> cLeadMap = New Map<Id,Lead>();
    if(trigger.isInsert){
        Set<Lead> leadList = New Set<Lead>();

        //Collect all non converted leads who have an appointment date time that exists in the future
        for(Lead l : Trigger.new) {
            if (!l.IsConverted && l.Appointment_Date_and_Time__c != null && l.Appointment_Date_and_Time__c > System.Now()){
              leadList.add(l);
            }
            //Added code to check if  Sales Rabbit Date is set and then convert
            if(!l.isConverted && l.Sales_Rabbit_Date_Created__c != null){
                cLeadMap.put(l.Id, l);
            }
        }
        //pass the valid leads to a class to handle creating events for those leads
        if(!leadList.isEmpty()){
            LeadEventUtility.insertEvntforLeads(leadList);        
        }
    }else if(trigger.isUpdate){
        //Build map of Leads and Id's that meet our criteria
        Map<Id,Lead> uleadMap = New Map<Id,Lead>();
        
        for(Lead l : Trigger.new) {
            if ((!l.IsConverted && l.Appointment_Date_and_Time__c != null && l.Appointment_Date_and_Time__c > System.Now())){
                uleadMap.put(l.Id,l);
            }
            //Added code to check if  Sales Rabbit Date is set and then convert
            //may be issues with time dependent workflow rules on leads with emails 
            if(!l.isConverted && l.Sales_Rabbit_Date_Created__c != null){
                cLeadMap.put(l.Id, l);
            }
        }
        
        //Send New Criteria Map to Trigger and trigger.oldmap
        if(!uleadMap.isEmpty()){
            LeadEventUtility.updateEvntforLeads(uleadMap,trigger.oldMap);        
        }
        if(!cLeadMap.isEmpty()){
            //convert leads here
            LeadConvertUtility.convertSalesRabitLeads(cLeadMap);
        }
    }
    
    
}