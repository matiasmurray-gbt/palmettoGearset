public with sharing class CommissionTrackerExportController
{
    private string fromDateExport{get;set;}
    private string toDateExport{get;set;}
    private integer reportType{get;set;}
    private string selectedMilestone{get;set;}
    private string selected3rdPartyProvider{get;set;}
    private Boolean paidMileStone{get;set;}
    private List<Commission__c> commission_list{get;set;}
    private Map<string,List<Commission__c>> mileStoneMap{get;set;}
    private Map<string,decimal> partyProviderCal{get;set;}
    private Map<string,decimal> partyProviderCalPerMileStone{get;set;}
    public CommissionTrackerExportController()
    {
        fromDateExport = EncodingUtil.urlDecode(ApexPages.currentPage().getParameters().get('startdate'),'UTF-8');
        toDateExport = EncodingUtil.urlDecode(ApexPages.currentPage().getParameters().get('enddate'),'UTF-8');
        selected3rdPartyProvider = EncodingUtil.urlDecode(ApexPages.currentPage().getParameters().get('partprovider'),'UTF-8');
        selectedMilestone = EncodingUtil.urlDecode(ApexPages.currentPage().getParameters().get('milestone'),'UTF-8');
        reportType = integer.valueOf(ApexPages.currentPage().getParameters().get('reporttype')); 
        paidMileStone = Boolean.valueOf(ApexPages.currentPage().getParameters().get('paidmilestone'));
       system.debug('milestone:'+selectedMilestone);
        string soql;
        if(reportType == 1)
        {
            soql = commissionToBeProcessedSOQL();
            system.debug('Commission to be Processed SOQL');
        }
        else if(reportType == 2)
        {
            soql = commissionProcessedSOQL();
            system.debug('Commission Processed SOQL');
        }
        else if(reportType == 3)
        {
            soql = commissionPaidSOQL();
            system.debug('Commission Paid SOQL');
        }
        commission_list = new List<Commission__c>();
        commission_list = (List<Commission__c>)Database.query(soql);
        if(reportType == 1)
        {
            generateMileStoneMapForCommissionToBeProcessed();
        }
        else if(reportType == 2)
        {
            generateMileStoneMapForProcessedCommission();
           // populateProcessCommissionList();
        }
        else if(reportType == 3)
        {
            generateMileStoneMapForPaidCommission();  
            //populateCommissionPaidList();
        }
        
        pouplatePartyProviderMapForCalculation();
    }
    /*private void populateCommissionPaidList()
    {
        List<Commission__c> paid_commission_list = new List<Commission__c>();
        date start_date = getDate(fromDateExport);
        date end_date  = getDate(toDateExport);
        for(Commission__c item:commission_list)
        {
            
            if(selectedMilestone.contains('M1') && (item.Milestone_1_Paid_Date__c >=start_date && item.Milestone_1_Paid_Date__c <=end_date))
            {
                if(item.Milestone_1_Paid__c == true)
                {
                   paid_commission_list.add(item);
                   
                    
                }
                
            }
            if(selectedMilestone.contains('M2') && (item.Milestone_2_Paid_Date__c >=start_date && item.Milestone_2_Paid_Date__c <=end_date))
            {
                if(item.Milestone_2_Paid__c == true)
                {
                     paid_commission_list.add(item);
                }
                
            }
            if(selectedMilestone.contains('M3') && (item.Milestone_3_Paid_Date__c >=start_date && item.Milestone_3_Paid_Date__c <=end_date))
            {
                
                if(item.Milestone_3_Paid__c == true)
                {
                    
                     paid_commission_list.add(item);
                }
                
            }
            if(selectedMilestone.contains('Clawbacks') && (item.M1_Clawback_Applied_to_Balance_Paid_Date__c >=start_date && item.M1_Clawback_Applied_to_Balance_Paid_Date__c <=end_date))
            {
                if(item.M1_Clawback_Applied_Paid__c == true)
                {
                    
                     paid_commission_list.add(item);
                     
                }
                
            }
        }
        commission_list = paid_commission_list;
    }
    private void populateProcessCommissionList()
    {
        List<Commission__c> processed_commission_list = new List<Commission__c>();
        date start_date = getDate(fromDateExport);
        date end_date  = getDate(toDateExport);
        for(Commission__c item:commission_list)
        {
            Boolean only_one_record = false;
            if(selectedMilestone.contains('M1') && (item.Milestone_1_Processed_Date__c >=start_date && item.Milestone_1_Processed_Date__c <=end_date))
            {
                if(item.Milestone_1_Processed__c == true && only_one_record == false)
                {
                    processed_commission_list.add(item);
                    only_one_record = true;
                }
            }
            
            if(selectedMilestone.contains('M2') && (item.Milestone_2_Processed_Date__c >=start_date && item.Milestone_2_Processed_Date__c <=end_date))
            {
                
                if(item.Milestone_2_Processed__c == true && only_one_record == false)
                {
                    processed_commission_list.add(item);
                    only_one_record = true;
                    
                }
                
            }
            
            if(selectedMilestone.contains('M3') && (item.Milestone_3_Processed_Date__c >=start_date && item.Milestone_3_Processed_Date__c <=end_date))
            {
                if(item.Milestone_3_Processed__c == true && only_one_record == false)
                {
                    processed_commission_list.add(item); 
                    only_one_record = true;
                }
                
            }
            
            if(selectedMilestone.contains('Clawbacks') && (item.M1_Clawback_Processed_Date__c >=start_date && item.M1_Clawback_Processed_Date__c <=end_date))
            {
                system.debug('Clawbacks for commission processed');
                if(item.M1_Clawback_Complete__c == true && only_one_record == false)
                {
                   processed_commission_list.add(item);
                   only_one_record = true;
                    
                }
               
            }
 
        }
        
        commission_list = processed_commission_list;
    }*/
    private void generateMileStoneMapForCommissionToBeProcessed()
    {
        mileStoneMap = new Map<string,List<Commission__c>>();
        for(commission__c item:commission_list)
        {
            if(mileStoneMap.containsKey(item.Milestone_Payments__c))
            {
                List<Commission__c> temp_commission_list = milestoneMap.get(item.Milestone_Payments__c);
                temp_commission_list.add(item);
            }
            else
                {
                    List<Commission__c> temp_commission_list = new List<Commission__c>();
                    temp_commission_list.add(item);
                    mileStoneMap.put(item.Milestone_Payments__c,temp_commission_list);
                }
        }
    }
    private void generateMileStoneMapForProcessedCommission()
    {
        mileStoneMap = new Map<string,List<Commission__c>>();
        date start_date = getDate(fromDateExport);
        date end_date  = getDate(toDateExport);
        Set<String> excluded_stages = new Set<string>();
        excluded_stages.add('9. Change Order Pending');
        excluded_stages.add('Closed Lost');
        excluded_stages.add('Cancelled');
        for(Commission__c item:commission_list)
        {
            if(selectedMilestone.contains('M1') && (item.Milestone_1_Processed_Date__c >=start_date && item.Milestone_1_Processed_Date__c <=end_date) && !excluded_stages.contains(item.Opportunity__r.StageName))
            {
                if(item.Milestone_1_Processed__c == true && mileStoneMap.containsKey('M1'))
                {
                    List<Commission__c> temp_commission_list = mileStoneMap.get('M1');
                    temp_commission_list.add(item);
                }
                else if(item.Milestone_1_Processed__c == true)
                {
                    List<Commission__c> temp_commission_list = new List<Commission__c>();
                    temp_commission_list.add(item);
                    mileStoneMap.put('M1',temp_commission_list);
                }
            }
            
            if(selectedMilestone.contains('M2') && (item.Milestone_2_Processed_Date__c >=start_date && item.Milestone_2_Processed_Date__c <=end_date) && !excluded_stages.contains(item.Opportunity__r.StageName))
            {
                
                if(item.Milestone_2_Processed__c == true && mileStoneMap.containsKey('M2'))
                {
                    List<Commission__c> temp_commission_list = mileStoneMap.get('M2');
                    temp_commission_list.add(item);
                    
                }
                else if(item.Milestone_2_Processed__c == true)
                {
                    List<Commission__c> temp_commission_list = new List<Commission__c>();
                    temp_commission_list.add(item);
                    mileStoneMap.put('M2',temp_commission_list);
                }
            }
            
            if(selectedMilestone.contains('M3') && (item.Milestone_3_Processed_Date__c >=start_date && item.Milestone_3_Processed_Date__c <=end_date) && !excluded_stages.contains(item.Opportunity__r.StageName))
            {
                if(item.Milestone_3_Processed__c == true && mileStoneMap.containsKey('M3'))
                {
                    List<Commission__c> temp_commission_list = mileStoneMap.get('M3');
                    temp_commission_list.add(item);
                    
                }
                else if(item.Milestone_3_Processed__c == true)
                {
                    List<Commission__c> temp_commission_list = new List<Commission__c>();
                    temp_commission_list.add(item);
                    mileStoneMap.put('M3',temp_commission_list);
                }
            }
            
            if(selectedMilestone.contains('Clawbacks') && (item.M1_Clawback_Processed_Date__c >=start_date && item.M1_Clawback_Processed_Date__c <=end_date))
            {
                system.debug('Clawbacks for commission processed');
                if(item.M1_Clawback_Complete__c == true && mileStoneMap.containsKey('Cancellation Clawback'))
                {
                    List<Commission__c> temp_commission_list = mileStoneMap.get('Cancellation Clawback');
                    temp_commission_list.add(item);
                    
                }
                else if(item.M1_Clawback_Complete__c == true)
                {
                    List<Commission__c> temp_commission_list = new List<Commission__c>();
                    temp_commission_list.add(item);
                    mileStoneMap.put('Cancellation Clawback',temp_commission_list);
                }
            }
 
        }
    }
    private void generateMileStoneMapForPaidCommission()
    {
        mileStoneMap = new Map<string,List<Commission__c>>();
        date start_date = getDate(fromDateExport);
        date end_date  = getDate(toDateExport);
        for(Commission__c item:commission_list)
        {
            if(selectedMilestone.contains('M1') && (item.Milestone_1_Paid_Date__c >=start_date && item.Milestone_1_Paid_Date__c <=end_date))
            {
                
                
                if(item.Milestone_1_Paid__c == true && mileStoneMap.containsKey('M1'))
                {
                    List<Commission__c> temp_commission_list = mileStoneMap.get('M1');
                    temp_commission_list.add(item);
                    
                }
                else if(item.Milestone_1_Paid__c == true)
                {
                    List<Commission__c> temp_commission_list = new List<Commission__c>();
                    temp_commission_list.add(item);
                    mileStoneMap.put('M1',temp_commission_list);
                }
            }
            if(selectedMilestone.contains('M2') && (item.Milestone_2_Paid_Date__c >=start_date && item.Milestone_2_Paid_Date__c <=end_date))
            {
                if(item.Milestone_2_Paid__c == true && mileStoneMap.containsKey('M2'))
                {
                     List<Commission__c> temp_commission_list = mileStoneMap.get('M2');
                    temp_commission_list.add(item);
                }
                else if(item.Milestone_2_Paid__c == true)
                {
                    List<Commission__c> temp_commission_list = new List<Commission__c>();
                    temp_commission_list.add(item);
                    mileStoneMap.put('M2',temp_commission_list);
                }
            }
            if(selectedMilestone.contains('M3') && (item.Milestone_3_Paid_Date__c >=start_date && item.Milestone_3_Paid_Date__c <=end_date))
            {
                
                if(item.Milestone_3_Paid__c == true && mileStoneMap.containsKey('M3'))
                {
                    List<Commission__c> temp_commission_list = mileStoneMap.get('M3');
                    temp_commission_list.add(item);
                    
                }
                else if(item.Milestone_3_Paid__c == true)
                {
                    List<Commission__c> temp_commission_list = new List<Commission__c>();
                    temp_commission_list.add(item);
                    mileStoneMap.put('M3',temp_commission_list);
                }
            }
            if(selectedMilestone.contains('Clawbacks') && (item.M1_Clawback_Applied_to_Balance_Paid_Date__c >=start_date && item.M1_Clawback_Applied_to_Balance_Paid_Date__c <=end_date))
            {
                if(item.M1_Clawback_Applied_Paid__c == true && mileStoneMap.containsKey('Cancellation Clawback'))
                {
                    List<Commission__c> temp_commission_list = mileStoneMap.get('Cancellation Clawback');
                    temp_commission_list.add(item);
                    
                }
                else if(item.M1_Clawback_Applied_Paid__c == true)
                {
                    List<Commission__c> temp_commission_list = new List<Commission__c>();
                    temp_commission_list.add(item);
                    mileStoneMap.put('Cancellation Clawback',temp_commission_list);
                }
            }
        }
    }
    private date getDate(string date_in_str)
    {
        List<String> date_parts = date_in_str.split('/');
        Date final_date = Date.newinstance(integer.valueOf(date_parts[2]),integer.valueOf(date_parts[0]),integer.valueOf(date_parts[1]));
        return final_date;
    }
    private void pouplatePartyProviderMapForCalculation()
    {
        partyProviderCal = new Map<string,decimal>();
        partyProviderCalPerMileStone = new Map<string,decimal>();
        for(string milestone:mileStoneMap.keySet())
        {
            List<Commission__c> temp_commission_list = mileStoneMap.get(milestone);
            for(Commission__c item:temp_commission_list)
            {
                decimal total = 0;
                if(reportType == 1 && milestone == 'M1' && item.Milestone_1_Amount__c != null)
                {
                    total = item.Milestone_1_Amount__c;
                }
                else if( milestone == 'M1' && item.Milestone_1_Amount_Actual_Paid__c != null)
                {
                    total = item.Milestone_1_Amount_Actual_Paid__c;
                }
                if(reportType == 1 && milestone == 'M2' && item.Milestone_2_Amount__c !=null)
                {
                  total = item.Milestone_2_Amount__c;  
                }
                else if(milestone == 'M2' && item.Milestone_2_Amount_Actual_Paid__c !=null)
                {
                    total = item.Milestone_2_Amount_Actual_Paid__c;
                }
                
                if(reportType == 1 && milestone == 'M3' && item.Milestone_3_Amount__c !=null)
                {
                  total = item.Milestone_3_Amount__c;  
                }
                else if(milestone == 'M3' && item.Milestone_3_Actual_Paid__c !=null)
                {
                    total = item.Milestone_3_Actual_Paid__c;  
                }
                
                if(reportType == 1 && milestone == 'Cancellation Clawback' && item.M1_Clawback_Amount__c != null)
                {
                    total = (-1) * item.M1_Clawback_Amount__c;
                }
                else if(milestone == 'Cancellation Clawback' && item.Clawback_Amount_Actual__c != null)
                {
                    total = (-1) * item.Clawback_Amount_Actual__c;
                }
                if(partyProviderCal.ContainsKey(item.Opportunity__r.X3rd_Party_Partner__c))
                {
                    decimal party_amount = partyProviderCal.get(item.Opportunity__r.X3rd_Party_Partner__c);
                    party_amount +=total;
                    partyProviderCal.put(item.Opportunity__r.X3rd_Party_Partner__c,party_amount);
                }
                else
                {
                    partyProviderCal.put(item.Opportunity__r.X3rd_Party_Partner__c,total);
                }
                
                if(partyProviderCalPerMileStone.ContainsKey(item.Opportunity__r.X3rd_Party_Partner__c+'-'+milestone))
                {
                    decimal party_amount_per_milestone = partyProviderCalPerMileStone.get(item.Opportunity__r.X3rd_Party_Partner__c+'-'+milestone);
                    party_amount_per_milestone +=total;
                    partyProviderCalPerMileStone.put(item.Opportunity__r.X3rd_Party_Partner__c+'-'+milestone,party_amount_per_milestone);
                }
                else
                {
                    partyProviderCalPerMileStone.put(item.Opportunity__r.X3rd_Party_Partner__c+'-'+milestone,total);
                }
            }
        }
    }
    private decimal getM1Total()
    {
       
        if(selectedMilestone.contains('M1'))
        {
            
            decimal m1_total = 0;
            for(string milestone:mileStoneMap.keySet())
            {
                system.debug('milestone Bucket:'+milestone);
                if(milestone == 'M1')
                {
                    List<Commission__c> temp_commission_list = mileStoneMap.get(milestone);
                    for(Commission__c item:temp_commission_list)
                    {
                        if(reportType == 1 && item.Milestone_1_Amount__c !=null)
                        {
                            m1_total +=item.Milestone_1_Amount__c;
                        }
                        else if(item.Milestone_1_Amount_Actual_Paid__c!= null)
                        {
                            m1_total +=item.Milestone_1_Amount_Actual_Paid__c; 
                        }
                        
                    }
                }
            }
            return m1_total;
            
            
        }
       return 0;
    }
    private decimal getM2Total()
    {
        
        if(selectedMilestone.contains('M2'))
        {
            decimal m2_total = 0;
            for(string milestone:mileStoneMap.keySet())
            {
                if(milestone == 'M2')
                {
                    List<Commission__c> temp_commission_list =  mileStoneMap.get(milestone);
                    for(Commission__c item:temp_commission_list)
                    {
                        if(reportType == 1 && item.Milestone_2_Amount__c != null)
                        {
                            m2_total +=item.Milestone_2_Amount__c;
                        }
                        else if(item.Milestone_2_Amount_Actual_Paid__c != null)
                        {
                            m2_total += item.Milestone_2_Amount_Actual_Paid__c;
                        }
                        
                    }
                }
            }
            return m2_total;
        }
       return 0;
    }
    
    private decimal getM3Total()
    {
        
        if(selectedMilestone.contains('M3'))
        {
            
                decimal m3_total = 0;
                for(string milestone:mileStoneMap.keySet())
                {
                    if(milestone == 'M3')
                    {
                        List<Commission__c> temp_commission_list =  mileStoneMap.get(milestone);
                        for(Commission__c item:temp_commission_list)
                        {
                            if(reportType== 1 && item.Milestone_3_Amount__c != null)
                            {
                                m3_total +=item.Milestone_3_Amount__c;
                            }
                            else if(item.Milestone_3_Actual_Paid__c != null)
                            {
                                m3_total +=item.Milestone_3_Actual_Paid__c;
                            }
                            
                        }
                    }
                }
                return m3_total;
            }
            
      return 0;
    }
    
    private decimal getClawBackTotal()
    {
        if(selectedMilestone.contains('Clawbacks'))
        {
            
            decimal clawback_total = 0;
            for(string milestone:mileStoneMap.keySet())
            {
                if(milestone == 'Cancellation Clawback')
                {
                    List<Commission__c> temp_commission_list =  mileStoneMap.get(milestone);
                    for(Commission__c item:temp_commission_list)
                    {
                        if(reportType == 1 && item.M1_Clawback_Amount__c != null)
                        {
                            clawback_total +=item.M1_Clawback_Amount__c;
                        }
                        else if(item.Clawback_Amount_Actual__c != null)
                        {
                            clawback_total += item.Clawback_Amount_Actual__c;
                        }
                        
                    }
                }
            }
            return clawback_total;
            
            
        }
        return 0;
    }
    private string commissionToBeProcessedSOQL()
    {
        
        date from_date = getDate(fromDateExport);
        date to_date  = getDate(toDateExport);
        DateTime start_date = dateTime.newinstance(from_date,Time.newInstance(0, 0, 0, 0));
        DateTime end_date = dateTime.newinstance(to_date,Time.newInstance(0, 0, 0, 0));
        string soql = CommissionTrackerUtility.commissionToBeProcessedSOQL(selectedMilestone,selected3rdPartyProvider,start_date,end_date);
        return soql;
    }
    
    private string commissionProcessedSOQL()
    {
        date from_date = getDate(fromDateExport);
        date to_date  = getDate(toDateExport);
        DateTime start_date = dateTime.newinstance(from_date,Time.newInstance(0, 0, 0, 0));
        DateTime end_date = dateTime.newinstance(to_date,Time.newInstance(0, 0, 0, 0));
        string soql = CommissionTrackerUtility.commissionProcessedSOQL(selectedMilestone,selected3rdPartyProvider,start_date,end_date,paidMileStone);
        return soql;
    }
    
    private string commissionPaidSOQL()
    {
        date from_date = getDate(fromDateExport);
        date to_date  = getDate(toDateExport);
        DateTime start_date = dateTime.newinstance(from_date,Time.newInstance(0, 0, 0, 0));
        DateTime end_date = dateTime.newinstance(to_date,Time.newInstance(0, 0, 0, 0));
        string soql = CommissionTrackerUtility.commissionPaidSOQL(selectedMilestone,selected3rdPartyProvider,start_date,end_date);
        return soql;
    }

    public String getCsvString() 
    {
        String[] rows = new String[0];
        String[] line = new String[0];
        rows.addAll(getDateRange());
        rows.addAll(getMileStoneSum());
        rows.addAll(getByProvider());
        rows.addAll(getCommission());
        return String.join(rows,'\n');
    }
    
    private string[] getDateRange()
    {
        String[] line = new String[0];
        String[] rows = new String[0];
        line.add('Date Range');
        rows.add(String.join(line, ','));
        line = new String[0];
        line.add('From:');
        line.add(fromDateExport);
        rows.add(String.join(line, ','));
        line = new String[0];
        line.add('To:');
        line.add(toDateExport);
        rows.add(String.join(line, ','));
        
        return rows;
        
    }
    
    private string[] getMileStoneSum()
    {
        String[] line = new String[0];
        String[] rows = new String[0];
        line.add('');
        rows.add(String.join(line, ','));
        line = new String[0];
        line.add('');
        rows.add(String.join(line, ','));
        line = new String[0];
        line.add('M1');
        Decimal m1_total = getM1Total();
        line.add('$ '+string.valueOf(m1_total));
        rows.add(String.join(line, ','));
        line = new String[0];
        line.add('M2');
        Decimal m2_total = getM2Total();
        line.add('$ '+string.valueOf(m2_total));
        rows.add(String.join(line, ','));
        line = new String[0];
        line.add('M3');
        Decimal m3_total = getM3Total();
        line.add('$ '+string.valueOf(m3_total));
        rows.add(String.join(line, ','));
        line = new String[0];
        line.add('ClawBack');
        decimal claw_back_total = getClawBackTotal();
        line.add('$ '+string.valueOf(claw_back_total));
        rows.add(String.join(line, ','));
        line = new String[0];
        decimal all_total = m1_total + m2_total + m3_total - claw_back_total;
        line.add('Total');
        line.add('$ '+all_total);
        rows.add(String.join(line, ','));
        return rows;
        
    }
    
    private string[] getByProvider()
    {
        String[] line = new String[0];
        String[] rows = new String[0];
        line.add('');
        rows.add(String.join(line, ','));
        line = new String[0];
        line.add('');
        rows.add(String.join(line, ','));
        line = new String[0];
        line.add('Channel Partner');
        line.add('Commission');
        line.add('');
        line.add('M1');
        line.add('M2');
        line.add('M3');
        line.add('Clawback');
        rows.add(String.join(line, ','));
        decimal all_total = 0;
        decimal m1_total = 0;
        decimal m2_total = 0;
        decimal m3_total = 0;
        decimal clawback_total = 0;
        for(string party_provider:partyProviderCal.keyset())
        {
            decimal total = partyProviderCal.get(party_provider);
            line = new String[0];
            line.add(party_provider.replace(',', ''));
            line.add('$ '+string.valueOf(total));
            line.add('');
            if(partyProviderCalPerMileStone.containsKey(party_provider+'-M1'))
            {
                decimal total_per_milestone = partyProviderCalPerMileStone.get(party_provider+'-M1');
                line.add('$ '+string.valueOf(total_per_milestone));
                m1_total +=total_per_milestone;
            }
            else
            {
                line.add('');
            }
            if(partyProviderCalPerMileStone.containsKey(party_provider+'-M2'))
            {
                decimal total_per_milestone = partyProviderCalPerMileStone.get(party_provider+'-M2');
                line.add('$ '+string.valueOf(total_per_milestone));
                m2_total += total_per_milestone;
            }
            else
            {
                line.add('');
            }
            if(partyProviderCalPerMileStone.containsKey(party_provider+'-M3'))
            {
                decimal total_per_milestone = partyProviderCalPerMileStone.get(party_provider+'-M3');
                line.add('$ '+string.valueOf(total_per_milestone));
                m3_total +=total_per_milestone;
            }
            else
            {
                line.add('');
            }
            if(partyProviderCalPerMileStone.containsKey(party_provider+'-Cancellation Clawback'))
            {
                decimal total_per_milestone = partyProviderCalPerMileStone.get(party_provider+'-Cancellation Clawback');
                line.add('$ '+string.valueOf(total_per_milestone));
                clawback_total +=total_per_milestone;
            }
            else
            {
                line.add('');
            }
            rows.add(String.join(line, ','));
            all_total +=total;
        }
        line = new String[0];
        line.add('Total');
        line.add('$ '+string.valueOf(all_total));
        line.add('');
        line.add('$ '+string.valueOf(m1_total));
        line.add('$ '+string.valueOf(m2_total));
        line.add('$ '+string.valueOf(m3_total));
        line.add('$ '+string.valueOf(clawback_total));
        rows.add(String.join(line, ','));
        return rows;

    }
    
    private string[] getCommission()
    {
        String[] line = new String[0];
        String[] rows = new String[0];
        line.add('MileStone');
        line.add('Commission Number');
        line.add('18 Character Opportunity ID');
        line.add('3rd Party Partner');
        line.add('3rd Party Salesrep');
        line.add('Opportunity Name');
        line.add('Financing Tool');
        line.add('Total Commissions');
        line.add('Opportunity Owner');
        line.add('Milestone 1 Amount');
        line.add('Milestone 1 Amount (Actual Paid)');
        line.add('Milestone 1 Paid Date');
        line.add('Milestone 2 Commission True-Up');
        line.add('Milestone 2 Amount');
        line.add('Milestone 2 Amount (Actual Paid)');
        line.add('Milestone 2 Paid Date');
        line.add('Milestone 3 Commission True-Up');
        line.add('Milestone 3 Amount');
        line.add('Milestone3 Amount(Actual Paid)');
        line.add('Contract Received Confirmed Date');
        line.add('Installation Complete Date');
        //line.add('Install Completion Approved Date');
        line.add('Cancellation Date');
        line.add('M1 Clawback Amount');
        line.add('Clawback Amount (Actual)');
        line.add('Amount');
        line.add('Price / Watt');
        line.add('System Size Calculated (kW)');
        line.add('CP Base');
        line.add('CP Base / Watt');
        line.add('Loan Term');
        line.add('Dealer Fees');
        line.add('Dealer Fee%');
        line.add('APR %');     
        line.add('"Total Adders, Upgrade & Incentives"');
        line.add('CT GreenBank Incentive');
        line.add('Total Upgrades Cost');
        line.add('Re-Roof Upgrade Cost');
        line.add('Electrical Upgrade Cost');
        line.add('Structural Upgrade Cost');
        line.add('Tree Removal / Other Upgrade Cost');
        line.add('Other / Misc Adjustments');
        line.add('Total Adders');
        line.add('Roof Type Adder');
        line.add('Roof Tilt Adder');
        line.add('High Roof Adder');
        line.add('Panel Type Adder');
        line.add('Solar Edge Warranty Adder');
        line.add('Appointment Success Fee (Adder)');
        line.add('Battery Adder');
        line.add('Ground Mount Adder');
        line.add('Trenching Distance Adder');
        line.add('Contract Received Date');
        //line.add('M3%');
        line.add('Stage');
        line.add('Change Order Reason');
        line.add('Lead Source Type');
        //New column added for card #804
        line.add('Palmetto Protect Cost');
        
        rows.add(String.join(line, ','));
        Map<string,Map<string,List<Commission__c>>> commission_map = new Map<string,Map<string,List<Commission__c>>>();
        date fromDate;
        date toDate;
         date start_date = getDate(fromDateExport);
        date end_date  = getDate(toDateExport);
        fromDate = start_date;
        toDate = end_date;
        if(reportType == 1)
        {
            CommissionTrackerUtility.generateTableForCommissionToBeProcessed(commission_list,commission_map);
        }
        else if(reportType == 2)
        {
            CommissionTrackerUtility.generateTableForProcessedCommission(commission_list, commission_map,selectedMilestone,fromDate,toDate);
        }
        else if(reportType == 3)
        {
            CommissionTrackerUtility.generateTableForPaidCommission(commission_list, commission_map,selectedMilestone,fromDate,toDate);
        }
        List<String> milestone_list = new List<String>();
        if(commission_map.ContainsKey('M1'))
        {
            milestone_list.add('M1');
        }
        if(commission_map.containsKey('M2'))
        {
            milestone_list.add('M2');
        }
        
        if(commission_map.ContainsKey('M3'))
        {
            milestone_list.add('M3');
        }
        
        if(commission_map.ContainsKey('Cancellation Clawback'))
        {
            milestone_list.add('Cancellation Clawback');
        }
        for(string milestone_key:milestone_list)
        {
            Map<string,List<Commission__c>> commission_per_milestone_map = commission_map.get(milestone_key);
            
            /*line = new String[0];
            line.add(milestone_key);
            rows.add(String.join(line, ','));*/
            for(string partner: commission_per_milestone_map.keyset())
            {
                List<Commission__c> commissions = commission_per_milestone_map.get(partner);
                system.debug('MileStone:'+ milestone_key + 'Partner:'+partner + 'Commissions:'+commissions.size());
                for(Commission__c item:commissions)
                {
                    
                    line = new String[0];
                    line.add(milestone_key);
                    line.add(item.Name);
                    line.add(item.X18_Character_Opportunity_ID__c);
                    line.add(item.Opportunity__r.X3rd_Party_Partner__c.replace(',',''));
                    line.add(item.Opportunity__r.X3rd_Party_Sales_Rep__c);
                    line.add(item.Opportunity__r.Name);
                    line.add(item.Opportunity__r.Financing_Tool__c);
                    line.add(string.valueOf(item.Total_Commissions__c));
                    line.add(item.Opportunity__r.Owner.Name);
                    line.add(string.valueOf(item.Milestone_1_Amount__c));
                    line.add(string.valueOf(item.Milestone_1_Amount_Actual_Paid__c));
                    line.add(string.valueof(item.Milestone_1_Paid_Date__c));
                    line.add(string.valueOf(item.Milestone_2_Commission_True_Up__c));
                    line.add(string.valueof(item.Milestone_2_Amount__c));
                    line.add(String.valueof(item.Milestone_2_Amount_Actual_Paid__c));
                    line.add(string.valueof(item.Milestone_2_Paid_Date__c));
                    line.add(string.valueOf(item.Milestone_3_Commission_True_Up__c));
                    line.add(string.valueOf(item.Milestone_3_Amount__c));
                    line.add(string.valueOf(item.Milestone_3_Actual_Paid__c));
                    line.add(string.valueof(item.Opportunity__r.Contract_Received_Confirmed_Date__c));
                    line.add(string.valueof(item.Installation_Complete_Date__c));
                    //line.add(string.valueof(item.Install_Completion_Approved_Date__c));
                    line.add(string.valueof(item.Opportunity__r.Cancellation_Date__c));
                    line.add(string.valueof(item.M1_Clawback_Amount__c));
                    line.add(string.valueof(item.Clawback_Amount_Actual__c));
                    line.add(string.valueof(item.Opportunity_Amount__c));
                    line.add(string.valueof(item.Price_Watt__c));
                    line.add(string.valueof(item.Opportunity__r.System_Size_Calculated_kW__c));
                    line.add(string.valueof(item.CP_Base__c));
                    line.add(string.valueof(item.CP_Base_Watt__c));
                    line.add(string.valueof(item.Loan_Term__c));
                    line.add(string.valueof(item.Dealer_Fees__c));
                    line.add(string.valueof(item.Dealer_Fee_Percent__c));
                    //New Column added in CSV 11/20/2019 start
                    line.add(string.valueof(item.APR__c)); 
                    line.add(string.valueof(item.Total_Adders_Upgrade_Incentives__c)); 
                    line.add(string.valueof(item.CT_GreenBank_Adder__c)); 
                    line.add(string.valueof(item.Structural_Electrical_Upgrade_Adder__c)); 
                    line.add(string.valueof(item.Roofing_Adder__c)); 
                    line.add(string.valueof(item.Electrical_Upgrade_Adder__c)); 
                    line.add(string.valueof(item.Structural_Upgrade_Adder__c)); 
                    line.add(string.valueof(item.Tree_Removal_Other_Adder__c)); 
                    line.add(string.valueof(item.Other_Misc_Adders__c)); 
                    //New Column added in CSV 11/20/2019 end
                    line.add(string.valueof(item.Total_Adders__c));
                    line.add(string.valueof(item.Roof_Type_Adder__c));
                    line.add(string.valueof(item.Roof_Tilt_Adder__c));
                    line.add(string.valueOf(item.High_Roof_Adder__c));
                    line.add(string.valueof(item.Panel_Type_Adder__c));
                    line.add(string.valueof(item.Solar_Edge_Warranty_Adder__c));
                    line.add(string.valueof(item.Appointment_Success_Fee__c));
                    line.add(string.valueof(item.Battery_Adder__c));
                    line.add(string.valueof(item.Ground_Mount_Adder__c));
                    line.add(string.valueof(item.Trenching_Distance_Adder__c));
                    line.add(string.valueof(item.Contract_Received_Date__c));
                    line.add(string.valueof(item.Opportunity__r.StageName));
                    line.add(string.valueof(item.Opportunity__r.Change_Order_Reason__c));
                    line.add(string.valueof(item.Opportunity__r.Lead_Source_Type__c));
                    //New column added for card #804
                    line.add(string.valueof(item.Palmetto_Protect_Cost__c));
                    rows.add(String.join(line, ','));
                }
            }
        }
        return rows;
        
    }
}