trigger AccountTeamMemberTrigger on AccountTeamMember (after insert, after update, after delete) {
    AccountTeamMemberHandler objHandler = new AccountTeamMemberHandler();
    if(Trigger.isAfter){
        if(Trigger.isInsert){
            objHandler.onAfterInsert(Trigger.new);
        }else if(Trigger.isUpdate){
            objHandler.onAfterUpdate(Trigger.new,Trigger.oldMap);
        }else if(Trigger.isDelete){
            objHandler.onAfterDelete(Trigger.old);
        }
    }
}