public class CommissionTrackerLgtngUtility 
{
  public static string commissionToBeProcessedSOQL(string selectedMilestone,string selected3rdPartyProvider,datetime start_date,datetime end_date, Boolean isExport)
    {
        Boolean isMileStonePresent = false;
        String M1 = '';
        String M2 = '';
        String M3 = '';
        string claw_back = '';
        
        string where_clause = '';
        
        if(selectedMilestone.contains('M1')) {

            where_clause = 'WHERE';
            M1 = string.format('((Milestone_1_Date_Calculated__c >={0} AND Milestone_1_Date_Calculated__c <= {1}) AND Opportunity__r.Contract_Received_Confirmed__c = true AND Opportunity__r.StageName != {2} AND Milestone_1_Processed__c = false AND Milestone_1_Paid__c = false )',
                               new string[]{start_date.format('yyyy-MM-dd'),
                                   end_date.format('yyyy-MM-dd'),
                                   '\'Cancelled\''
                                
                                   });  
            isMileStonePresent = true; 
        }
        
        if(selectedMilestone.contains('M2') && isMileStonePresent == true) {

            M2 = string.format('OR ((Milestone_2_Date__c >={0} AND Milestone_2_Date__c <={1} ) AND Milestone_1_Paid__c = true AND Milestone_2_Paid__c = false AND Milestone_2_Processed__c = false AND Opportunity__r.StageName != {2})',
                               new string[]{
                                   start_date.format('yyyy-MM-dd'),
                                       end_date.format('yyyy-MM-dd'),
                                   '\'Cancelled\''
                                       });

        } else if(selectedMilestone.contains('M2')) {

            where_clause = 'WHERE';
            M2 = string.format('((Milestone_2_Date__c >={0} AND Milestone_2_Date__c <={1} ) AND Milestone_1_Paid__c = true AND Milestone_2_Paid__c = false AND Milestone_2_Processed__c = false AND Opportunity__r.StageName != {2})',
                               new string[]{
                                   start_date.format('yyyy-MM-dd'),
                                       end_date.format('yyyy-MM-dd'),
                                       '\'Cancelled\''
                                       });
            isMileStonePresent = true;
        }
        
        if(selectedMilestone.contains('M3') && isMileStonePresent == true) {

            M3 = string.format('OR ((Milestone_3_Date_PTO_3_Days__c >={0} AND Milestone_3_Date_PTO_3_Days__c<={1} ) AND Milestone_3_Processed__c = false AND Milestone_3_Paid__c = false AND Milestone_2_Paid__c = true AND (M3__c != null AND M3__c != 0) AND Opportunity__r.StageName != {2})',
                               new string[]{
                                   start_date.format('yyyy-MM-dd'),
                                       end_date.format('yyyy-MM-dd'),
                     '\'Cancelled\''
                                       });

        } else if(selectedMilestone.contains('M3')) {

            where_clause = 'WHERE';
            M3 = string.format('((Milestone_3_Date_PTO_3_Days__c >={0} AND Milestone_3_Date_PTO_3_Days__c<={1} ) AND Milestone_3_Processed__c = false AND Milestone_3_Paid__c = false AND Milestone_2_Paid__c = true AND (M3__c != null AND M3__c != 0) AND Opportunity__r.StageName != {2})',
                               new string[]{
                                   start_date.format('yyyy-MM-dd'),
                                       end_date.format('yyyy-MM-dd'),
                     '\'Cancelled\''
                                       });
            isMileStonePresent = true;
        }
        
        if(selectedMilestone.contains('Clawbacks') && isMileStonePresent == true) {

            claw_back = string.format('OR ((Opportunity__r.Cancellation_Date__c >={0} AND Opportunity__r.Cancellation_Date__c<={1}) AND Milestone_1_Paid__c = true AND M1_Clawback_Complete__c = false)'
                                      ,new string[]{
                                          start_date.format('yyyy-MM-dd'),
                                              end_date.format('yyyy-MM-dd')
                                              }
                                     );
        } else if(selectedMilestone.contains('Clawbacks')) {

            where_clause = 'WHERE';
            claw_back = string.format(' ((Opportunity__r.Cancellation_Date__c >={0} AND Opportunity__r.Cancellation_Date__c<={1}) AND Milestone_1_Paid__c = true AND M1_Clawback_Complete__c = false)'
                                      ,new string[]{
                                          start_date.format('yyyy-MM-dd'),
                                              end_date.format('yyyy-MM-dd')
                                              }
                                     );
            isMileStonePresent = true;
        }

        string soql_3rd_party = '';

        if(!string.isEmpty(selected3rdPartyProvider) && isMileStonePresent == true) {
            
            soql_3rd_party = ' AND (Opportunity__r.X3rd_Party_Partner__c IN (' + selected3rdPartyProvider +  '))';

        } else if(!string.isEmpty(selected3rdPartyProvider)) {

            where_clause = 'WHERE';
            soql_3rd_party = 'Opportunity__r.X3rd_Party_Partner__c IN (' + selected3rdPartyProvider +  ')';
        }

        string stage_pending = 'AND (Opportunity__r.StageName NOT IN (\'9. Change Order Pending\',\'Closed Lost\') AND Milestone_Payments__c !=null)';
        /*if(isMileStonePresent == true)
        {
            stage_pending = 'AND (Opportunity__r.StageName !=\'9. Change Order Pending\')';
        }
        else
        {
            where_clause = 'WHERE';
            stage_pending = 'Opportunity__r.StageName !=\'9. Change Order Pending\'';
        }*/
        //Added Order by Clause 27/05/2021
        String orderBy = 'ORDER BY Opportunity__r.X3rd_Party_Partner__c';
        // new fields added 11/12/2019 'APR__c,Electrical_Upgrade_Adder__c,Roofing_Adder__c,Structural_Upgrade_Adder__c,Total_Adders_Quote__c,Tree_Removal_Other_Adder__c,Trenching_Adder__c'
        // New field added 14/05/2021 Milestone_1_Date_Calculated__c, Milestone_2_Paid__c, Milestone_3_Processed__c, Milestone_3_Paid__c, M1_Clawback_Complete__c, id, Opportunity__r.id
        // New field added 08/06/2021 Opportunity__r.Channel_Partner__c
        //Added field M1_Clawback_Applied_Paid__c 11/06
		//Added new parameter "isExport" to reduce amount of fields for commission calculator performance
		string soql;
		if(isExport) {
			soql = string.format('SELECT X18_Character_Opportunity_ID__c, Ground_Mount_Adder__c, Contract_Received_Confirmed_Date__c,'+
				'Solar_Edge_Warranty_Adder__c,Other_Misc_Adders__c,CT_GreenBank_Adder__c,Total_Adders_Upgrade_Incentives__c,'+
				'Dealer_Fee_Percent__c,Structural_Electrical_Upgrade_Adder__c, Appointment_Success_Fee__c,Name,Opportunity__r.X3rd_Party_Sales_Rep__c,'+
				'Opportunity__r.Name,Opportunity__r.Owner.Name,Opportunity__r.Lead_Source_Type__c,Opportunity__r.StageName,Notes__c,'+
				'Total_Commissions__c,Milestone_1_Amount__c,Milestone_1_Amount_Actual_Paid__c,Milestone_1_Processed_Date__c,Milestone_1_Paid_Date__c,'+
				'Milestone_2_Paid_Date__c,Milestone_2_Commission_True_Up__c,Milestone_2_Amount__c,Milestone_2_Amount_Actual_Paid__c,'+
				'Milestone_2_Processed_Date__c,Milestone_3_Paid_Date__c,Milestone_3_Commission_True_Up__c,Milestone_3_Amount__c,'+
				'Milestone_3_Processed_Date__c,Milestone_3_Actual_Paid__c, Milestone_1_Date_Calculated__c, Milestone_1_paid__c,Milestone_2_processed__c,'+
				'Milestone_2_Paid__c, Milestone_3_Processed__c, Milestone_3_Paid__c, M1_Clawback_Applied_Paid__c,Site_Approved_Date__c,'+
				'Installation_Complete_Date__c,Install_Completion_Approved_Date__c,M1_Clawback_Amount__c,Clawback_Amount_Actual__c,APR__c,'+
				'Electrical_Upgrade_Adder__c,Roofing_Adder__c,Structural_Upgrade_Adder__c,Total_Adders_Quote__c,Tree_Removal_Other_Adder__c,'+
				'Trenching_Adder__c,Opportunity__r.Cancellation_Date__c,Opportunity_Amount__c,Opportunity__r.System_Size_kW__c,CP_Base__c,'+
				'Opportunity__r.Financing_Tool__c,Loan_Term__c,Dealer_Fees__c,Total_Adders__c, M1_Clawback_Complete__c, id, Opportunity__r.id,'+
				' Opportunity__r.Channel_Partner__c,Panel_Type_Adder__c,Roof_Type_Adder__c,Roof_Tilt_Adder__c,High_Roof_Adder__c,'+
				'Trenching_Distance_Adder__c,Battery_Adder__c,Contract_Received_Date__c,Milestone_Payments__c,Opportunity__r.X3rd_Party_Partner__c,'+
				'Opportunity__r.Change_Order_Reason__c,Opportunity__r.Contract_Received_Confirmed_Date__c,Price_Watt__c,CP_Base_Watt__c,'+
				'Opportunity__r.System_Size_Calculated_kW__c,Account_Name_c__c,Location__c,Total_Commissions_Paid_To_Date__c,'+
				'Balance_Due_Commissions__c,M1__c,M2__c,M3__c,PTO_Net_Meter_Installed_Date__c,M1_Clawback_Processed_Date__c,'+
				'M1_Clawback_Applied_to_Balance_Paid_Date__c,Palmetto_Home_Adder__c, Opportunity__r.Number_of_Solar_Panels__c,'+
				'Opportunity__r.Roof_Type__c,Opportunity__r.Number_of_Stories__c,Opportunity__r.Array_Tilt_Highest__c,'+
				'Opportunity__r.Palmetto_Digital_Appointment__c,Opportunity__r.Battery_Qty__c,Opportunity__r.Solar_Edge_25_yr_Extended_Warranty__c,'+
				'Opportunity__r.Palmetto_Digital_Appointment_Fee__c,Milestone_1_processed__c,Opportunity__r.Address__c,Opportunity__r.Trenching_Distance__c, Palmetto_Protect_Cost__c '+
				'FROM Commission__c {0} ({1}  {2} {3} {4}) {5} {6} {7}',new string[]
                                    
                                    {where_clause,M1,M2,M3,claw_back,soql_3rd_party,stage_pending, orderBy});
		} else {
			soql = string.format('SELECT Contract_Received_Confirmed_Date__c,Name,Opportunity__r.X3rd_Party_Sales_Rep__c,Opportunity__r.Name,'+
				'Opportunity__r.Owner.Name, Total_Commissions__c,Milestone_1_Amount__c,Milestone_1_Amount_Actual_Paid__c,'+
				'Milestone_1_Processed_Date__c, Milestone_1_Date_Calculated__c, Milestone_1_paid__c,Milestone_1_Paid_Date__c,'+
				'Milestone_2_Paid_Date__c,Milestone_2_Amount__c,Milestone_2_Amount_Actual_Paid__c,Milestone_2_Processed_Date__c,'+
                'Milestone_2_processed__c, Milestone_2_Paid__c, Milestone_3_Paid_Date__c,Milestone_3_Amount__c,Milestone_3_Processed_Date__c,'+
				'Milestone_3_Actual_Paid__c, Milestone_3_Processed__c, Milestone_3_Paid__c, M1_Clawback_Applied_Paid__c, M1_Clawback_Complete__c,'+
				'Installation_Complete_Date__c,Install_Completion_Approved_Date__c,M1_Clawback_Amount__c,Clawback_Amount_Actual__c,'+
				'Opportunity__r.Cancellation_Date__c, Opportunity__r.Channel_Partner__c,Opportunity__r.Financing_Tool__c, id,Milestone_Payments__c,'+
				'Opportunity__r.X3rd_Party_Partner__c, Opportunity__r.StageName'+
                                    ' FROM Commission__c {0} ({1}  {2} {3} {4}) {5} {6} {7}',new string[]
                                    
                                    {where_clause,M1,M2,M3,claw_back,soql_3rd_party,stage_pending, orderBy});
		}
        
        return soql;
    }
    
    public static string commissionProcessedSOQL(string selectedMilestone,string selected3rdPartyProvider,datetime start_date,datetime end_date,boolean paidMileStone, Boolean isExport)
    {
        Boolean isMileStonePresent = false;
        String M1 = '';
        String M2 = '';
        String M3 = '';
        string claw_back = '';
        string where_clause = '';
        if(selectedMilestone.contains('M1'))
        {
            where_clause = 'WHERE';
            string exclude_paid_date = '';
            if(!paidMileStone)
            {
                exclude_paid_date = 'AND Milestone_1_Paid_Date__c = null';
            }
            M1 = string.format('((Milestone_1_Processed_Date__c >={0} AND Milestone_1_Processed_Date__c<={1}) {2})',
                               new string[]{
                                   start_date.format('yyyy-MM-dd'),
                                       end_date.format('yyyy-MM-dd'),
                                       exclude_paid_date
                                       });  
            isMileStonePresent = true;  
        }
        
        if(selectedMilestone.contains('M2') && isMileStonePresent == true)
        {
            string exclude_paid_date = '';
            if(!paidMileStone)
            {
                exclude_paid_date = 'AND Milestone_2_Paid_Date__c = null';
            }
            M2 = string.format('OR ((Milestone_2_Processed_Date__c>={0} AND Milestone_2_Processed_Date__c<={1}) {2})',
                               new string[]{
                                   start_date.format('yyyy-MM-dd'),
                                       end_date.format('yyyy-MM-dd'),
                                       exclude_paid_date
                                       });
        }
        else if(selectedMilestone.contains('M2'))
        {
            where_clause = 'WHERE';
            string exclude_paid_date = '';
            if(!paidMileStone)
            {
                exclude_paid_date = 'AND Milestone_2_Paid_Date__c = null';
            }
            M2 = string.format('((Milestone_2_Processed_Date__c>={0} AND Milestone_2_Processed_Date__c<={1} {2}))',
                               new string[]{
                                   start_date.format('yyyy-MM-dd'),
                                       end_date.format('yyyy-MM-dd'),
                                       exclude_paid_date
                                       });
            isMileStonePresent = true;
        }
        
        if(selectedMilestone.contains('M3') && isMileStonePresent == true)
        {
            string exclude_paid_date = '';
            if(!paidMileStone)
            {
                exclude_paid_date = 'AND Milestone_3_Paid_Date__c = null';
            }
            M3 = string.format('OR ((Milestone_3_Processed_Date__c>={0} AND Milestone_3_Processed_Date__c<={1}) {2})',
                               new string[]{
                                   start_date.format('yyyy-MM-dd'),
                                       end_date.format('yyyy-MM-dd'),
                                       exclude_paid_date
                                       }); 
        }
        else if(selectedMilestone.contains('M3'))
        {
            where_clause = 'WHERE';
            string exclude_paid_date = '';
            if(!paidMileStone)
            {
                exclude_paid_date = 'AND Milestone_3_Paid_Date__c = null';
            }
            M3 = string.format('((Milestone_3_Processed_Date__c>={0} AND Milestone_3_Processed_Date__c<={1}) {2})',
                               new string[]{
                                   start_date.format('yyyy-MM-dd'),
                                       end_date.format('yyyy-MM-dd'),
                                       exclude_paid_date
                                       }); 
            isMileStonePresent = true;
        }
        if(selectedMilestone.contains('Clawbacks') && isMileStonePresent == true)
        {
            string exclude_paid_date = '';
            if(!paidMileStone)
            {
                exclude_paid_date = 'AND M1_Clawback_Applied_to_Balance_Paid_Date__c = null';
            }
            claw_back = string.format('OR ((M1_Clawback_Processed_Date__c>={0} AND M1_Clawback_Processed_Date__c<={1}) {2})',
                                      new string[]{
                                          start_date.format('yyyy-MM-dd'),
                                              end_date.format('yyyy-MM-dd'),
                                              exclude_paid_date
                                              });
        }
        else if(selectedMilestone.contains('Clawbacks'))
        {
            where_clause = 'WHERE';
            string exclude_paid_date = '';
            if(!paidMileStone)
            {
                exclude_paid_date = 'AND M1_Clawback_Applied_to_Balance_Paid_Date__c = null';
            }
            claw_back = string.format('((M1_Clawback_Processed_Date__c>={0} AND M1_Clawback_Processed_Date__c<={1}) {2})',
                                      new string[]{
                                          start_date.format('yyyy-MM-dd'),
                                              end_date.format('yyyy-MM-dd'),
                                              exclude_paid_date
                                              });
            isMileStonePresent = true;
        }
        string soql_3rd_party = '';
        if(!string.isEmpty(selected3rdPartyProvider) && isMileStonePresent == true)
        {
            soql_3rd_party = 'AND (Opportunity__r.X3rd_Party_Partner__c IN (' + selected3rdPartyProvider +  '))';
        }
        else if(!string.isEmpty(selected3rdPartyProvider))
        {
            where_clause = 'WHERE';
            soql_3rd_party = 'Opportunity__r.X3rd_Party_Partner__c IN (' + selected3rdPartyProvider +  ')';
        }
        //Added Order by Clause 27/05/2021
        String orderBy = 'ORDER BY Opportunity__r.X3rd_Party_Partner__c';
        // new fields added 11/12/2019 'APR__c,Electrical_Upgrade_Adder__c,Roofing_Adder__c,Structural_Upgrade_Adder__c,Total_Adders_Quote__c,Tree_Removal_Other_Adder__c,Trenching_Adder__c'
        // New field added 08/06/2021 Opportunity__r.Channel_Partner__c
        //11/06 New fields added Milestone_1_Paid__c, Milestone_2_Paid__c, Milestone_3_Paid__c, M1_Clawback_Applied_Paid__c
		//Added new parameter "isExport" to reduce amount of fields for commission calculator performance
		string soql;
		if(isExport) {
        	soql = string.format('SELECT X18_Character_Opportunity_ID__c, Ground_Mount_Adder__c, Contract_Received_Confirmed_Date__c,'+
				'Solar_Edge_Warranty_Adder__c,Other_Misc_Adders__c,CT_GreenBank_Adder__c,Total_Adders_Upgrade_Incentives__c,'+
				'Dealer_Fee_Percent__c,Structural_Electrical_Upgrade_Adder__c, Appointment_Success_Fee__c,Name,Opportunity__r.X3rd_Party_Sales_Rep__c,'+
				'Opportunity__r.Name,Opportunity__r.Owner.Name,Opportunity__r.Lead_Source_Type__c,Opportunity__r.StageName,Notes__c,'+
				'Total_Commissions__c,Milestone_1_Amount__c,Milestone_1_Amount_Actual_Paid__c,Milestone_1_Processed_Date__c,Milestone_1_Paid_Date__c,'+
				'Milestone_2_Paid_Date__c,Milestone_2_Commission_True_Up__c,Milestone_2_Amount__c,Milestone_2_Amount_Actual_Paid__c,'+
				'Milestone_2_Processed_Date__c,Milestone_3_Paid_Date__c,Milestone_3_Commission_True_Up__c,Milestone_3_Amount__c,'+
				'Milestone_3_Processed_Date__c,Milestone_3_Actual_Paid__c, Milestone_1_Date_Calculated__c, Milestone_1_paid__c,Milestone_2_processed__c,'+
				'Milestone_2_Paid__c, Milestone_3_Processed__c, Milestone_3_Paid__c, M1_Clawback_Applied_Paid__c,Site_Approved_Date__c,'+
				'Installation_Complete_Date__c,Install_Completion_Approved_Date__c,M1_Clawback_Amount__c,Clawback_Amount_Actual__c,APR__c,'+
				'Electrical_Upgrade_Adder__c,Roofing_Adder__c,Structural_Upgrade_Adder__c,Total_Adders_Quote__c,Tree_Removal_Other_Adder__c,'+
				'Trenching_Adder__c,Opportunity__r.Cancellation_Date__c,Opportunity_Amount__c,Opportunity__r.System_Size_kW__c,CP_Base__c,'+
				'Opportunity__r.Financing_Tool__c,Loan_Term__c,Dealer_Fees__c,Total_Adders__c, M1_Clawback_Complete__c, id, Opportunity__r.id,'+
				' Opportunity__r.Channel_Partner__c,Panel_Type_Adder__c,Roof_Type_Adder__c,Roof_Tilt_Adder__c,High_Roof_Adder__c,'+
				'Trenching_Distance_Adder__c,Battery_Adder__c,Contract_Received_Date__c,Milestone_Payments__c,Opportunity__r.X3rd_Party_Partner__c,'+
				'Opportunity__r.Change_Order_Reason__c,Opportunity__r.Contract_Received_Confirmed_Date__c,Price_Watt__c,CP_Base_Watt__c,'+
				'Opportunity__r.System_Size_Calculated_kW__c,Account_Name_c__c,Location__c,Total_Commissions_Paid_To_Date__c,'+
				'Balance_Due_Commissions__c,M1__c,M2__c,M3__c,PTO_Net_Meter_Installed_Date__c,M1_Clawback_Processed_Date__c,'+
				'M1_Clawback_Applied_to_Balance_Paid_Date__c,Palmetto_Home_Adder__c, Opportunity__r.Number_of_Solar_Panels__c,'+
				'Opportunity__r.Roof_Type__c,Opportunity__r.Number_of_Stories__c,Opportunity__r.Array_Tilt_Highest__c,'+
				'Opportunity__r.Palmetto_Digital_Appointment__c,Opportunity__r.Battery_Qty__c,Opportunity__r.Solar_Edge_25_yr_Extended_Warranty__c,'+
				'Opportunity__r.Palmetto_Digital_Appointment_Fee__c,Milestone_1_processed__c,Opportunity__r.Address__c,Opportunity__r.Trenching_Distance__c, Palmetto_Protect_Cost__c'+
                                    ' from Commission__c {0} ({1}  {2} {3} {4}) {5} {6}',new string[]
                                    
                                    {where_clause,M1,M2,M3,claw_back,soql_3rd_party, orderBy});
		} else {
			soql = string.format('SELECT Contract_Received_Confirmed_Date__c,Name,Opportunity__r.X3rd_Party_Sales_Rep__c,Opportunity__r.Name,'+
				'Opportunity__r.Owner.Name, Total_Commissions__c,Milestone_1_Amount__c,Milestone_1_Amount_Actual_Paid__c,'+
				'Milestone_1_Processed_Date__c, Milestone_1_Date_Calculated__c, Milestone_1_paid__c,Milestone_1_Paid_Date__c,'+
				'Milestone_2_Paid_Date__c,Milestone_2_Amount__c,Milestone_2_Amount_Actual_Paid__c,Milestone_2_Processed_Date__c,'+
				'Milestone_2_processed__c, Milestone_2_Paid__c, Milestone_3_Paid_Date__c,Milestone_3_Amount__c,Milestone_3_Processed_Date__c,'+
				'Milestone_3_Actual_Paid__c, Milestone_3_Processed__c, Milestone_3_Paid__c, M1_Clawback_Applied_Paid__c, M1_Clawback_Complete__c,'+
				'Installation_Complete_Date__c,Install_Completion_Approved_Date__c,M1_Clawback_Amount__c,Clawback_Amount_Actual__c,'+
				'Opportunity__r.Cancellation_Date__c, Opportunity__r.Channel_Partner__c,Opportunity__r.Financing_Tool__c, id,Milestone_Payments__c,'+
				'Opportunity__r.X3rd_Party_Partner__c,Opportunity__r.StageName'+
								' FROM Commission__c {0} ({1}  {2} {3} {4}) {5} {6}',new string[]
								
								{where_clause,M1,M2,M3,claw_back,soql_3rd_party, orderBy});
		}
        return soql;
    }
    
    public static string commissionPaidSOQL(string selectedMilestone,string selected3rdPartyProvider,datetime start_date,datetime end_date, Boolean isExport)
    {
        Boolean isMileStonePresent = false;
        String M1 = '';
        String M2 = '';
        String M3 = '';
        string claw_back = '';
        string where_clause = '';
        if(selectedMilestone.contains('M1'))
        {
            where_clause = 'WHERE';
            M1 = string.format('(Milestone_1_Paid_Date__c >={0} AND Milestone_1_Paid_Date__c <={1})',
                               new string[]{
                                   start_date.format('yyyy-MM-dd'),
                                       end_date.format('yyyy-MM-dd')
                                       });  
            isMileStonePresent = true;  
        }
        
        if(selectedMilestone.contains('M2') && isMileStonePresent == true)
        {
            M2 = string.format('OR (Milestone_2_Paid_Date__c >={0} AND Milestone_2_Paid_Date__c <={1})',
                               new string[]{
                                   start_date.format('yyyy-MM-dd'),
                                       end_date.format('yyyy-MM-dd')
                                       });
        }
        else if(selectedMilestone.contains('M2'))
        {
            where_clause = 'WHERE';
            M2 = string.format('(Milestone_2_Paid_Date__c >={0} AND Milestone_2_Paid_Date__c <={1})',
                               new string[]{
                                   start_date.format('yyyy-MM-dd'),
                                       end_date.format('yyyy-MM-dd')
                                       });
            isMileStonePresent = true;
        }
        
        if(selectedMilestone.contains('M3') && isMileStonePresent == true)
        {
            M3 = string.format('OR (Milestone_3_Paid_Date__c >={0} AND Milestone_3_Paid_Date__c <={1})',
                               new string[]{
                                   start_date.format('yyyy-MM-dd'),
                                       end_date.format('yyyy-MM-dd')
                                       }); 
        }
        else if(selectedMilestone.contains('M3'))
        {
            where_clause = 'WHERE';
            M3 = string.format('(Milestone_3_Paid_Date__c >={0} AND Milestone_3_Paid_Date__c <={1})',
                               new string[]{
                                   start_date.format('yyyy-MM-dd'),
                                       end_date.format('yyyy-MM-dd')
                                       }); 
            isMileStonePresent = true;
        }
        if(selectedMilestone.contains('Clawbacks') && isMileStonePresent == true)
        {
            claw_back = string.format('OR (M1_Clawback_Applied_to_Balance_Paid_Date__c >={0} AND M1_Clawback_Applied_to_Balance_Paid_Date__c <={1})',
                                      new string[]{
                                          start_date.format('yyyy-MM-dd'),
                                              end_date.format('yyyy-MM-dd')
                                              });
        }
        else if(selectedMilestone.contains('Clawbacks'))
        {
            where_clause = 'WHERE';
            claw_back = string.format('(M1_Clawback_Applied_to_Balance_Paid_Date__c >={0} AND M1_Clawback_Applied_to_Balance_Paid_Date__c <={1})',
                                      new string[]{
                                          start_date.format('yyyy-MM-dd'),
                                              end_date.format('yyyy-MM-dd')
                                              });
            isMileStonePresent = true;
        }
        string soql_3rd_party = '';
        if(!string.isEmpty(selected3rdPartyProvider) && isMileStonePresent == true)
        {
            soql_3rd_party = 'AND (Opportunity__r.X3rd_Party_Partner__c IN (' + selected3rdPartyProvider +  '))';
        }
        else if(!string.isEmpty(selected3rdPartyProvider))
        {
            where_clause = 'WHERE';
            soql_3rd_party = 'Opportunity__r.X3rd_Party_Partner__c IN (' + selected3rdPartyProvider +  ')';
        }
        //Added Order by Clause 27/05/2021
        String orderBy = 'ORDER BY Opportunity__r.X3rd_Party_Partner__c';
        // new fields added 11/12/2019 'APR__c,Electrical_Upgrade_Adder__c,Roofing_Adder__c,Structural_Upgrade_Adder__c,Total_Adders_Quote__c,Tree_Removal_Other_Adder__c,Trenching_Adder__c'
        // New field added 08/06/2021 Opportunity__r.Channel_Partner__c
		//Added new parameter "isExport" to reduce amount of fields for commission calculator performance
		string soql;
		if(isExport) {
        	soql = string.format('SELECT X18_Character_Opportunity_ID__c, Ground_Mount_Adder__c, Contract_Received_Confirmed_Date__c,'+
				'Solar_Edge_Warranty_Adder__c,Other_Misc_Adders__c,CT_GreenBank_Adder__c,Total_Adders_Upgrade_Incentives__c,'+
				'Dealer_Fee_Percent__c,Structural_Electrical_Upgrade_Adder__c, Appointment_Success_Fee__c,Name,Opportunity__r.X3rd_Party_Sales_Rep__c,'+
				'Opportunity__r.Name,Opportunity__r.Owner.Name,Opportunity__r.Lead_Source_Type__c,Opportunity__r.StageName,Notes__c,'+
				'Total_Commissions__c,Milestone_1_Amount__c,Milestone_1_Amount_Actual_Paid__c,Milestone_1_Processed_Date__c,Milestone_1_Paid_Date__c,'+
				'Milestone_2_Paid_Date__c,Milestone_2_Commission_True_Up__c,Milestone_2_Amount__c,Milestone_2_Amount_Actual_Paid__c,'+
				'Milestone_2_Processed_Date__c,Milestone_3_Paid_Date__c,Milestone_3_Commission_True_Up__c,Milestone_3_Amount__c,'+
				'Milestone_3_Processed_Date__c,Milestone_3_Actual_Paid__c, Milestone_1_Date_Calculated__c, Milestone_1_paid__c,Milestone_2_processed__c,'+
				'Milestone_2_Paid__c, Milestone_3_Processed__c, Milestone_3_Paid__c, M1_Clawback_Applied_Paid__c,Site_Approved_Date__c,'+
				'Installation_Complete_Date__c,Install_Completion_Approved_Date__c,M1_Clawback_Amount__c,Clawback_Amount_Actual__c,APR__c,'+
				'Electrical_Upgrade_Adder__c,Roofing_Adder__c,Structural_Upgrade_Adder__c,Total_Adders_Quote__c,Tree_Removal_Other_Adder__c,'+
				'Trenching_Adder__c,Opportunity__r.Cancellation_Date__c,Opportunity_Amount__c,Opportunity__r.System_Size_kW__c,CP_Base__c,'+
				'Opportunity__r.Financing_Tool__c,Loan_Term__c,Dealer_Fees__c,Total_Adders__c, M1_Clawback_Complete__c, id, Opportunity__r.id,'+
				' Opportunity__r.Channel_Partner__c,Panel_Type_Adder__c,Roof_Type_Adder__c,Roof_Tilt_Adder__c,High_Roof_Adder__c,'+
				'Trenching_Distance_Adder__c,Battery_Adder__c,Contract_Received_Date__c,Milestone_Payments__c,Opportunity__r.X3rd_Party_Partner__c,'+
				'Opportunity__r.Change_Order_Reason__c,Opportunity__r.Contract_Received_Confirmed_Date__c,Price_Watt__c,CP_Base_Watt__c,'+
				'Opportunity__r.System_Size_Calculated_kW__c,Account_Name_c__c,Location__c,Total_Commissions_Paid_To_Date__c,'+
				'Balance_Due_Commissions__c,M1__c,M2__c,M3__c,PTO_Net_Meter_Installed_Date__c,M1_Clawback_Processed_Date__c,'+
				'M1_Clawback_Applied_to_Balance_Paid_Date__c,Palmetto_Home_Adder__c, Opportunity__r.Number_of_Solar_Panels__c,'+
				'Opportunity__r.Roof_Type__c,Opportunity__r.Number_of_Stories__c,Opportunity__r.Array_Tilt_Highest__c,'+
				'Opportunity__r.Palmetto_Digital_Appointment__c,Opportunity__r.Battery_Qty__c,Opportunity__r.Solar_Edge_25_yr_Extended_Warranty__c,'+
				'Opportunity__r.Palmetto_Digital_Appointment_Fee__c,Milestone_1_processed__c,Opportunity__r.Address__c,Opportunity__r.Trenching_Distance__c, Palmetto_Protect_Cost__c '+
				' FROM Commission__c {0} ({1}  {2} {3} {4}) {5} {6}',new string[]
                                    
                                    {where_clause,M1,M2,M3,claw_back,soql_3rd_party, orderBy});
		} else {
			soql = string.format('SELECT Contract_Received_Confirmed_Date__c,Name,Opportunity__r.X3rd_Party_Sales_Rep__c,Opportunity__r.Name,'+
				'Opportunity__r.Owner.Name, Total_Commissions__c,Milestone_1_Amount__c,Milestone_1_Amount_Actual_Paid__c,'+
				'Milestone_1_Processed_Date__c, Milestone_1_Date_Calculated__c, Milestone_1_paid__c,Milestone_1_Paid_Date__c,'+
				'Milestone_2_Paid_Date__c,Milestone_2_Amount__c,Milestone_2_Amount_Actual_Paid__c,Milestone_2_Processed_Date__c,'+
				'Milestone_2_processed__c, Milestone_2_Paid__c, Milestone_3_Paid_Date__c,Milestone_3_Amount__c,Milestone_3_Processed_Date__c,'+
				'Milestone_3_Actual_Paid__c, Milestone_3_Processed__c, Milestone_3_Paid__c, M1_Clawback_Applied_Paid__c, M1_Clawback_Complete__c,'+
				'Installation_Complete_Date__c,Install_Completion_Approved_Date__c,M1_Clawback_Amount__c,Clawback_Amount_Actual__c,'+
				'Opportunity__r.Cancellation_Date__c, Opportunity__r.Channel_Partner__c,Opportunity__r.Financing_Tool__c, id,Milestone_Payments__c,'+
				'Opportunity__r.X3rd_Party_Partner__c,Opportunity__r.StageName'+
								' FROM Commission__c {0} ({1}  {2} {3} {4}) {5} {6}',new string[]
							
							{where_clause,M1,M2,M3,claw_back,soql_3rd_party, orderBy});
		}
        return soql;
    }
    
    public static void generateTableForCommissionToBeProcessed(List<Commission__c> commission_list, Map<string,Map<string,List<Commission__c>>> commission_map)
    {
        for(Commission__c item:commission_list)
        {
            if(commission_map.containsKey(item.Milestone_Payments__c))
            {
                Map<string,List<Commission__c>> temp_commission_map = commission_map.get(item.Milestone_Payments__c);
                if(temp_commission_map.containsKey(item.Opportunity__r.X3rd_Party_Partner__c))
                {
                    List<Commission__c> temp_commission_list = temp_commission_map.get(item.Opportunity__r.X3rd_Party_Partner__c);
                    temp_commission_list.add(item);
                }
                else
                {
                    List<Commission__c> temp_commission_list = new List<Commission__c>();
                    temp_commission_list.add(item);
                    temp_commission_map.put(item.Opportunity__r.X3rd_Party_Partner__c,temp_commission_list);
                }
                
            }
            else
            {
                List<Commission__c> temp_commission_list = new List<Commission__c>();
                temp_commission_list.add(item);
                Map<string,List<Commission__c>> temp_commission_map = new Map<string,List<Commission__c>>();
                temp_commission_map.put(item.Opportunity__r.X3rd_Party_Partner__c,temp_commission_list);
                commission_map.put(item.Milestone_Payments__c,temp_commission_map);
            }
        }
    }
    
    public static void generateTableForPaidCommission(List<Commission__c> commission_list, Map<string,Map<string,List<Commission__c>>> commission_map,string selectedMilestone,Date fromDate,Date toDate)
    {
        Map<string,Map<string,List<Commission__c>>> commission_paid_map = new Map<string,Map<string,List<Commission__c>>>();
        for(Commission__c item:commission_list)
        {
            if(selectedMilestone.contains('M1') && (item.Milestone_1_Paid_Date__c >=fromDate && item.Milestone_1_Paid_Date__c <=toDate))
            {
                
                
                if(item.Milestone_1_Paid__c == true && commission_map.containsKey('M1'))
                {
                    Map<string,List<Commission__c>> temp_commission_map = commission_map.get('M1');
                    if(temp_commission_map.containsKey(item.Opportunity__r.X3rd_Party_Partner__c))
                    {
                        List<Commission__c> temp_commission_list = temp_commission_map.get(item.Opportunity__r.X3rd_Party_Partner__c);
                        temp_commission_list.add(item);
                    }
                    else
                    {
                        List<Commission__c> temp_commission_list = new List<Commission__c>();
                        temp_commission_list.add(item);
                        temp_commission_map.put(item.Opportunity__r.X3rd_Party_Partner__c,temp_commission_list);
                    }
                    
                }
                else if(item.Milestone_1_Paid__c == true)
                {
                    List<Commission__c> temp_commission_list = new List<Commission__c>();
                    temp_commission_list.add(item);
                    Map<string,List<Commission__c>> temp_commission_map = new Map<string,List<Commission__c>>();
                    temp_commission_map.put(item.Opportunity__r.X3rd_Party_Partner__c,temp_commission_list);
                    commission_map.put('M1',temp_commission_map);
                }
            }
            if(selectedMilestone.contains('M2') && (item.Milestone_2_Paid_Date__c >=fromDate && item.Milestone_2_Paid_Date__c <=toDate))
            {
                if(item.Milestone_2_Paid__c == true && commission_map.containsKey('M2'))
                {
                    Map<string,List<Commission__c>> temp_commission_map = commission_map.get('M2');
                    if(temp_commission_map.containsKey(item.Opportunity__r.X3rd_Party_Partner__c))
                    {
                        List<Commission__c> temp_commission_list = temp_commission_map.get(item.Opportunity__r.X3rd_Party_Partner__c);
                        temp_commission_list.add(item);
                    }
                    else
                    {
                        List<Commission__c> temp_commission_list = new List<Commission__c>();
                        temp_commission_list.add(item);
                        temp_commission_map.put(item.Opportunity__r.X3rd_Party_Partner__c,temp_commission_list);
                    }
                    
                }
                else if(item.Milestone_2_Paid__c == true)
                {
                    List<Commission__c> temp_commission_list = new List<Commission__c>();
                    temp_commission_list.add(item);
                    Map<string,List<Commission__c>> temp_commission_map = new Map<string,List<Commission__c>>();
                    temp_commission_map.put(item.Opportunity__r.X3rd_Party_Partner__c,temp_commission_list);
                    commission_map.put('M2',temp_commission_map);
                }
            }
            if(selectedMilestone.contains('M3') && (item.Milestone_3_Paid_Date__c >=fromDate && item.Milestone_3_Paid_Date__c <=toDate))
            {
                
                if(item.Milestone_3_Paid__c == true && commission_map.containsKey('M3'))
                {
                    Map<string,List<Commission__c>> temp_commission_map = commission_map.get('M3');
                    if(temp_commission_map.containsKey(item.Opportunity__r.X3rd_Party_Partner__c))
                    {
                        List<Commission__c> temp_commission_list = temp_commission_map.get(item.Opportunity__r.X3rd_Party_Partner__c);
                        temp_commission_list.add(item);
                    }
                    else
                    {
                        List<Commission__c> temp_commission_list = new List<Commission__c>();
                        temp_commission_list.add(item);
                        temp_commission_map.put(item.Opportunity__r.X3rd_Party_Partner__c,temp_commission_list);
                    }
                    
                }
                else if(item.Milestone_3_Paid__c == true)
                {
                    List<Commission__c> temp_commission_list = new List<Commission__c>();
                    temp_commission_list.add(item);
                    Map<string,List<Commission__c>> temp_commission_map = new Map<string,List<Commission__c>>();
                    temp_commission_map.put(item.Opportunity__r.X3rd_Party_Partner__c,temp_commission_list);
                    commission_map.put('M3',temp_commission_map);
                }
            }
            if(selectedMilestone.contains('Clawbacks') && (item.M1_Clawback_Applied_to_Balance_Paid_Date__c >=fromDate && item.M1_Clawback_Applied_to_Balance_Paid_Date__c <=toDate))
            {
                if(item.M1_Clawback_Applied_Paid__c == true && commission_map.containsKey('Cancellation Clawback'))
                {
                    Map<string,List<Commission__c>> temp_commission_map = commission_map.get('Cancellation Clawback');
                    if(temp_commission_map.containsKey(item.Opportunity__r.X3rd_Party_Partner__c))
                    {
                        List<Commission__c> temp_commission_list = temp_commission_map.get(item.Opportunity__r.X3rd_Party_Partner__c);
                        temp_commission_list.add(item);
                    }
                    else
                    {
                        List<Commission__c> temp_commission_list = new List<Commission__c>();
                        temp_commission_list.add(item);
                        temp_commission_map.put(item.Opportunity__r.X3rd_Party_Partner__c,temp_commission_list);
                    }
                    
                }
                else if(item.M1_Clawback_Applied_Paid__c == true)
                {
                    List<Commission__c> temp_commission_list = new List<Commission__c>();
                    temp_commission_list.add(item);
                    Map<string,List<Commission__c>> temp_commission_map = new Map<string,List<Commission__c>>();
                    temp_commission_map.put(item.Opportunity__r.X3rd_Party_Partner__c,temp_commission_list);
                    commission_map.put('Cancellation Clawback',temp_commission_map);
                }
            }
        }
    }
    
    public static void generateTableForProcessedCommission(List<Commission__c> commission_list, Map<string,Map<string,List<Commission__c>>> commission_map,string selectedMilestone,date fromDate,date toDate)
    {
       Set<String> excluded_stages = new Set<string>();
       excluded_stages.add('9. Change Order Pending');
       excluded_stages.add('Closed Lost');
       excluded_stages.add('Cancelled');
       for(Commission__c item:commission_list)
        {
            if(selectedMilestone.contains('M1') && (item.Milestone_1_Processed_Date__c >=fromDate && item.Milestone_1_Processed_Date__c <=toDate) && !excluded_stages.contains(item.Opportunity__r.StageName))
            {
                if(item.Milestone_1_Processed__c == true && commission_map.containsKey('M1'))
                {
                    Map<string,List<Commission__c>> temp_commission_map = commission_map.get('M1');
                    if(temp_commission_map.containsKey(item.Opportunity__r.X3rd_Party_Partner__c))
                    {
                        List<Commission__c> temp_commission_list = temp_commission_map.get(item.Opportunity__r.X3rd_Party_Partner__c);
                        temp_commission_list.add(item);
                    }
                    else
                    {
                        List<Commission__c> temp_commission_list = new List<Commission__c>();
                        temp_commission_list.add(item);
                        temp_commission_map.put(item.Opportunity__r.X3rd_Party_Partner__c,temp_commission_list);
                    }
                    
                }
                else if(item.Milestone_1_Processed__c == true)
                {
                    List<Commission__c> temp_commission_list = new List<Commission__c>();
                    temp_commission_list.add(item);
                    Map<string,List<Commission__c>> temp_commission_map = new Map<string,List<Commission__c>>();
                    temp_commission_map.put(item.Opportunity__r.X3rd_Party_Partner__c,temp_commission_list);
                    commission_map.put('M1',temp_commission_map);
                }
            }
            
            if(selectedMilestone.contains('M2') && (item.Milestone_2_Processed_Date__c >=fromDate && item.Milestone_2_Processed_Date__c <=toDate) && !excluded_stages.contains(item.Opportunity__r.StageName))
            {
                
                if(item.Milestone_2_Processed__c == true && commission_map.containsKey('M2'))
                {
                    Map<string,List<Commission__c>> temp_commission_map = commission_map.get('M2');
                    if(temp_commission_map.containsKey(item.Opportunity__r.X3rd_Party_Partner__c))
                    {
                        List<Commission__c> temp_commission_list = temp_commission_map.get(item.Opportunity__r.X3rd_Party_Partner__c);
                        temp_commission_list.add(item);
                    }
                    else
                    {
                        List<Commission__c> temp_commission_list = new List<Commission__c>();
                        temp_commission_list.add(item);
                        temp_commission_map.put(item.Opportunity__r.X3rd_Party_Partner__c,temp_commission_list);
                    }
                    
                }
                else if(item.Milestone_2_Processed__c == true)
                {
                    List<Commission__c> temp_commission_list = new List<Commission__c>();
                    temp_commission_list.add(item);
                    Map<string,List<Commission__c>> temp_commission_map = new Map<string,List<Commission__c>>();
                    temp_commission_map.put(item.Opportunity__r.X3rd_Party_Partner__c,temp_commission_list);
                    commission_map.put('M2',temp_commission_map);
                }
            }
            
            if(selectedMilestone.contains('M3') && (item.Milestone_3_Processed_Date__c >=fromDate && item.Milestone_3_Processed_Date__c <=toDate) && !excluded_stages.contains(item.Opportunity__r.StageName))
            {
                if(item.Milestone_3_Processed__c == true && commission_map.containsKey('M3'))
                {
                    Map<string,List<Commission__c>> temp_commission_map = commission_map.get('M3');
                    if(temp_commission_map.containsKey(item.Opportunity__r.X3rd_Party_Partner__c))
                    {
                        List<Commission__c> temp_commission_list = temp_commission_map.get(item.Opportunity__r.X3rd_Party_Partner__c);
                        temp_commission_list.add(item);
                    }
                    else
                    {
                        List<Commission__c> temp_commission_list = new List<Commission__c>();
                        temp_commission_list.add(item);
                        temp_commission_map.put(item.Opportunity__r.X3rd_Party_Partner__c,temp_commission_list);
                    }
                    
                }
                else if(item.Milestone_3_Processed__c == true)
                {
                    List<Commission__c> temp_commission_list = new List<Commission__c>();
                    temp_commission_list.add(item);
                    Map<string,List<Commission__c>> temp_commission_map = new Map<string,List<Commission__c>>();
                    temp_commission_map.put(item.Opportunity__r.X3rd_Party_Partner__c,temp_commission_list);
                    commission_map.put('M3',temp_commission_map);
                }
            }
            
            if(selectedMilestone.contains('Clawbacks') && (item.M1_Clawback_Processed_Date__c >=fromDate && item.M1_Clawback_Processed_Date__c <=toDate))
            {
                if(item.M1_Clawback_Complete__c == true && commission_map.containsKey('Cancellation Clawback'))
                {
                    Map<string,List<Commission__c>> temp_commission_map = commission_map.get('Cancellation Clawback');
                    if(temp_commission_map.containsKey(item.Opportunity__r.X3rd_Party_Partner__c))
                    {
                        List<Commission__c> temp_commission_list = temp_commission_map.get(item.Opportunity__r.X3rd_Party_Partner__c);
                        temp_commission_list.add(item);
                    }
                    else
                    {
                        List<Commission__c> temp_commission_list = new List<Commission__c>();
                        temp_commission_list.add(item);
                        temp_commission_map.put(item.Opportunity__r.X3rd_Party_Partner__c,temp_commission_list);
                    }
                    
                }
                else if(item.M1_Clawback_Complete__c == true)
                {
                    List<Commission__c> temp_commission_list = new List<Commission__c>();
                    temp_commission_list.add(item);
                    Map<string,List<Commission__c>> temp_commission_map = new Map<string,List<Commission__c>>();
                    temp_commission_map.put(item.Opportunity__r.X3rd_Party_Partner__c,temp_commission_list);
                    commission_map.put('Cancellation Clawback',temp_commission_map);
                }
            }
 
        }
    }
}