trigger Lead_Trigger on Lead (before insert, after insert, after update) 
{
    LeadHandler objHandler = new LeadHandler();
    if(trigger.isBefore && trigger.isInsert)
        objHandler.onBeforeInsert(trigger.new);
    if(trigger.isAfter && trigger.isInsert)
        objHandler.onAfterInsert(trigger.new);
    if(trigger.isAfter && trigger.isUpdate)
        objHandler.onAfterUpdate(trigger.new, trigger.oldMap);
    
    /*
    for(Lead L:trigger.new)
    {
        if(L.status == 'Convert' && L.IsConverted == False){
            Lead_TriggerHandler.leadConversion(Trigger.new);
            system.debug('TriggerStart');
         }
    }*/
}