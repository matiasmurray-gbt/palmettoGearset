trigger Account_Trigger on Account(before insert, after insert, before update, after update,before delete, after delete) 
{
    
    if (trigger.isBefore) 
    {
        if (trigger.isUpdate || trigger.isInsert) 
        {
         Account_TriggerHandler.AccountRefferal(Trigger.new);   
        } 
        
    }
}