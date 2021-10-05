public with sharing class CommissionTrackerExportControllerLgtng {
    
    @AuraEnabled
    public static string getReport(String fromDate,String toDate, String selectedProvider,String milestone, Integer reportType, Boolean paidMileStone){

        try {
            String defaultFromDate = DateTime.now().addDays(-360).date().format();
            String defaultToDate = DateTime.now().date().format();

            CommissionTrackerReport ctr = new CommissionTrackerReport(
                fromDate != null ? fromDate : defaultFromDate,
                toDate != null ? toDate : defaultToDate,
                selectedProvider,
                milestone,
                reportType,
                paidMileStone
            );
            return ctr.getCsvString();
        } catch (Exception ex) {
            AuraHandledException aex = new AuraHandledException(ex.getMessage());
            aex.setMessage(ex.getMessage());
            throw aex;
        }
    }

    private class CommissionTrackerReport{
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

        public CommissionTrackerReport(String fromDate,String toDate, String selectedProvider,String milestone, Integer reportTypeNumber, Boolean paidMilestoneBool){
			
            fromDateExport = fromDate;
            toDateExport = toDate;
            selected3rdPartyProvider = selectedProvider;
            selectedMilestone = milestone;
            reportType = reportTypeNumber; 
            paidMileStone = paidMilestoneBool;
            string soql;

            if(reportType == 1) {
                soql = commissionToBeProcessedSOQL();
            } else if(reportType == 2) {
                soql = commissionProcessedSOQL();
            } else if(reportType == 3) {
                soql = commissionPaidSOQL();
            }

            commission_list = new List<Commission__c>();
            commission_list = (List<Commission__c>)Database.query(soql);

            if(reportType == 1) {
                generateMileStoneMapForCommissionToBeProcessed();
            } else if(reportType == 2) {
                generateMileStoneMapForProcessedCommission();
            // populateProcessCommissionList();
            } else if(reportType == 3) {
                generateMileStoneMapForPaidCommission();  
                //populateCommissionPaidList();
            }
            
            pouplatePartyProviderMapForCalculation();
        }

        private void generateMileStoneMapForCommissionToBeProcessed() {
            mileStoneMap = new Map<string,List<Commission__c>>();

            for(commission__c item:commission_list) {
                if(mileStoneMap.containsKey(item.Milestone_Payments__c)) {
                    List<Commission__c> temp_commission_list = milestoneMap.get(item.Milestone_Payments__c);
                    temp_commission_list.add(item);
                } else {
					List<Commission__c> temp_commission_list = new List<Commission__c>();
					temp_commission_list.add(item);
					mileStoneMap.put(item.Milestone_Payments__c,temp_commission_list);
                }
            }
        }

        private void generateMileStoneMapForProcessedCommission() {

            mileStoneMap = new Map<string,List<Commission__c>>();
            date start_date = getDate(fromDateExport);
            date end_date  = getDate(toDateExport);
            Set<String> excluded_stages = new Set<string>();
            excluded_stages.add('9. Change Order Pending');
            excluded_stages.add('Closed Lost');
            excluded_stages.add('Cancelled');

            for(Commission__c item:commission_list) {

                if(selectedMilestone.contains('M1') && (item.Milestone_1_Processed_Date__c >=start_date && item.Milestone_1_Processed_Date__c <=end_date) && !excluded_stages.contains(item.Opportunity__r.StageName)) {

                    if(item.Milestone_1_Processed__c == true && mileStoneMap.containsKey('M1')) {
                        List<Commission__c> temp_commission_list = mileStoneMap.get('M1');
                        temp_commission_list.add(item);
                    }
                    else if(item.Milestone_1_Processed__c == true) {
                        List<Commission__c> temp_commission_list = new List<Commission__c>();
                        temp_commission_list.add(item);
                        mileStoneMap.put('M1',temp_commission_list);
                    }
                }
                
                if(selectedMilestone.contains('M2') && (item.Milestone_2_Processed_Date__c >=start_date && item.Milestone_2_Processed_Date__c <=end_date) && !excluded_stages.contains(item.Opportunity__r.StageName)) {
                    
                    if(item.Milestone_2_Processed__c == true && mileStoneMap.containsKey('M2')) {
                        List<Commission__c> temp_commission_list = mileStoneMap.get('M2');
                        temp_commission_list.add(item);
                        
                    } else if(item.Milestone_2_Processed__c == true) {
                        List<Commission__c> temp_commission_list = new List<Commission__c>();
                        temp_commission_list.add(item);
                        mileStoneMap.put('M2',temp_commission_list);
                    }
                }
                
                if(selectedMilestone.contains('M3') && (item.Milestone_3_Processed_Date__c >=start_date && item.Milestone_3_Processed_Date__c <=end_date) && !excluded_stages.contains(item.Opportunity__r.StageName)) {

                    if(item.Milestone_3_Processed__c == true && mileStoneMap.containsKey('M3')) {
                        List<Commission__c> temp_commission_list = mileStoneMap.get('M3');
                        temp_commission_list.add(item);
                        
                    } else if(item.Milestone_3_Processed__c == true) {
                        List<Commission__c> temp_commission_list = new List<Commission__c>();
                        temp_commission_list.add(item);
                        mileStoneMap.put('M3',temp_commission_list);
                    }
                }
                
                if(selectedMilestone.contains('Clawbacks') && (item.M1_Clawback_Processed_Date__c >=start_date && item.M1_Clawback_Processed_Date__c <=end_date)) {

                    if(item.M1_Clawback_Complete__c == true && mileStoneMap.containsKey('Cancellation Clawback')) {

                        List<Commission__c> temp_commission_list = mileStoneMap.get('Cancellation Clawback');
                        temp_commission_list.add(item);
                        
                    }

                    else if(item.M1_Clawback_Complete__c == true) {
                        List<Commission__c> temp_commission_list = new List<Commission__c>();
                        temp_commission_list.add(item);
                        mileStoneMap.put('Cancellation Clawback',temp_commission_list);
                    }
                }
     
            }
        }
        private void generateMileStoneMapForPaidCommission() {

            mileStoneMap = new Map<string,List<Commission__c>>();
            date start_date = getDate(fromDateExport);
            date end_date  = getDate(toDateExport);

            for(Commission__c item:commission_list) {
                if(selectedMilestone.contains('M1') && (item.Milestone_1_Paid_Date__c >=start_date && item.Milestone_1_Paid_Date__c <=end_date)) {
                    
                    if(item.Milestone_1_Paid__c == true && mileStoneMap.containsKey('M1')) {
                        List<Commission__c> temp_commission_list = mileStoneMap.get('M1');
                        temp_commission_list.add(item);
                        
                    } else if(item.Milestone_1_Paid__c == true) {
                        List<Commission__c> temp_commission_list = new List<Commission__c>();
                        temp_commission_list.add(item);
                        mileStoneMap.put('M1',temp_commission_list);
                    }
                }

                if(selectedMilestone.contains('M2') && (item.Milestone_2_Paid_Date__c >=start_date && item.Milestone_2_Paid_Date__c <=end_date)) {

                    if(item.Milestone_2_Paid__c == true && mileStoneMap.containsKey('M2')) {

                        List<Commission__c> temp_commission_list = mileStoneMap.get('M2');
                        temp_commission_list.add(item);

                    } else if(item.Milestone_2_Paid__c == true) {
                        List<Commission__c> temp_commission_list = new List<Commission__c>();
                        temp_commission_list.add(item);
                        mileStoneMap.put('M2',temp_commission_list);
                    }
                }

                if(selectedMilestone.contains('M3') && (item.Milestone_3_Paid_Date__c >=start_date && item.Milestone_3_Paid_Date__c <=end_date)) {
                    
                    if(item.Milestone_3_Paid__c == true && mileStoneMap.containsKey('M3')) {

                        List<Commission__c> temp_commission_list = mileStoneMap.get('M3');
                        temp_commission_list.add(item);
                        
                    } else if(item.Milestone_3_Paid__c == true) {
                        List<Commission__c> temp_commission_list = new List<Commission__c>();
                        temp_commission_list.add(item);
                        mileStoneMap.put('M3',temp_commission_list);
                    }
                }

                if(selectedMilestone.contains('Clawbacks') && (item.M1_Clawback_Applied_to_Balance_Paid_Date__c >=start_date && item.M1_Clawback_Applied_to_Balance_Paid_Date__c <=end_date)) {

                    if(item.M1_Clawback_Applied_Paid__c == true && mileStoneMap.containsKey('Cancellation Clawback')) {
                        List<Commission__c> temp_commission_list = mileStoneMap.get('Cancellation Clawback');
                        temp_commission_list.add(item);
                        
                    } else if(item.M1_Clawback_Applied_Paid__c == true) {
                        List<Commission__c> temp_commission_list = new List<Commission__c>();
                        temp_commission_list.add(item);
                        mileStoneMap.put('Cancellation Clawback',temp_commission_list);
                    }
                }
            }
        }

        private date getDate(string date_in_str) {

            List<String> date_parts = date_in_str.split('/');
            Date final_date = Date.newinstance(integer.valueOf(date_parts[2]),integer.valueOf(date_parts[0]),integer.valueOf(date_parts[1]));
            return final_date;
        }

        private void pouplatePartyProviderMapForCalculation() {

            partyProviderCal = new Map<string,decimal>();
            partyProviderCalPerMileStone = new Map<string,decimal>();

            for(string milestone:mileStoneMap.keySet()) {

                List<Commission__c> temp_commission_list = mileStoneMap.get(milestone);

                for(Commission__c item:temp_commission_list) {

                    decimal total = 0;

                    if(reportType == 1 && milestone == 'M1' && item.Milestone_1_Amount__c != null) {
                        total = item.Milestone_1_Amount__c;
                    } else if( milestone == 'M1' && item.Milestone_1_Amount_Actual_Paid__c != null) {
                        total = item.Milestone_1_Amount_Actual_Paid__c;
                    }

                    if(reportType == 1 && milestone == 'M2' && item.Milestone_2_Amount__c !=null) {

                      total = item.Milestone_2_Amount__c;  

                    } else if(milestone == 'M2' && item.Milestone_2_Amount_Actual_Paid__c !=null) {
                        total = item.Milestone_2_Amount_Actual_Paid__c;
                    }
                    
                    if(reportType == 1 && milestone == 'M3' && item.Milestone_3_Amount__c !=null) {

                      total = item.Milestone_3_Amount__c;

                    } else if(milestone == 'M3' && item.Milestone_3_Actual_Paid__c !=null) {
                        total = item.Milestone_3_Actual_Paid__c;  
                    }
                    
                    if(reportType == 1 && milestone == 'Cancellation Clawback' && item.M1_Clawback_Amount__c != null) {
                        total = (-1) * item.M1_Clawback_Amount__c;

                    } else if(milestone == 'Cancellation Clawback' && item.Clawback_Amount_Actual__c != null) {
                        total = (-1) * item.Clawback_Amount_Actual__c;
                    }

                    if(partyProviderCal.ContainsKey(item.Opportunity__r.X3rd_Party_Partner__c)) {

                        decimal party_amount = partyProviderCal.get(item.Opportunity__r.X3rd_Party_Partner__c);
                        party_amount +=total;
                        partyProviderCal.put(item.Opportunity__r.X3rd_Party_Partner__c,party_amount);

                    } else {
                        partyProviderCal.put(item.Opportunity__r.X3rd_Party_Partner__c,total);
                    }
                    
                    if(partyProviderCalPerMileStone.ContainsKey(item.Opportunity__r.X3rd_Party_Partner__c+'-'+milestone)) {

                        decimal party_amount_per_milestone = partyProviderCalPerMileStone.get(item.Opportunity__r.X3rd_Party_Partner__c+'-'+milestone);
                        party_amount_per_milestone +=total;
                        partyProviderCalPerMileStone.put(item.Opportunity__r.X3rd_Party_Partner__c+'-'+milestone,party_amount_per_milestone);

                    } else {
                        partyProviderCalPerMileStone.put(item.Opportunity__r.X3rd_Party_Partner__c+'-'+milestone,total);
                    }
                }
            }
        }
        private decimal getM1Total() {
            if(selectedMilestone.contains('M1')) {

                decimal m1_total = 0;

                for(string milestone:mileStoneMap.keySet()) {

                    if(milestone == 'M1') {

                        List<Commission__c> temp_commission_list = mileStoneMap.get(milestone);

                        for(Commission__c item:temp_commission_list) {
							
                            if(reportType == 1 && item.Milestone_1_Amount__c !=null) {

                                m1_total +=item.Milestone_1_Amount__c;

                            } else if(item.Milestone_1_Amount_Actual_Paid__c!= null) {

                                m1_total +=item.Milestone_1_Amount_Actual_Paid__c; 
                            }
                        }
                    }
                }
                return m1_total;
            }
           return 0;
        }

        private decimal getM2Total() {
            
            if(selectedMilestone.contains('M2')) {

                decimal m2_total = 0;

                for(string milestone:mileStoneMap.keySet()) {

                    if(milestone == 'M2') {

                        List<Commission__c> temp_commission_list =  mileStoneMap.get(milestone);

                        for(Commission__c item:temp_commission_list) {

                            if(reportType == 1 && item.Milestone_2_Amount__c != null) {

                                m2_total +=item.Milestone_2_Amount__c;

                            } else if(item.Milestone_2_Amount_Actual_Paid__c != null) {

                                m2_total += item.Milestone_2_Amount_Actual_Paid__c;
                            }
                            
                        }
                    }
                }
                return m2_total;
            }
           return 0;
        }
        
        private decimal getM3Total() {
            
            if(selectedMilestone.contains('M3')) {
                
                    decimal m3_total = 0;
					
                    for(string milestone:mileStoneMap.keySet()) {

                        if(milestone == 'M3') {

                            List<Commission__c> temp_commission_list =  mileStoneMap.get(milestone);

                            for(Commission__c item:temp_commission_list) {
                                if(reportType== 1 && item.Milestone_3_Amount__c != null) {

                                    m3_total +=item.Milestone_3_Amount__c;

                                } else if(item.Milestone_3_Actual_Paid__c != null) {

                                    m3_total +=item.Milestone_3_Actual_Paid__c;
                                }
                            }
                        }
                    }
                    return m3_total;
                }
          return 0;
        }
        
        private decimal getClawBackTotal() {

            if(selectedMilestone.contains('Clawbacks')) {

                decimal clawback_total = 0;

                for(string milestone:mileStoneMap.keySet()) {

                    if(milestone == 'Cancellation Clawback') {

                        List<Commission__c> temp_commission_list =  mileStoneMap.get(milestone);

                        for(Commission__c item:temp_commission_list) {

                            if(reportType == 1 && item.M1_Clawback_Amount__c != null) {

								clawback_total +=item.M1_Clawback_Amount__c;

                            } else if(item.Clawback_Amount_Actual__c != null) {

                                clawback_total += item.Clawback_Amount_Actual__c;
                            }
                        }
                    }
                }
                return clawback_total;
            }
            return 0;
        }
        private string commissionToBeProcessedSOQL() {
            
            date from_date = getDate(fromDateExport);
            date to_date  = getDate(toDateExport);
            DateTime start_date = dateTime.newinstance(from_date,Time.newInstance(0, 0, 0, 0));
            DateTime end_date = dateTime.newinstance(to_date,Time.newInstance(0, 0, 0, 0));
            string soql = CommissionTrackerLgtngUtility.commissionToBeProcessedSOQL(selectedMilestone,selected3rdPartyProvider,start_date,end_date, true);
            return soql;
        }
        
        private string commissionProcessedSOQL() {

            date from_date = getDate(fromDateExport);
            date to_date  = getDate(toDateExport);
            DateTime start_date = dateTime.newinstance(from_date,Time.newInstance(0, 0, 0, 0));
            DateTime end_date = dateTime.newinstance(to_date,Time.newInstance(0, 0, 0, 0));
            string soql = CommissionTrackerLgtngUtility.commissionProcessedSOQL(selectedMilestone,selected3rdPartyProvider,start_date,end_date,paidMileStone, true);
            return soql;
        }
        
        private string commissionPaidSOQL() {

            date from_date = getDate(fromDateExport);
            date to_date  = getDate(toDateExport);
            DateTime start_date = dateTime.newinstance(from_date,Time.newInstance(0, 0, 0, 0));
            DateTime end_date = dateTime.newinstance(to_date,Time.newInstance(0, 0, 0, 0));
            string soql = CommissionTrackerLgtngUtility.commissionPaidSOQL(selectedMilestone,selected3rdPartyProvider,start_date,end_date, true);
            return soql;
        }
    
        public String getCsvString() {

            String[] rows = new String[0];
            String[] line = new String[0];
            rows.addAll(getDateRange());
            rows.addAll(getMileStoneSum());
            rows.addAll(getByProvider());
            rows.addAll(getCommission());
            return String.join(rows,'\n');
        }
        
        private string[] getDateRange() {

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
        
        private string[] getMileStoneSum() {

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
        
        private string[] getByProvider() {

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

            for(string party_provider:partyProviderCal.keyset()) {

                decimal total = partyProviderCal.get(party_provider);
                line = new String[0];
                line.add(party_provider.replace(',', ''));
                line.add('$ '+string.valueOf(total));
                line.add('');

                if(partyProviderCalPerMileStone.containsKey(party_provider+'-M1')) {

                    decimal total_per_milestone = partyProviderCalPerMileStone.get(party_provider+'-M1');
                    line.add('$ '+string.valueOf(total_per_milestone));
                    m1_total +=total_per_milestone;

                } else {
                    line.add('');
                }

                if(partyProviderCalPerMileStone.containsKey(party_provider+'-M2')) {

                    decimal total_per_milestone = partyProviderCalPerMileStone.get(party_provider+'-M2');
                    line.add('$ '+string.valueOf(total_per_milestone));
                    m2_total += total_per_milestone;

                } else {
                    line.add('');
                }

                if(partyProviderCalPerMileStone.containsKey(party_provider+'-M3')) {

                    decimal total_per_milestone = partyProviderCalPerMileStone.get(party_provider+'-M3');
                    line.add('$ '+string.valueOf(total_per_milestone));
                    m3_total +=total_per_milestone;

                } else {
                    line.add('');
                }

                if(partyProviderCalPerMileStone.containsKey(party_provider+'-Cancellation Clawback')) {

                    decimal total_per_milestone = partyProviderCalPerMileStone.get(party_provider+'-Cancellation Clawback');
                    line.add('$ '+string.valueOf(total_per_milestone));
                    clawback_total +=total_per_milestone;

                } else {
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
        
        private string[] getCommission() {
            String[] line = new String[0];
            String[] rows = new String[0];
			line.add('Channel Partner');
            line.add('3rd Party Partner');
            line.add('3rd Party Salesrep');
            line.add('MileStone Payments');
            line.add('Commission Number');
            line.add('18 Character Opportunity ID');
            line.add('Opportunity Name');
			line.add('Account Name');
			line.add('Billing Address');
			line.add('Location');
            line.add('Contract Received Date');
            line.add('System Size Calculated (kW)');
            line.add('CP Base / Watt');
			line.add('Opportunity Amount');
            line.add('CP Base');
            line.add('Dealer Fees');
            line.add('"Total Adders, Upgrade & Incentives"');
            line.add('Total Commissions');
			line.add('Total Commissions Paid (To Date)');
			line.add('Commissions Payable');
			line.add('M1 %');
			line.add('M2 %');
			line.add('M3 %');
            line.add('Contract Received Confirmed Date');
            line.add('Milestone 1 Processed Date');
            line.add('Milestone 1 Amount');
            line.add('Milestone 1 Amount (Actual Paid)');
            line.add('Milestone 1 Paid Date');
            line.add('Installation Complete Date');
			line.add('Milestone 2 Processed Date');
			line.add('Milestone 2 Commission True-Up');
            line.add('Milestone 2 Amount');
            line.add('Milestone 2 Amount (Actual Paid)');
            line.add('Milestone 2 Paid Date');
			line.add('PTO / Net Meter Installed Date');
			line.add('Milestone 3 Processed Date');
            line.add('Milestone 3 Commission True-Up');
            line.add('Milestone 3 Amount');
            line.add('Milestone 3 Amount Actual Paid');
			line.add('Milestone 3 Paid Date');
            line.add('Cancellation Date');
            line.add('M1 Clawback Processed Date');
            line.add('M1 Clawback Amount');
            line.add('Clawback Amount (Actual)');
			line.add('M1 Clawback Applied to Balance (Paid) Date');
            line.add('Stage');
            line.add('Financing Tool');
            line.add('Loan Term');
            line.add('APR %');
            line.add('Dealer Fee%');
            line.add('Number of Solar Panels');
            line.add('Roof Type');
            line.add('Number of Stories');
            line.add('Array Tilt (Highest)');
            line.add('Trenching Distance');
            line.add('Palmetto Digital Appointment');
            line.add('Battery Qty');
            line.add('Solar Edge 25 yr Extended Warranty');
            line.add('Total Adders');
            line.add('Roof Type Adder');
            line.add('High Roof Adder');
            line.add('Roof Tilt Adder');
            line.add('Trenching Distance Adder');
            line.add('Ground Mount Adder');
            line.add('Palmetto Digital Appointment Fee');
            line.add('Appointment Success Fee (Adder)');
            line.add('CT GreenBank Incentive');
            line.add('Battery Adder');
            line.add('Palmetto Home Adder');
            line.add('Solar Edge Warranty Adder');
            line.add('Total Upgrades Cost');
            line.add('Re-Roof Upgrade Cost');
            line.add('Structural Upgrade Cost');
            line.add('Electrical Upgrade Cost');
            line.add('Tree Removal / Other Upgrade Cost');
            line.add('Other / Misc Adjustments');
            //Column added for card #804. 8/24/2020
            line.add('Palmetto Protect Cost');
			//New report End here
            //line.add('Opportunity Owner'); Commented on 29 June
            //line.add('Install Completion Approved Date');
            //line.add('Amount'); Commented on 29 June
            //line.add('Price / Watt'); Commented on 29 June
            //line.add('Panel Type Adder'); Commented on 29 June
            //line.add('M3%');
            //line.add('Change Order Reason'); Commented on 29 June
            //line.add('Lead Source Type'); Commented on 29 June
            
            rows.add(String.join(line, ','));

            Map<string,Map<string,List<Commission__c>>> commission_map = new Map<string,Map<string,List<Commission__c>>>();

            date fromDate;
            date toDate;
            date start_date = getDate(fromDateExport);
            date end_date  = getDate(toDateExport);
            fromDate = start_date;
            toDate = end_date;

            if(reportType == 1){

                CommissionTrackerLgtngUtility.generateTableForCommissionToBeProcessed(commission_list,commission_map);

            } else if(reportType == 2) {

                CommissionTrackerLgtngUtility.generateTableForProcessedCommission(commission_list, commission_map,selectedMilestone,fromDate,toDate);

            } else if(reportType == 3) {

                CommissionTrackerLgtngUtility.generateTableForPaidCommission(commission_list, commission_map,selectedMilestone,fromDate,toDate);
            }

            List<String> milestone_list = new List<String>();

            if(commission_map.ContainsKey('M1')) {
                milestone_list.add('M1');
            }
            if(commission_map.containsKey('M2')) {
                milestone_list.add('M2');
            }
            
            if(commission_map.ContainsKey('M3')) {
                milestone_list.add('M3');
            }
            
            if(commission_map.ContainsKey('Cancellation Clawback')) {
                milestone_list.add('Cancellation Clawback');
            }

            for(string milestone_key:milestone_list) {
                Map<string,List<Commission__c>> commission_per_milestone_map = commission_map.get(milestone_key);
                
                /*line = new String[0];
                line.add(milestone_key);
                rows.add(String.join(line, ','));*/
                for(string partner: commission_per_milestone_map.keyset()) {
                    List<Commission__c> commissions = commission_per_milestone_map.get(partner);

                    for(Commission__c item:commissions) {
                        
                        line = new String[0];
						line.add(item.Opportunity__r.Channel_Partner__c);
                        line.add(item.Opportunity__r.X3rd_Party_Partner__c.replace(',',''));
                        line.add(item.Opportunity__r.X3rd_Party_Sales_Rep__c);
                        line.add(milestone_key);
                        line.add(item.Name);
                        line.add(item.X18_Character_Opportunity_ID__c);
                        line.add(item.Opportunity__r.Name);
						line.add(item.Account_Name_c__c);
						line.add(item.Opportunity__r.Address__c);
						line.add(item.Location__c);
                        line.add(string.valueof(item.Contract_Received_Date__c));
                        line.add(string.valueof(item.Opportunity__r.System_Size_Calculated_kW__c));
                        line.add(string.valueof(item.CP_Base_Watt__c));
                        line.add(string.valueof(item.Opportunity_Amount__c));
                        line.add(string.valueof(item.CP_Base__c));
                        line.add(string.valueof(item.Dealer_Fees__c));
                        line.add(string.valueof(item.Total_Adders_Upgrade_Incentives__c));
                        line.add(string.valueOf(item.Total_Commissions__c));
                        line.add(string.valueOf(item.Total_Commissions_Paid_To_Date__c));
						line.add(string.valueOf(item.Balance_Due_Commissions__c));
						line.add(string.valueOf(item.M1__c));
						line.add(string.valueOf(item.M2__c));
						line.add(string.valueOf(item.M3__c));
                        line.add(string.valueof(item.Opportunity__r.Contract_Received_Confirmed_Date__c));
						line.add(string.valueOf(item.Milestone_1_Processed_Date__c));
                        line.add(string.valueOf(item.Milestone_1_Amount__c));
                        line.add(string.valueOf(item.Milestone_1_Amount_Actual_Paid__c));
                        line.add(string.valueof(item.Milestone_1_Paid_Date__c));
						line.add(string.valueof(item.Installation_Complete_Date__c));
						line.add(string.valueOf(item.Milestone_2_Processed_Date__c));
                        line.add(string.valueOf(item.Milestone_2_Commission_True_Up__c));
                        line.add(string.valueof(item.Milestone_2_Amount__c));
                        line.add(String.valueof(item.Milestone_2_Amount_Actual_Paid__c));
                        line.add(string.valueof(item.Milestone_2_Paid_Date__c));
						line.add(string.valueof(item.PTO_Net_Meter_Installed_Date__c));
						line.add(string.valueOf(item.Milestone_3_Processed_Date__c));
                        line.add(string.valueOf(item.Milestone_3_Commission_True_Up__c));
                        line.add(string.valueOf(item.Milestone_3_Amount__c));
                        line.add(string.valueOf(item.Milestone_3_Actual_Paid__c));
                        line.add(string.valueof(item.Milestone_3_Paid_Date__c));
                        line.add(string.valueof(item.Opportunity__r.Cancellation_Date__c));
						line.add(string.valueof(item.M1_Clawback_Processed_Date__c));
                        line.add(string.valueof(item.M1_Clawback_Amount__c));
                        line.add(string.valueof(item.Clawback_Amount_Actual__c));
						line.add(string.valueof(item.M1_Clawback_Applied_to_Balance_Paid_Date__c));
                        line.add(item.Opportunity__r.StageName);
                        line.add(item.Opportunity__r.Financing_Tool__c);
                        line.add(string.valueof(item.Loan_Term__c));
                        line.add(item.APR__c);
                        line.add(string.valueof(item.Dealer_Fee_Percent__c));
						line.add(string.valueof(item.Opportunity__r.Number_of_Solar_Panels__c));
						line.add(item.Opportunity__r.Roof_Type__c);
						line.add(string.valueof(item.Opportunity__r.Number_of_Stories__c));
						line.add(string.valueof(item.Opportunity__r.Array_Tilt_Highest__c));
						line.add(string.valueof(item.Opportunity__r.Trenching_Distance__c)); 
						line.add(string.valueof(item.Opportunity__r.Palmetto_Digital_Appointment__c));
						line.add(string.valueof(item.Opportunity__r.Battery_Qty__c));
						line.add(string.valueof(item.Opportunity__r.Solar_Edge_25_yr_Extended_Warranty__c));
                        line.add(string.valueof(item.Total_Adders__c));
                        line.add(string.valueof(item.Roof_Type_Adder__c));
                        line.add(string.valueOf(item.High_Roof_Adder__c));
                        line.add(string.valueof(item.Roof_Tilt_Adder__c));
                        line.add(string.valueof(item.Trenching_Distance_Adder__c));
                        line.add(string.valueof(item.Ground_Mount_Adder__c));
                        line.add(string.valueof(item.Opportunity__r.Palmetto_Digital_Appointment_Fee__c));
                        line.add(string.valueof(item.Appointment_Success_Fee__c));
                        line.add(string.valueof(item.CT_GreenBank_Adder__c));
                        line.add(string.valueof(item.Battery_Adder__c));
                        line.add(string.valueof(item.Palmetto_Home_Adder__c));
                        line.add(string.valueof(item.Solar_Edge_Warranty_Adder__c));
                        line.add(string.valueof(item.Structural_Electrical_Upgrade_Adder__c));
                        line.add(string.valueof(item.Roofing_Adder__c)); 
                        line.add(string.valueof(item.Structural_Upgrade_Adder__c));
                        line.add(string.valueof(item.Electrical_Upgrade_Adder__c));
                        line.add(string.valueof(item.Tree_Removal_Other_Adder__c));
                        line.add(string.valueof(item.Other_Misc_Adders__c));
                        //Column added for card #804. 8/24/2020
                        line.add(string.valueof(item.Palmetto_Protect_Cost__c));
						//line.add(item.Opportunity__r.Trenching_Distance); Field Missing
                        //line.add(item.Opportunity__r.Owner.Name); Commented on 29 jun
                        //line.add(string.valueof(item.Install_Completion_Approved_Date__c));
                        //line.add(string.valueof(item.Price_Watt__c)); Commented on 29 jun
                        //New Column added in CSV 11/20/2019 start      
                        //New Column added in CSV 11/20/2019 end
                        //line.add(string.valueof(item.Panel_Type_Adder__c));Commented on 29 jun
                        //line.add(string.valueof(item.Opportunity__r.Change_Order_Reason__c)); Commented on 29 jun
                        //line.add(string.valueof(item.Opportunity__r.Lead_Source_Type__c)); Commented on 29 jun
                        rows.add(String.join(line, ','));
                    }
                }
            }
            return rows;
            
        }
    }
}