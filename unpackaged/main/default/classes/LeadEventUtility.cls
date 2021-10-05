public class LeadEventUtility {

    //public static method for creating events for valid leads, used to stop trigger recursion
    public static Set<Id> tLeads = New Set<Id>();
    
    public static void insertEvntforLeads(Set<lead> nleads){

        List<event> leadEvents = New List<event>();
        //loop through the leads and create an event for each
        Event e;
        for (lead l : nleads) {
            e = new Event();
            String Subject = (l.FirstName != null) ? 'Meeting with ' + l.FirstName + ' ' + l.LastName : 'Meeting with ' + l.LastName;
            e.StartDateTime = l.Appointment_Date_and_Time__c;
            e.EndDateTime = l.Appointment_Date_and_Time__c.addHours(1);
            e.Subject = Subject;
            e.WhoId = l.id;
            e.OwnerId = l.OwnerId;
            leadEvents.add(e);
            //due to recursion add the lead id to s static variable Set
            tLeads.add(l.Id);
        }
        

        insert leadEvents;
        
    }
    
    public static void updateEvntforLeads(Map<Id,Lead> uleads, Map<Id,Lead> oLeads){


        List<Id> ownrIds = New List<Id>();
        List<Event> eventList = New List<Event>();
        Map<Id,List<Event>> eventOmap = New Map<Id,List<Event>>();
        //loop through update list and remove any leads who have been processed in this trigger context
        for(Id key : uleads.keyset()){
           if(tLeads.contains(key)){
                uLeads.remove(key);
           }
        }
        //add the owner ids to lists
        for(Id key : uleads.keyset()){
            ownrIds.add(uleads.get(key).OwnerId);
        }    
        

        for(event e : [Select Id, StartDateTime, EndDateTime, Subject, WhoId, OwnerId from Event where WhoId in : uleads.keyset() and OwnerId in : ownrIds]){
            //build a map of events for each lead, lead id is the key
            if(!eventOmap.containsKey(e.OwnerId)){
                eventOmap.put(e.WhoId, New List<Event>{e});
            }else{
                eventOmap.get(e.WhoId).add(e);
            }
        }

        Event nEvent;
        //loop through the lead map and then through the events and compare them, if there is not an event match, create a new one
        for(Id key : uleads.keyset()){            
                if(eventOmap.containsKey(key) && oLeads.get(key).Appointment_Date_and_Time__c != null){
                    for(event e : eventOmap.get(key)){
                        if((e.WhoId == key) && (e.StartDateTime == oLeads.get(key).Appointment_Date_and_Time__c) && (e.OwnerId == uleads.get(key).ownerId)){
                            e.StartDateTime = uLeads.get(key).Appointment_Date_and_Time__c;
                            e.EndDateTime = uLeads.get(key).Appointment_Date_and_Time__c.addHours(1);
                            eventList.add(e);
                        }else{
                            String Subject = (uleads.get(key).FirstName != null) ? 'Meeting with ' + uleads.get(key).FirstName + ' ' + uleads.get(key).LastName : 'Meeting with ' + uleads.get(key).LastName;
                            nEvent = new Event();
                            nEvent.StartDateTime = uLeads.get(key).Appointment_Date_and_Time__c;
                            nEvent.EndDateTime = uLeads.get(key).Appointment_Date_and_Time__c.addHours(1);
                            nEvent.Subject = Subject;
                            nEvent.WhoId = key;
                            nEvent.OwnerId = uleads.get(key).OwnerId;
                            eventList.add(nEvent);
                        }
                    }
                }else{
                            String Subject = (uleads.get(key).FirstName != null) ? 'Meeting with ' + uleads.get(key).FirstName + ' ' + uleads.get(key).LastName : 'Meeting with ' + uleads.get(key).LastName;
                            nEvent = new Event();
                            nEvent.StartDateTime = uLeads.get(key).Appointment_Date_and_Time__c;
                            nEvent.EndDateTime = uLeads.get(key).Appointment_Date_and_Time__c.addHours(1);
                            nEvent.Subject = Subject;
                            nEvent.WhoId = key;
                            nEvent.OwnerId = uleads.get(key).OwnerId;
                            eventList.add(nEvent);
                }    
        }

        upsert eventList;
        
    }

}