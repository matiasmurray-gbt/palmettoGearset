trigger HomeCustomerUpdate on Opportunity ( after update)
{
    TriggerConfiguration__c objTriggerConfigurationCS = TriggerConfiguration__c.getInstance('HomeCustomerUpdate');
    if(objTriggerConfigurationCS != null && objTriggerConfigurationCS.Active__c){
        
        HomeCustomerUpdate objHandler = new HomeCustomerUpdate();
        if(trigger.isAfter && trigger.isUpdate){
            objHandler.onAfterUpdate(trigger.new, trigger.oldMap);
        } 
       
        /*
        for (Opportunity Op : Trigger.new) {
            HomeCustomerUpdate.CustomerUpdate(Op.Id);
        }   */
    }    
}