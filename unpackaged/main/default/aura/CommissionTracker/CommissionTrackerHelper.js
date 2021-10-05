({
    fetchData : function(component, event) {
        component.set("v.isLoading", true);
        let params = {};
        //Obtain values from the inputs
		let selectedProviders = component.get("v.providerValues");
		
		if(component.get("v.includeInactives")) {
			let selectedInactiveProviders = component.get("v.inactiveProviderValues");
			if(selectedInactiveProviders) {
				for(let provider of selectedInactiveProviders) {
					selectedProviders.push(provider);
				}
			}
		}
        
        const selectedMilestones = component.get("v.milestoneValues");
        var fromDate = component.get("v.dateFrom");
        var toDate = component.get("v.dateTo");
        var mode;

        if(component.find("display") != undefined) {
           mode = component.find("display").get("v.value");
        }
        var showPaidMilestones = component.get("v.selectedPaid");

        if(!$A.util.isEmpty(selectedMilestones)) {
            params["selectedAllMilestones"] = selectedMilestones;
        }
        if(!$A.util.isEmpty(selectedProviders)) {
            params["selectedProviders"] = selectedProviders;
        }
        if(fromDate != null) {
            params["fromDate"] = fromDate;
        }
        if(toDate != null) {
            params["toDate"] = toDate;
        }
        if(mode != null) {
            params["mode"] = mode;
        }
        
        params["showPaidMilestones"] = showPaidMilestones;
        
        let helper = this;

        var action = component.get("c.getMilestonesData");

        action.setParams(
            params
        );

        action.setCallback(this, function(response) {
            var data = response.getReturnValue();
            var state = response.getState();

            if(state === 'SUCCESS') {
                //Commissions
                component.set("v.rawTData", data.data);
                var rawTDataa = component.get("v.rawTData");

                //Calculate providers quantity for pagination
                var providersLength = 0;
                for(var milestone of data.data) {
					console.log('milestone => ', milestone);
                    if(milestone.data.length > providersLength) {

                        providersLength = milestone.data.length;

                    }
                }
                component.set("v.providersLength", providersLength);

                //Populate providers picklist
                var providers = [];
                
                for(var i = 0; i < data.thirdPartyProviders.length; i++) {
                    if(data.thirdPartyProviders[i] != undefined) {
                        providers.push({'label':data.thirdPartyProviders[i], 'value':data.thirdPartyProviders[i]});
                    }
                    
                }
                component.set("v.availableProviders", providers);

				//New List for inactive providers
				var inactiveProviders = [];

				for(var i = 0; i < data.thirdInactivePartyProviders.length; i++) {
                    if(data.thirdInactivePartyProviders[i] != undefined) {
                        inactiveProviders.push({'label':data.thirdInactivePartyProviders[i], 'value':data.thirdInactivePartyProviders[i]});
                    }
                    
                }
                component.set("v.inactiveProviders", inactiveProviders);

                if(component.get("v.selectedAllProviders") && !component.get("v.firstExecution")) {

                    helper.selectAllProvidersHelper(component, event, helper);
                    component.set('v.searchStringProvider', providers.length + ' providers selected');
					if(component.get("v.selectedAllInactiveProviders")) {
						helper.selectAllInactiveProvidersHelper(component, event, helper);
                    	component.set('v.searchStringInactiveProvider', inactiveProviders.length + ' providers selected');
					}
                }

                if(component.get("v.firstExecution")) {

                    helper.selectAllProvidersHelper(component, event, helper);
                    component.set('v.searchStringProvider', providers.length + ' providers selected');
                    helper.selectAllMilestonesHelper(component,event,helper);
                    component.set('v.searchStringMilestone', 4 + ' milestones selected');
                    
                }
                //let processedTData = helper.prepareProcessedTData(component, data.commissions);
                let processedTData = helper.prepareProcessedTData(component, data.data);
                component.set(
                    "v.tData",
                    helper.getPage(1, component.get("v.pageSize"), processedTData)
                );
                component.set("v.isLoading", false);
                component.set("v.firstExecution", false);

            } else if(state === 'ERROR') {
                var error = response.getError();
                
                console.log('ERROR => ' +error);
                console.log(error[0]);
                console.log(error[0].message);
                this.fireToast("Error",error[0].message,"error");
                component.set("v.isLoading", false);
            } else {
                console.log('RETURN STATE => ', response.getState());
            }
        });

        $A.enqueueAction(action);
        
        
    },

    prepareProcessedTData : function(component, rawData) {

		const pageSize = component.get("v.pageSize");

		if(!rawData) {
			rawData = component.get("v.rawTData");
		}
		
		component.set("v.currentPage", 1);

		let filteredData = this.filterData(component, rawData);

        //**Commented sortData function because its not used */

		/*let processedTData = this.sortData(
			filteredData,
			component.get("v.tableSortedBy"),
			component.get("v.tableSortedDirection")
		);*/

        //Changed processedTData to filteredData

		component.set("v.processedTData", filteredData);
		//var calculatedSize = (processedTData.length / pageSize); Replaced for providersLength
        
        /* Commented 23:49 08-06
        var calculatedSize = (component.get("v.providersLength") / pageSize);
		component.set("v.calculatedSize", Math.ceil(calculatedSize));
        */
        this.calculateSize(component, filteredData);
        //Changed processedTData to filteredData

		return filteredData;
	},

    calculateSize : function(component, filteredData) {

        var calculatedSize = 0;
        var providersLength = 0;

        for(var milestone of filteredData) {
            if(milestone.data.length > providersLength) {

                providersLength = milestone.data.length;

            }
        }

        calculatedSize = providersLength / component.get("v.pageSize");
		component.set("v.calculatedSize", Math.ceil(calculatedSize));

        return calculatedSize;
    },

    filterData : function(component, rawData) {

        //Clone rawData because we don't want to affect the original data
        var rawDataCopy = JSON.parse(JSON.stringify(rawData));

		if(!component.get("v.filterState")) {
			//if the filters are off, return the data unchanged
			return rawData;
		}

		let filterFunction = this.prepareFilterFunctions(component);

		if(!filterFunction) {
			//If there are no active filters, don't filter.
			return rawData;
		}
        
		let filteredData = [];

        var selectedProviders = component.get("v.providerValues");
        var dateFrom = component.get("v.dateFrom");
        var dateTo = component.get("v.dateTo");
        var display = component.get("v.display");
		var type = component.get("v.commissionsFilter");

		for (let i = 0; i < rawDataCopy.length; i++) {

			const element = rawDataCopy[i];
            
			if(filterFunction(element)) {

                for(var j = 0; j < element.data.length; j++) {
					if(type == 'Negative') {

						if(element.data[j].CommissionResult > 0){

							element.data.splice(j, 1);
							
							j--;
						}

					} else if(type == 'Positive') {

						if(element.data[j].CommissionResult < 0){

							element.data.splice(j, 1);

							j--;
						}
					}

					if(j > 0) {
					
						if(!$A.util.isEmpty(selectedProviders)) {

							if(selectedProviders.includes(element.data[j].ProviderName)) {
								
							} else { 
								element.data.splice(j, 1);
									j--;
							}
						}
						/*for(var k = 0; k < element.data[j].CommissionsList.length; k++) {
							
							if(type == 'Negative') {

								if(element.data[j].CommissionsList[k].Total_Commissions__c > 0){

									element.data[j].CommissionsList.splice(k, 1);
					
									k--;
								}

							} else if(type == 'Positive') {

								if(element.data[j].CommissionsList[k].Total_Commissions__c < 0){

									element.data[j].CommissionsList.splice(k, 1);

									k--;
								}
							}

							if(!$A.util.isEmpty(selectedProviders)) {

								if(selectedProviders.includes(element.data[j].ProviderName)) {
									
								} else {

									element.data.splice(j, 1);
									j--;
								}
							}
						}*/
						if(element.data[j].CommissionsList.length == 0) {

							element.data.splice(j, 1);
							j--;
						}
					}
                }
				filteredData.push(element);
			}
		}
		
		return filteredData;
	},

    prepareFilterFunctions : function(component) {

        let selectedProvider = component.get("v.selectedProvider");
        var selectedProviders = component.get("v.providerValues");
        var selectedMilestones = component.get("v.milestoneValues");
		let dateFrom = component.get("v.dateFrom");
		let dateTo = component.get("v.dateTo");
        var display = component.get("v.display");
		let commissionsFilter = component.get("v.commissionsFilter");

		let filterFunctions = [];

        if(!$A.util.isEmpty(selectedMilestones)) {

           filterFunctions.push(function(elem) {
                   return selectedMilestones.includes(elem.milestone);
           });
       
        }

		if(commissionsFilter == 'Positive' || commissionsFilter == 'Negative') {

			var isTrue = false;
			var type = component.get("v.commissionsFilter");

			filterFunctions.push(function(elem) {
				console.log('elem milestone => ', elem.milestone);
				for(var provider of elem.data) {
					if(type == 'Negative') {

						isTrue = provider.CommissionResult < 0;

						if(isTrue) {
							break;
						}

					} else if(type == 'Positive') {

						isTrue = provider.CommissionResult > 0;

						if(isTrue) {
							break;
						}
					}

                    /*for(var commission of provider.CommissionsList) {

                        if(type == 'Negative') {

							isTrue = commission.Total_Commissions__c < 0;

							if(isTrue) {
								break;
							}

						} else if(type == 'Positive') {

							isTrue = commission.Total_Commissions__c > 0;

							if(isTrue) {
								break;
							}
						}
					}*/

					if(isTrue) {
						break;
					}	
				}
				return isTrue;
			});
		}

        if(!$A.util.isEmpty(selectedProviders)) {
            //If selectedProviders are found will return true or false and iterate back next milestone
            var isTrue = false;

            filterFunctions.push(function(elem) {

                for(var data of elem.data) {

                    isTrue = selectedProviders.includes(data.ProviderName);

                    if(isTrue) {
                        break;
                    }
                }
                return isTrue;
            });
        }

		if(filterFunctions.length == 0) {
			//If there are no active filters, don't filter.
			return false;
		}
		
		let result = function(elem) {
			for (let i = 0; i < filterFunctions.length; i++) {
				if(!filterFunctions[i](elem)) {
					//When a filter fails, the element should be discarded
					return false;
				}
			}
			//The element passed all filters
			return true;
		};
		
		return result;
	},

    sortData : function(tData, sortBy, sortDir) {
		tData.sort(this.prepareSortForField(sortBy, sortDir));
		
		return tData;
	},
	
	prepareSortForField : function(sortField, sortDir) {
		let sortDirValue = (sortDir == "desc")?1:-1
		if(sortField == "PaymentValue") {
			return function(a, b) {
				if(a.PaymentValue === undefined && b.PaymentValue != undefined) {
					return sortDirValue;
				}
				else if(b.PaymentValue === undefined && a.PaymentValue != undefined) {
					return -sortDirValue;
				}
				
				//+val forces val to beome a number
				if(+(a.PaymentValue) < +(b.PaymentValue)) {
					return sortDirValue;
				}
				else if (+(a.PaymentValue) > +(b.PaymentValue)) {
					return -sortDirValue;
				}
				else {
					return 0;
				}
			}
		}
		else {
			return function(a, b) {
				if(a[sortField] === undefined && b[sortField] != undefined) {
					return sortDirValue;
				}
				else if(b[sortField] === undefined && a[sortField] != undefined) {
					return -sortDirValue;
				}
				
				if(a[sortField] < b[sortField]) {
					return sortDirValue;
				}
				else if (a[sortField] > b[sortField]) {
					return -sortDirValue;
				}
				else {
					return 0;
				}
			}
		}
	},

    getPage : function(pageNum, pageSize, processedData) {

		let pageStart = (pageNum - 1) * pageSize;

        var tData = [];

        for(var milestone of processedData) {
            var tempData = [];
            tempData["milestone"] = milestone.milestone;
            tempData["data"] = milestone.data.slice(pageStart, pageStart + pageSize);
            tData.push(tempData);    
        }
		return tData;
	},

    execAsync : function(component, callback) {
		component.set("v.isLoading", true);
		setTimeout(function() {
			callback();
			component.set("v.isLoading", false);
		}, 0);
	},

    blurEventHelper : function(component, event) {

        var selectorFired = event.getSource().get("v.name");
        var multiSelect = component.get('v.multiSelect');
        
        switch(selectorFired) {
            case 'providerSelector':
                var selectedValue = component.get('v.providerSelector');
        
                var previousLabel;
                var count = 0;
                var options = component.get("v.availableProviders");

                options.forEach( function(element, index) {
                    if(element.value === selectedValue) {
                        previousLabel = element.label;
                    }
                    if(element.selected) {
                        count++;
                    }
                });

                if(multiSelect) {
                    component.set('v.searchStringProvider', count + ' providers selected');
                } else {
                    component.set('v.searchStringProvider', previousLabel);
                }

                $A.util.removeClass(component.find('providerDiv'),'slds-is-open');
            break;
			case 'inactiveProviderSelector':
                var selectedValue = component.get('v.inactiveProviderSelector');
        
                var previousLabel;
                var count = 0;
                var options = component.get("v.inactiveProviders");

                options.forEach( function(element, index) {
                    if(element.value === selectedValue) {
                        previousLabel = element.label;
                    }
                    if(element.selected) {
                        count++;
                    }
                });

                if(multiSelect) {
                    component.set('v.searchStringInactiveProvider', count + ' providers selected');
                } else {
                    component.set('v.searchStringInactiveProvider', previousLabel);
                }

                $A.util.removeClass(component.find('inactiveProviderDiv'),'slds-is-open');
            break;
            case 'milestoneSelector':
                var selectedValue = component.get('v.milestoneValue');
        
                var previousLabel;
                var count = 0;
                var options = component.get("v.availableMilestones");

                options.forEach( function(element, index) {
                    if(element.value === selectedValue) {
                        previousLabel = element.label;
                    }
                    if(element.selected) {
                        count++;
                    }
                });

                if(multiSelect) {
                    component.set('v.searchStringMilestone', count + ' milestones selected');
                } else {
                    component.set('v.searchStringMilestone', previousLabel);
                }

                $A.util.removeClass(component.find('milestoneDiv'),'slds-is-open');
            break;
            default:
                console.log('None selected');
        }   	
	},


    removePillHelper : function(component, event, helper) {
        var value = event.getSource().get('v.name');
        
        var fromPill = event.getSource().getLocalId();
        
        var multiSelect = component.get('v.multiSelect');
        var count = 0;

        switch(fromPill) {
            case 'providerPill':
                var options = component.get("v.availableProviders");
                var values = component.get('v.providerValues') || [];
                options.forEach( function(element, index) {
                    if(element.value === value) {
                        element.selected = false;
                        values.splice(values.indexOf(element.value), 1);
                    }
                    if(element.selected) {
                        count++;
                    }
                });
                if(multiSelect) {
                    component.set('v.searchStringProvider', count + ' providers selected');
                }
                component.set('v.providerValues', values)
                component.set("v.availableProviders", options);
            break;
			case 'inactiveProviderPill':
                var options = component.get("v.inactiveProviders");
                var values = component.get('v.inactiveProviderValues') || [];
                options.forEach( function(element, index) {
                    if(element.value === value) {
                        element.selected = false;
                        values.splice(values.indexOf(element.value), 1);
                    }
                    if(element.selected) {
                        count++;
                    }
                });
                if(multiSelect) {
                    component.set('v.searchStringInactiveProvider', count + ' providers selected');
                }
                component.set('v.inactiveProviderValues', values)
                component.set("v.inactiveProviders", options);
            break;

            case 'milestonePill':
                var options = component.get("v.availableMilestones");
                var values = component.get('v.milestoneValues') || [];
                options.forEach( function(element, index) {
                    if(element.value === value) {
                        element.selected = false;
                        values.splice(values.indexOf(element.value), 1);
                    }
                    if(element.selected) {
                        count++;
                    }
                });
                if(multiSelect) {
                    component.set('v.searchStringMilestone', count + ' milestones selected');
                }
                component.set('v.milestonesValues', values)
                component.set("v.availableMilestones", options);
            break;

        }

        this.execAsync(component, function() {
			let processedTData = helper.prepareProcessedTData(component);
			
			component.set(
				"v.tData",
				helper.getPage(
					1,
					component.get("v.pageSize"),
					processedTData
				)
			);
		});
    },

	filterInactiveProviderHelper : function(component) {
        
        component.set("v.message", '');

        var searchText = component.get('v.searchStringInactiveProvider');
        var options = component.get("v.inactiveProviders");
        var minChar = component.get('v.minChar');

        if(searchText.length >= minChar) {
            var flag = true;
            options.forEach( function(element,index) {
                if(element.label != undefined) {
                    if(element.label.toLowerCase().trim().startsWith(searchText.toLowerCase().trim())) {
                        element.isVisible = true;
                        flag = false;
                    } else {
                        element.isVisible = false;
                    }
                }
                
            });
            component.set("v.inactiveProviders",options);
                if(flag) {
                    component.set("v.message", "There is no results for '" + searchText + "'");
                }
        }
        $A.util.addClass(component.find('inactiveProviderDiv'),'slds-is-open');
	},

    filterProviderHelper : function(component) {
        
        component.set("v.message", '');

        var searchText = component.get('v.searchStringProvider');
        var options = component.get("v.availableProviders");
        var minChar = component.get('v.minChar');

        if(searchText.length >= minChar) {
            var flag = true;
            options.forEach( function(element,index) {
                if(element.label != undefined) {
                    if(element.label.toLowerCase().trim().startsWith(searchText.toLowerCase().trim())) {
                        element.isVisible = true;
                        flag = false;
                    } else {
                        element.isVisible = false;
                    }
                }
                
            });
            component.set("v.availableProviders",options);
                if(flag) {
                    component.set("v.message", "There is no results for '" + searchText + "'");
                }
        }
        $A.util.addClass(component.find('providerDiv'),'slds-is-open');
	},

    selectAllProvidersHelper : function(component, event, helper) {

        var options = component.get('v.availableProviders');
        var values = [];
        
        options.forEach(function(element, index) {

            if(element.selected != component.get("v.selectedAllProviders")) {

                element.selected = !element.selected;

                if(element.selected == true) {
                    values.push(element.value);
                }
            }
        });
        if(!component.get("v.selectedAllProviders")) {
            component.set("v.selectedProvidersCount", 0);
        }
        component.set("v.availableProviders", options);
        component.set("v.providerValues", values);
    },
	selectAllInactiveProvidersHelper : function(component, event, helper) {

        var options = component.get('v.inactiveProviders');
        var values = [];
        
        options.forEach(function(element, index) {

            if(element.selected != component.get("v.selectedAllInactiveProviders")) {

                element.selected = !element.selected;

                if(element.selected == true) {
                    values.push(element.value);
                }
            }
        });
        if(!component.get("v.selectedAllInactiveProviders")) {
            component.set("v.selectedInactiveProvidersCount", 0);
        }
        component.set("v.inactiveProviders", options);
        component.set("v.inactiveProviderValues", values);
    },

    selectAllMilestonesHelper : function(component, event, helper) { 
        var options = component.get('v.availableMilestones');
        var values = [];

        options.forEach(function(element, index) {

            values.push(element.value);
            element.selected = true;

        });

        component.set("v.availableMilestones", options);
        component.set("v.milestoneValues", values);
    },

	selectInactiveProviderHelper : function(component, event, helper) {

        var options = component.get('v.inactiveProviders');
        var multiSelect = component.get('v.multiSelect');
        var searchStringInactiveProvider = component.get('v.searchStringInactiveProvider');
        var values = component.get('v.inactiveProviderValues') || [];
        var value;
        var count = 0;

        options.forEach( function(element, index) {
            if(element.value === event.currentTarget.id) {
                if(multiSelect) {
                    if(values.includes(element.value)) {
                        values.splice(values.indexOf(element.value), 1);
                    } else {
                        values.push(element.value);
                    }
                    element.selected = element.selected ? false : true;   
                } else {
                    value = element.value;
                    searchStringInactiveProvider = element.label;
                }
            }
            if(element.selected) {
                count++;
            }
        });

        //Filter view with selected provider
        /*var fiteredProviders = [];
        var providers = component.get("v.rawTData");
        for(var provider of providers) {
            if(provider.Name == event.currentTarget.id) {
                filteredProviders.push(provider);
            }
        }

        component.set("v.rawTData", filteredProviders);*/


        component.set('v.inactiveProviderValue', value);
        component.set('v.inactiveProviderValues', values);
        component.set('v.inactiveProviders', options);
        component.set('v.filterButtonLabel', 'Filtrar');

        if(multiSelect) {
            component.set('v.searchStringInactiveProvider', count + ' providers selected');
            component.set("v.selectedInactiveProvidersCount", count);
        }else{
            component.set('v.searchStringInactiveProvider', searchStringInactiveProvider);
        }
          
        $A.util.removeClass(component.find('inactiveProviderDiv'),'slds-is-open');
    },

    selectProviderHelper : function(component, event, helper) {

        var options = component.get('v.availableProviders');
        var multiSelect = component.get('v.multiSelect');
        var searchStringProvider = component.get('v.searchStringProvider');
        var values = component.get('v.providerValues') || [];
        var value;
        var count = 0;

        options.forEach( function(element, index) {
            if(element.value === event.currentTarget.id) {
                if(multiSelect) {
                    if(values.includes(element.value)) {
                        values.splice(values.indexOf(element.value), 1);
                    } else {
                        values.push(element.value);
                    }
                    element.selected = element.selected ? false : true;   
                } else {
                    value = element.value;
                    searchStringProvider = element.label;
                }
            }
            if(element.selected) {
                count++;
            }
        });

        //Filter view with selected provider
        /*var fiteredProviders = [];
        var providers = component.get("v.rawTData");
        for(var provider of providers) {
            if(provider.Name == event.currentTarget.id) {
                filteredProviders.push(provider);
            }
        }

        component.set("v.rawTData", filteredProviders);*/


        component.set('v.providerValue', value);
        component.set('v.providerValues', values);
        component.set('v.availableProviders', options);
        component.set('v.filterButtonLabel', 'Filtrar');

        if(multiSelect) {
            component.set('v.searchStringProvider', count + ' providers selected');
            component.set("v.selectedProvidersCount", count);
        }else{
            component.set('v.searchStringProvider', searchStringProvider);
        }
          
        $A.util.removeClass(component.find('providerDiv'),'slds-is-open');
    },
    filterMilestoneHelper : function(component) {
        
        component.set("v.message", '');

        var searchText = component.get('v.searchStringMilestone');
        var options = component.get("v.availableMilestones");
        var minChar = component.get('v.minChar');

        if(searchText.length >= minChar) {
            var flag = true;
            options.forEach( function(element,index) {
                if(element.label.toLowerCase().trim().startsWith(searchText.toLowerCase().trim())) {
                    element.isVisible = true;
                    flag = false;
                } else {
                    element.isVisible = false;
                }
            });
            component.set("v.availableMilestones",options);
                if(flag) {
                    component.set("v.message", "There is no results for '" + searchText + "'");
                }
        }
        $A.util.addClass(component.find('milestoneDiv'),'slds-is-open');
	},

    selectMilestoneHelper : function(component, event, helper) {
        
        var options = component.get('v.availableMilestones');
        var multiSelect = component.get('v.multiSelect');
        var searchStringMilestone = component.get('v.searchStringMilestone');
        var values = component.get('v.milestoneValues') || [];
        var value;
        var count = 0;

        options.forEach( function(element, index) {
            if(element.value === event.currentTarget.id) {
                if(multiSelect) {
                    if(values.includes(element.value)) {
                        values.splice(values.indexOf(element.value), 1);
                    } else {
                        values.push(element.value);
                    }
                    element.selected = element.selected ? false : true;   
                } else {
                    value = element.value;
                    searchStringMilestone = element.label;
                }
            }
            if(element.selected) {
                count++;
            }
        });

        component.set('v.milestoneValue', value);
        component.set('v.milestoneValues', values);
        component.set('v.availableMilestones', options);
        component.set('v.filterButtonLabel', 'Filtrar');

        if(multiSelect) {
            component.set('v.searchStringMilestone', count + ' milestones selected');
        }else{
            component.set('v.searchStringMilestone', searchStringMilestone);
        }
          
        $A.util.removeClass(component.find('milestoneDiv'),'slds-is-open');

        //Filter view for selected milestones
        this.execAsync(component, function() {
			let processedTData = helper.prepareProcessedTData(component);

			component.set(
				"v.tData",
				helper.getPage(
					1,
					component.get("v.pageSize"),
					processedTData
				)
			);

		});
    },

    processCommission : function(component, helper){

        let milestoneWrapper = component.get('v.tData');
        let selectedCommissions = [];
		for(let i = 0; i < milestoneWrapper.length; i++){
			for(let j = 0; j < milestoneWrapper[i].data.length; j++){
				for(let k = 0; k < milestoneWrapper[i].data[j].CommissionsList.length; k++) {
					if(document.getElementById('checkbox-0'+i+j+k).checked){
                        selectedCommissions.push(milestoneWrapper[i].data[j].CommissionsList[k].Id);
                    }
				}
				
			}
		}
        if(selectedCommissions.length < 1){
            this.fireToast("Error","Please select a commission to process first.","error");
        } else {
            var action = component.get("c.processMilestones");
            action.setParams({
                commissions:selectedCommissions
            });

            action.setCallback(this, function(response) {
                var result  = response.getReturnValue();
                var state = response.getState();

                if(state === "SUCCESS") {

                    if(result.message == 'OK' && $A.util.isEmpty(result.Commissions)) {
                        this.fireToast("Success","Commission/s processed sucessfully.","success");
                    } else if(result.message == 'OK' && !$A.util.isEmpty(result.Commissions)){
                        $A.createComponent(
                            "c:CommissionTrackerWarningModal", {
                                commissions: result.Commissions,
                                details: 'The operation was successful, but the following commissions couldn\'t be updated either because they are already processed or finance tool and initial payment doesn\'t meet the criteria:'
                            },
                            function(content, status) {
                                if (status === "SUCCESS") {
                                    let modalBody = content;
                                    component.find('overlayLib').showCustomModal({
                                        header: "The operation was successful, but...",
                                        body: modalBody,
                                        showCloseButton: true,
                                        cssClass: "mymodal",
                                        closeCallback: function() {
                                            //Clear the selection at a later time because otherwise the radio option is not cleared.
                                            
                                        }
                                    });
                                }
                            }
                        );
                    } else {
                        this.fireToast("Error",result.message,"error", 10000);
                    }
                    
                } else if (state === 'ERROR') {
                    this.fireToast("Error",error.getMessage(),"error");
                }
            });
            
            $A.enqueueAction(action);
        }
    },

    addPaidDateHelper : function(component, selectedCommissions, selectedDate) {
        let selectedCommissionsIds = [];
            for(var commission of selectedCommissions) {
                
                    selectedCommissionsIds.push(commission.Id);
                }
        if(selectedCommissionsIds.length < 1){

            this.fireToast("Error","Please select a commission first.","error");

        } else {
            var action = component.get("c.addPaidDateToCommissions");

            action.setParams({
                commissions : selectedCommissionsIds,
                selectedDate: selectedDate
            })

            action.setCallback(this, function(response) {
                var result = response.getReturnValue();
                var state = response.getState();

                if(state === "SUCCESS") {
                    if(result.message == 'OK' && $A.util.isEmpty(result.Commissions)) {
                        this.fireToast("Success","Commission's paid date updated successfully.","success");
                    } else if(result.message == 'OK' && !$A.util.isEmpty(result.Commissions)){
                        $A.createComponent(
                            "c:CommissionTrackerWarningModal", {
                                commissions: result.Commissions,
                                details: 'The operation was successful, but the following commissions couldn\'t be updated, either because there are already a paid date assigned for their current milestone or need to be processed first:'
                            },
                            function(content, status) {
                                if (status === "SUCCESS") {
                                    let modalBody = content;
                                    component.find('overlayLib').showCustomModal({
                                        header: "The operation was successful, but...",
                                        body: modalBody,
                                        showCloseButton: true,
                                        cssClass: "mymodal",
                                        closeCallback: function() {
                                            //Clear the selection at a later time because otherwise the radio option is not cleared.
                                            
                                        }
                                    });
                                }
                            }
                        );
                    } else {
                        this.fireToast("Error",result.message,"error");
                    }
                    
                } else if (state === 'ERROR') {
                    this.fireToast("Error",error.getMessage(),"error");
                }
            });
            $A.enqueueAction(action);
        }
    },

    changePageHelper : function (component, event, helper) {

        var elem = event.target;
        var pageNum = Number(elem.value);

        this.execAsync(component, function() {
			let processedTData = helper.prepareProcessedTData(component);
			component.set("v.currentPage", pageNum);
			component.set(
				"v.tData",
				helper.getPage(
					pageNum,
					component.get("v.pageSize"),
					processedTData
				)
			);
		});
        component.set("v.currentPage", pageNum);
    },

    sendEmailReportHelper : function (component, event, helper) {
        const selectedProviders = component.get("v.providerValues");
        const selectedMilestones = component.get("v.milestoneValues");
        const allProviders = component.get("v.availableProviders");
        var fromDate = component.get("v.dateFrom");
        var toDate = component.get("v.dateTo");

        var display = component.find("display").get("v.value");
        if(display == 'To Be Processed') {
            this.fireToast("Error","Commission to be processed can't be Emailed","error")
        } else {
            const dataCommissions = component.get("v.rawTData");
        $A.createComponent(
            "c:CommissionTrackerEmailReport", {
                commissionsList: dataCommissions,
                availableProviders: allProviders,
                selectedMilestones: selectedMilestones,
                fromDate : fromDate,
                toDate : toDate
            },
            function(content, status) {
                if (status === "SUCCESS") {
                    let modalBody = content;
                    component.find('overlayLib').showCustomModal({
                        header: "Mail Report to CP",
                        body: modalBody,
                        showCloseButton: true,
                        cssClass: "mymodal slds-modal_large",
                        closeCallback: function() {
                            //Clear the selection at a later time because otherwise the radio option is not cleared.
                        }
                    });
                }
            }
        );
        }
    },

    searchHelper : function(component, event, helper) {

        var allValidationsPass = true;

		var dateFrom = component.find("dateFrom");
		var dateFromValue = dateFrom.get("v.value");

		if(dateFromValue == null) {
			dateFrom.setCustomValidity("Please select a date first");
			allValidationsPass = false;
		} else {
			dateFrom.setCustomValidity("");
		}
		dateFrom.reportValidity();

		var dateTo = component.find("dateTo");
		var dateToValue = dateTo.get("v.value");

		if(dateToValue == null) {
			dateTo.setCustomValidity("Please select a date first");
			allValidationsPass = false;
		} else {
			dateTo.setCustomValidity("");
		}
		dateTo.reportValidity();

		var providerSelector = component.find("inputLookup1");
		var providerSelectorValue = component.get("v.providerValues");
		var allProvidersSelected = component.get("v.selectedAllProviders");

		if($A.util.isEmpty(providerSelectorValue) && !allProvidersSelected) {

			providerSelector[0].setCustomValidity("Please select at least one provider");
			allValidationsPass = false;
		} else {
			providerSelector[0].setCustomValidity("");
		}
		providerSelector[0].reportValidity();

		var milestoneSelector = component.find("inputLookup1");
		var milestoneValues = component.get("v.milestoneValues");

		if($A.util.isEmpty(milestoneValues)) {

			milestoneSelector[1].setCustomValidity("Please select at least one milestone");
			allValidationsPass = false;
			
		} else {
			milestoneSelector[1].setCustomValidity("");
		}
		milestoneSelector[1].reportValidity();

		if(allValidationsPass) {
			component.set("v.isSearched", true);
			
			var mode = component.get("v.display");
			component.set("v.selectedMode",mode);
			helper.fetchData(component);
		}
    },

    fireToast : function(title, message, type, duration){
        let toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": title,
            "message": message,
            "type": type,
            "duration": duration
        });
        toastEvent.fire();
    }
})