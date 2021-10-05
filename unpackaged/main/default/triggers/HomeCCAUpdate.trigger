trigger HomeCCAUpdate on User (after insert, after update) {
    System.debug('hello ------------------ user profile photo');  
    for (User u : Trigger.new) 
    {
        HomeCCAUpdate.CCAUpdate(u.Id);
       
        System.debug('u.Id');       
    }   

}