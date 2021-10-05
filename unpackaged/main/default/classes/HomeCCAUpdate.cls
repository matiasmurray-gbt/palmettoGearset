global class HomeCCAUpdate{
  @future (callout=true)
   public static void CCAUpdate(id userId) {
   try
   {   
   
       // kalidass
        User userData=[select MobilePhone,FullPhotoUrl,Email  from User where id=:userId];
        String JsonString=JSON.serialize(userData);
        system.debug('kalidass - hello');
        system.debug(JsonString);
        system.debug('test123');
        //HTTPResponse res = getInfoFromExternalService(JsonString,'https://home.palmetto.com/api/updateCCA'); 
        HTTPResponse res = getInfoFromExternalService(JsonString,'http://legacy-home-live.palmetto.com'); 
        
        system.debug('perftest');
        system.debug(res);
         
       //end 
     
     
    }
    catch (Exception e)
    {
        SendEmail( 'Exception' + e + '\n User Id = ' +  userId);
    } 
     
   }
   
  
   
   public static HttpResponse getInfoFromExternalService(String jsonstr,String url)
   {
    //Construct HTTP request and response
     //Http request method,Endpoint and setBody
     HttpRequest req = new HttpRequest();
     req.setHeader('Content-Type','application/json');
     String endpoint = url;
     req.setMethod('POST');
     req.setEndpoint(endpoint); 
     req.setBody(jsonstr);
     //Http response method 
     Http http = new Http();
     return http.send(req);
   }
   public static void SendEmail(String MailBody) 
   {
      List<Messaging.SingleEmailMessage> mails =  new List<Messaging.SingleEmailMessage>();
      Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
      List<String> sendTo = new List<String>();
      //sendTo.add('kalidass@infiniticreation.co.uk');
      //sendTo.add('karthik@infiniticreation.co.uk');
      //sendTo.add('amala@infiniticreation.co.uk');
      sendTo.add('terchnologyteam@palmetto.com');
      sendTo.add('bhargav.rentala@palmetto.com');
      mail.setReplyTo('alchemy@palmettoventures.com');
      mail.setSubject('URGENT SF Trigger Issue - CCA');
      //String body = 'Exception Details ' + e ;
      mail.setToAddresses(sendTo);
      mail.setHtmlBody(MailBody);
      mails.add(mail);
      Messaging.sendEmail(mails);

   }
   
 }