public class CommissionHandler {
    
    public static Set<Id> setOppId;
    
    public CommissionHandler()
    {
        
    }
    public static void ProcessM1MileStone()
    {
        //Opportunity__r.Contract_Received_Confirmed__c = true
        String M1 = '';
        string where_clause = '';
        DateTime start_date = dateTime.now().addDays(-360);
        DateTime end_date = System.Datetime.now().addDays(-1);
        where_clause = 'WHERE';
        M1 = string.format('((Milestone_1_Date_Calculated__c >={0} AND Milestone_1_Date_Calculated__c <= {1}) AND Opportunity__r.Contract_Received_Confirmed_Date__c != null AND Opportunity__r.StageName NOT IN({2}) AND Milestone_1_Processed__c = false AND Milestone_1_Paid__c = false)',
                           new string[]{start_date.format('yyyy-MM-dd'),
                               end_date.format('yyyy-MM-dd'),
                               '\'9. Change Order Pending\',\'Cancelled\''
                               });
                               
         if(setOppId != null && !setOppId.isEmpty()){
             M1 += ' AND Opportunity__c IN :setOppId ';
         } 
         
         string soql = string.format('SELECT Milestone_1_Amount__c,Milestone_1_Amount_Actual_Paid__c,Milestone_1_Processed_Date__c from Commission__c {0} ({1})',new string[]
                                    {where_clause,M1});
         system.debug('soql:'+soql);
         List<Commission__c> commission_list = (List<Commission__c>)Database.query(soql);
         system.debug('M1 Size:'+commission_list.size());
         for(Commission__c item:commission_list)
         {
           item.Milestone_1_Processed_Date__c = System.date.today();
           item.Milestone_1_Amount_Actual_Paid__c = item.Milestone_1_Amount__c;
           item.Milestone_1_Processed__c = true;
         }
        
         update commission_list;
    }
    
    public static void ProcessM2MileStone()
    {
        String M2 = '';
        string where_clause = '';
        DateTime start_date = dateTime.now().addDays(-360);
        DateTime end_date = System.Datetime.now().addDays(-1);
        where_clause = 'WHERE';
        M2 = string.format('((Milestone_2_Date__c >={0} AND Milestone_2_Date__c <={1} ) AND Milestone_1_Paid__c = true AND Milestone_2_Paid__c = false AND Milestone_2_Processed__c = false)',
                               new string[]{
                                   start_date.format('yyyy-MM-dd'),
                                       end_date.format('yyyy-MM-dd')
                                       });
        string soql = string.format('SELECT Milestone_2_Amount__c,Milestone_2_Amount_Actual_Paid__c,Milestone_2_Processed_Date__c' +
                                    ' from Commission__c {0} ({1})',new string[]
                                    {
                                        where_clause,M2
                                    });
       List<Commission__c> commission_list = (List<Commission__c>)Database.query(soql);
        system.debug('M2 Size:'+commission_list.size());        
         for(Commission__c item:commission_list)
         {
           item.Milestone_2_Processed_Date__c = System.date.today();
           item.Milestone_2_Amount_Actual_Paid__c = item.Milestone_2_Amount__c;
           item.Milestone_2_Processed__c = true;
         }
        
         update commission_list;
    }
    
    public static void ProcessM3MileStone()
    {
        //(M3__c != null AND M3__c != 0)
        String M3 = '';
        string where_clause = '';
        DateTime start_date = dateTime.now().addDays(-360);
        DateTime end_date = System.Datetime.now().addDays(-1);
        where_clause = 'WHERE';
        M3 = string.format('((Milestone_3_Date_PTO_3_Days__c >={0} AND Milestone_3_Date_PTO_3_Days__c<={1} ) AND Milestone_3_Processed__c = false AND Milestone_3_Paid__c = false AND Milestone_2_Paid__c = true AND Milestone_3_Amount__c != 0 AND Milestone_3_Amount__c != -0.01 AND Milestone_3_Amount__c != 0.01)',
                               new string[]{
                                   start_date.format('yyyy-MM-dd'),
                                       end_date.format('yyyy-MM-dd')
                                       });
        string soql = string.format('SELECT Milestone_3_Amount__c,Milestone_3_Actual_Paid__c,Milestone_3_Processed_Date__c' +
                                    ' from Commission__c {0} ({1})',new string[]
                                    {
                                        where_clause,M3
                                    });
                                    
        soql += ' AND Contract_Received_Date__c >= 2020-01-01';
       List<Commission__c> commission_list = (List<Commission__c>)Database.query(soql);
        system.debug('M3 Size:'+commission_list.size());
         for(Commission__c item:commission_list)
         {
           item.Milestone_3_Processed_Date__c = System.date.today();
           item.Milestone_3_Actual_Paid__c = item.Milestone_3_Amount__c;
           item.Milestone_3_Processed__c = true;
         }
        
         update commission_list;
    }
    
    public static void ProcessClawBackMileStone()
    {
         String claw_back = '';
        string where_clause = '';
        DateTime start_date = dateTime.now().addDays(-360);
        DateTime end_date = System.Datetime.now().addDays(-1);
        where_clause = 'WHERE';
        claw_back = string.format(' ((Opportunity__r.Cancellation_Date__c >={0} AND Opportunity__r.Cancellation_Date__c<={1}) AND Milestone_1_Paid__c = true AND M1_Clawback_Complete__c = false)'
                                      ,new string[]{
                                          start_date.format('yyyy-MM-dd'),
                                              end_date.format('yyyy-MM-dd')
                                              }
                                     );
       string soql = string.format('SELECT M1_Clawback_Processed_Date__c from Commission__c {0} ({1})',new string[]
                                    {
                                        where_clause,claw_back
                                    });
       List<Commission__c> commission_list = (List<Commission__c>)Database.query(soql);
       system.debug('claw_back Size:'+commission_list.size());
       for(Commission__c item:commission_list)
       {
          item.M1_Clawback_Processed_Date__c = System.date.today();
          item.M1_Clawback_Complete__c = true;
       }
        
         update commission_list;
    }
    
    public static void sendErrorEmail( string emailAddress,Exception e)
    {
        if ( e == null )
        {
            return;
        }
        string subject = 'Commision to be processed failed';
        string body =
                'Dear ' + Userinfo.getName() + ',<br/>' +
                '<br/>' +
                'Error details in Commission to be processor Schedular:<br/>' +
                'Error: ' + e.getCause() + '|' + e.getLineNumber() + '|' + e.getMessage() + '|' + e.getStackTraceString() + '|' + e.getTypeName() + '<br/>' +
                'Regards,<br/>' +
                '<br/>' +
                'Infinity Creation';
        sendEmail( emailAddress, subject, body );
    }
    private static void sendEmail( string emailAddress, string subject, string body )
    {
        try
        {
            if ( emailAddress == null )
            {
                return;
            }

            Messaging.reserveSingleEmailCapacity( 1 );
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            List< string > toAddresses = new List< string>();
            toAddresses.add( emailAddress );

            mail.setToAddresses( toAddresses );
            mail.setReplyTo( 'jawad@infinitycreation.com' );
            mail.setSenderDisplayName( 'Infinity Creation' );
            mail.setSubject( subject );
            mail.setBccSender( false );
            mail.setUseSignature( false );
            mail.setPlainTextBody( body );
            mail.setHtmlBody( body );
            Messaging.sendEmail( new Messaging.SingleEmailMessage[] { mail } );
        }
        catch( Exception ex )
        {
            system.debug( LoggingLevel.Error, 'Failed to send email' );
            system.debug( 'Failed to processed'+ex.getStackTRaceString() );
            
        }
    }
}