public class CommissionPlanMapingHandler {
    
    public static void assignCommissionToOpportunity()
    {   
        Set<Id> recordTypes = new Set<Id>();
        recordTypes.add(Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Opportunity_Process').getRecordTypeId());
        recordTypes.add(Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('X3rd_Party_Contracted_Sales').getRecordTypeId());
        recordTypes.add(Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('X3rd_Party_Design_Sales').getRecordTypeId());

        Set<String> stageNames = new Set<String>();
        stageNames.add('7. Contract Received');
        stageNames.add('7a. Contract Received Confirmed');
        stageNames.add('8. Site Audit Scheduled');
        stageNames.add('8a. Site Audit Completed');
        stageNames.add('10. Site Approved');
        stageNames.add('11. Interconnection Sent');
        stageNames.add('12. Engineering Package Sent');
        stageNames.add('13. Engineering Design Complete');
        stageNames.add('14. Permit Sent');
        stageNames.add('15. Permit Ready');
        stageNames.add('16. Permit Received');
        stageNames.add('17. Install Ready');

        List<Opportunity> opportunity_list = [
                SELECT location__c,X3rd_Party_Partner__c,Lead_Source_Type__c, Channel_Partner__c 
                FROM opportunity 
                WHERE Test_Account__c = false 
                AND RecordTypeId IN :recordTypes
                AND Customer_Type__c ='Residential - Customer' 
                AND StageName IN :stageNames 
                AND LeadSource IN ('3rd Party Provider', 'Self Generated Lead') 
                AND Lead_Source_Type__c IN ('Channel','Independent') 
                AND Id NOT IN (SELECT Opportunity__c from Commission__c)];
                
                
        if(opportunity_list.size() > 0)
        {
            Set<String> party_provider_set = new Set<string>();
            Set<String> location_set = new Set<String>();
            for(Opportunity item:opportunity_list)
            {
                if(!string.isEmpty(item.Channel_Partner__c))
                {
                    //party_provider_set.add(item.X3rd_Party_Partner__c);
                    party_provider_set.add(item.Channel_Partner__c);
                }
                if(!string.isEmpty(item.location__c))
                {
                    location_set.add(item.location__c);
                }
                
            }
            List<string> all_location_list = new List<string>(location_set);
            List<string> all_party_list = new List<string>(party_provider_set);
            string all_locations = setToDelimitedString(',',all_location_list,true);
            string all_party_provider = setToDelimitedString(',',all_party_list,true);
            system.debug('all locations: '+all_locations);
            string soql = string.format('SELECT id,location__c,X3rd_Party_Partner__c, Channel_Partner_Account__c from Commission_Plan__c where Channel_Partner_Account__c IN ({0}) AND location__c INCLUDES({1}) ORDER BY LastModifiedDate DESC' ,
                                        new string[]{
                                            all_party_provider,
                                                all_locations
                                                });
            system.debug('soql:' + soql);
            //List<Commission_Plan__c> commission_list = [SELECT id,location__c,X3rd_Party_Partner__c from Commission_Plan__c where X3rd_Party_Partner__c IN:party_provider_set AND location__c INCLUDES(:all_locations) ORDER BY LastModifiedDate DESC];
            
            List<Commission_Plan__c> commission_list = (List<Commission_Plan__c>)database.query(soql); 
            
            if(commission_list.size() > 0 && opportunity_list.size() > 0)
            {
                Map<string,List<Commission_Plan__c>> commission_map = new Map<string,LisT<Commission_Plan__c>>();
                for(Commission_Plan__c item:commission_list)
                {
                    
                    List<string> location_list = item.location__c.split(';');
                    system.debug('location_list:'+location_list);
                    for(string location:location_list)
                    {
                        if(commission_map.ContainsKey(location+'-'+item.Channel_Partner_Account__c))
                        {
                            List<Commission_Plan__c> temp_commission = commission_map.get(location+'-'+item.Channel_Partner_Account__c);
                            temp_commission.add(item);
                        }
                        else
                        {
                            List<Commission_Plan__c> temp_commission = new  List<Commission_Plan__c>();
                            temp_commission.add(item);
                            commission_map.put(location+'-'+item.Channel_Partner_Account__c,temp_commission);
                        }                                                           
                    }                                                    
                    
                }
                Map<id,List<Commission_Plan__c>> opportunity_map = new Map<id,List<Commission_Plan__c>>();
                for(Opportunity item:opportunity_list)
                {
                    if(commission_map.ContainsKey(item.location__c+'-'+item.Channel_Partner__c))
                    {
                        List<Commission_Plan__c> temp_commission = commission_map.get(item.location__c+'-'+item.Channel_Partner__c);
                        opportunity_map.put(item.id,temp_commission);
                    }
                }
                
                List<Commission__c> commission_new_list = new  List<Commission__c>();
                List<Treasury_Mgmt__c> treasuru_mgmt_new_list = new List<Treasury_Mgmt__c>();
                List<Commission_Plan__c> commission_plan_alchemists_list = new List<Commission_Plan__c>();
                Map<id,Commission__c> opp_and_commission_map = new Map<id,Commission__c>();
                try
                {
                    commission_plan_alchemists_list = [SELECT id,name from Commission_Plan__c where name='Independent Alchemists Commission Plan'];
                    //system.debug('commission_plan_obj:'+ commission_plan_alchemists_list[0].Name);
                }
                catch(Exception ex)
                {
                    system.debug('Independent Alchiments:'+ex.getMessage());
                }
                for(Opportunity item:opportunity_list)
                {
                    if(item.Lead_Source_Type__c == 'Independent' && (commission_plan_alchemists_list != null && commission_plan_alchemists_list.size()>0))
                    {
                        Commission__c commission_obj = new Commission__c(Opportunity__c=item.id,Commission_Plan__c = commission_plan_alchemists_list[0].id);
                        commission_new_list.add(commission_obj);
                        opp_and_commission_map.put(item.id,commission_obj);
                        
                        system.debug('Opp Id:'+item.id);
                    }
                    else if(opportunity_map.ContainsKey(item.id))
                    {
                        system.debug('Commission plan found for opportunity:' + item.id); 
                        List<Commission_Plan__c> temp_commission_plan = opportunity_map.get(item.id);
                        Commission__c commission_obj = new Commission__c(Opportunity__c=item.id,Commission_Plan__c = temp_commission_plan[0].id);
                        commission_new_list.add(commission_obj);
                        opp_and_commission_map.put(item.id,commission_obj);
                    }
                }
                
                if(commission_new_list.size() > 0)
                {
                    database.insert(commission_new_list,false);
                }
                for(Opportunity item:opportunity_list)
                {
                    if(opp_and_commission_map.containsKey(item.id))
                    {
                        Commission__c comm_obj_temp = opp_and_commission_map.get(item.id);
                        treasuru_mgmt_new_list.add(new Treasury_Mgmt__c (Opportunity__c = item.id,Commission__c=comm_obj_temp.id));
                    }
                }
                if(treasuru_mgmt_new_list.size()>0)
                {
                    database.insert(treasuru_mgmt_new_list,false);
                }
            }
        }
        
        
    } 
    
    private static string setToDelimitedString(string delimiter,List< string > inputList,boolean add_single_quotes)
    {
        string result = '';
        if ( inputList != null && delimiter != null )
        {
            for ( string s : inputList )
            {
                if(s != null)
                {
                    if ( result != '' )
                    {   
                        result += delimiter;
                    }
                    
                    if(add_single_quotes)
                    {
                        result += '\''+String.escapeSingleQuotes(s) +'\'';
                    }
                    else
                    {
                        result += String.escapeSingleQuotes(s);
                    }
                }
                
            }
        }
        return result;
    }
    public static void sendErrorEmail( string emailAddress,Exception e)
    {
        if ( e == null )
        {
            return;
        }
        string subject = 'Commision Plan Mappper failed';
        string body =
            'Dear ' + Userinfo.getName() + ',<br/>' +
            '<br/>' +
            'Error details in Commission Plan Mapping Handler:<br/>' +
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
    
    public static void abortAllDeleted()
    {
        try
        {   
            Set<Id> corn_job_ids = new Set<Id> ();
            for(CronJobDetail cj : [select Id from CronJobDetail where Name LIKE 'Commission Plan Mapping Schedular:%' limit 50])
            {
                corn_job_ids.add(cj.Id);
            }
            
            for(CronTrigger last_job : [ select Id, State from CronTrigger 
                                        where State = 'Deleted' 
                                        AND CronJobDetailId IN: corn_job_ids ])
            {
                System.abortJob( last_job.Id );
            }
        }
        catch ( Exception e )
        {
            System.Debug( 'Failed to abort deleted scheduled job: ' + e );
        }
    }
}