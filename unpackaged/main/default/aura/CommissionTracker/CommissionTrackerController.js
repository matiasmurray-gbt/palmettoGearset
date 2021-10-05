({
    doInit : function(component, event, helper) {
        helper.fetchData(component);
    },

    handleSort : function (component, event, helper) {
		helper.execAsync(component, function() {
			let sortBy = event.getParam("fieldName");
			let sortDirection = event.getParam("sortDirection");
			let processedTData = component.get("v.processedTData");
			const pageSize = component.get("v.pageSize");
			
			processedTData = helper.sortData(processedTData, sortBy, sortDirection);
			
			component.set("v.tableSortedBy", sortBy);
			component.set("v.tableSortedDirection", sortDirection);
			component.set("v.processedTData", processedTData);
			component.set(
				"v.tData",
				helper.getPage(
					component.get("v.currentPage"),
					component.get("v.pageSize"),
					processedTData
				)
			);
			//var calculatedSize = (processedTData.length / pageSize); Replaced for providersLength
			var calculatedSize = (component.get("v.providersLength") / pageSize);
			component.set("v.calculatedSize", Math.round(calculatedSize));
			component.set("v.isLoading", false);
		});
	},

	handleFilterChange : function (component, event, helper) {
		component.set("v.filterState", true);
		helper.execAsync(component, function() {
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

	handleFilterClick : function (component, event, helper) {
		helper.execAsync(component, function() {
			let filterState = !component.get("v.filterState");
			
			if(!filterState) {
				//Clear filters
				component.set("v.dateFrom", "");
				component.set("v.dateTo", "");
				
				let processedTData = helper.prepareProcessedTData(component);
				component.set(
					"v.tData",
					helper.getPage(
						1,
						component.get("v.pageSize"),
						processedTData
					)
				);
			}
			
			component.set("v.filterState", filterState);
			component.set("v.isLoading", false);
		});
	},

    handleClickNextPage : function(component, event, helper) {
		helper.execAsync(component, function() {
			let page = component.get("v.currentPage") + 1;
			let pageSize = component.get("v.pageSize");
			let processedTData = component.get("v.processedTData");
			let providersLength = component.get("v.providersLength");
			//Replaced processedTData.length for providersLength
			if(page < (providersLength / pageSize) + 1) {
				component.set("v.tData",
					helper.getPage(
						page,
						pageSize,
						processedTData
					)
				);
				component.set("v.currentPage", page);
			}
		});
	},
	
	handleClickPrevPage : function(component, event, helper) {
		helper.execAsync(component, function() {
			let page = component.get("v.currentPage") - 1;
			if(page > 0) {
				component.set("v.tData",
					helper.getPage(
						page,
						component.get("v.pageSize"),
						component.get("v.processedTData")
					)
				);
				component.set("v.currentPage", page);
			}
		});
	},
    //Here starts the logic for multiselect picklist (3rdPartyPartners and Milestones)

    // To remove the selected item.
	removePill : function( component, event, helper ){
		helper.removePillHelper(component, event, helper);

		helper.execAsync(component, function() {
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
    // To close the dropdown if clicked outside the dropdown.
	blurEvent : function( component, event, helper ){
		helper.blurEventHelper(component, event);
	},
    showProviders : function( component, event, helper ) {
		var disabled = component.get("v.disabled");
		if(!disabled) {
			component.set("v.message", '');
			component.set('v.searchStringProvider', '');
			var providers = component.get("v.availableProviders");
			providers.forEach( function(element,index) {
				element.isVisible = true;
			});
			component.set("v.availableProviders", providers);
			if(!$A.util.isEmpty(component.get('v.availableProviders'))) {
				$A.util.addClass(component.find('providerDiv'),'slds-is-open');
			} 
		}
	},
    // When a keyword is entered in search box
	filterProvider : function( component, event, helper ) {;
		if( !$A.util.isEmpty(component.get('v.searchStringProvider')) ) {
			helper.filterProviderHelper(component);
		} else {
			$A.util.removeClass(component.find('providerDiv'),'slds-is-open');
		}
	},

    // When an item is selected
	selectProvider : function( component, event, helper ) {
        var selectedProvider = event.currentTarget.id;
        component.set("v.selectedProvider", selectedProvider);
		if(!$A.util.isEmpty(event.currentTarget.id)) {
			helper.selectProviderHelper(component, event, helper);
			component.set("v.filterState", true);
		}

        helper.execAsync(component, function() {
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

	filterCommissions : function( component, event, helper ) {
		component.set("v.filterState", true);
        var commissionsFilter = component.get("v.commissionsFilter");

        helper.execAsync(component, function() {
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

	selectAllProviders : function(component, event, helper) {
		component.set("v.selectedAllProviders", !component.get("v.selectedAllProviders"));
		helper.selectAllProvidersHelper(component, event, helper);

		helper.execAsync(component, function() {
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
	selectedAllInactiveProviders : function(component, event, helper) {
		component.set("v.selectedAllInactiveProviders", !component.get("v.selectedAllInactiveProviders"));
		helper.selectAllInactiveProvidersHelper(component, event, helper);

		helper.execAsync(component, function() {
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

    showMilestones : function( component, event, helper ) {
		var disabled = component.get("v.disabled");
		if(!disabled) {
			component.set("v.message", '');
			component.set('v.searchStringMilestone', '');
			var milestones = component.get("v.availableMilestones");
			milestones.forEach( function(element,index) {
				element.isVisible = true;
			});
			component.set("v.availableMilestones", milestones);
			if(!$A.util.isEmpty(component.get('v.availableMilestones'))) {
				$A.util.addClass(component.find('milestoneDiv'),'slds-is-open');
			} 
		}
	},
    // When a keyword is entered in search box
	filterMilestone : function( component, event, helper ) {
		if( !$A.util.isEmpty(component.get('v.searchStringMilestone')) ) {
			helper.filterMilestoneHelper(component);
		} else {
			$A.util.removeClass(component.find('milestoneDiv'),'slds-is-open');
		}
	},

    // When an item is selected
	selectMilestone : function( component, event, helper ) {
		if(!$A.util.isEmpty(event.currentTarget.id)) {
			component.set("v.filterState", true);
			helper.selectMilestoneHelper(component, event, helper);
		}
	},

    handleOnSearch : function(component, event, helper) {

		helper.searchHelper(component, event, helper);
        
    },

    handleDisplay : function(component, event, helper) {

        var mode = component.find("display").get("v.value");

        if(mode == 'Processed Commission') {
            component.set("v.showPaidMilestones", true);
        } else {
            component.set("v.showPaidMilestones", false);
        }
    },

	allSelected : function(component, event){ 

		let selectAllValue = document.getElementById('checkbox-unique-id-297').checked;
		let selectedCommissions = [];
		let milestoneWrapper = component.get('v.tData');
		for(let i = 0; i < milestoneWrapper.length; i++){
			for(let j = 0; j < milestoneWrapper[i].data.length; j++){
				for(let k = 0; k < milestoneWrapper[i].data[j].CommissionsList.length; k++) {
					document.getElementById('checkbox-0'+i+j+k).checked = selectAllValue;
					if(document.getElementById('checkbox-0'+i+j+k).checked) {
						selectedCommissions.push(milestoneWrapper[i].data[j].CommissionsList[k]);
					}
				}
				
			}
		}
		if(!document.getElementById('checkbox-unique-id-297').checked) {
			selectedCommissions = [];
		}
		component.set('v.selectedRows', selectedCommissions);
	},

	handleProcess: function(component) {
        $A.createComponent("c:CommissionTrackerConfirmOperationModal", {
			"operation" : "process"
		}, function(content, status) {
			if (status === "SUCCESS") {
				var modalBody = content;
				component.find('overlayLib').showCustomModal({
					header: "Are you sure you want to process the selected commissions?",
					body: modalBody, 
					showCloseButton: false,
					closeCallback: function(ovl) {
						console.log('Overlay is closing');
					}
				}).then(function(overlay){
					console.log("Overlay is made");
				});
			}
		});
    },
    
    handleApplicationEvent : function(component, event, helper) {
        var message = event.getParam("message");
		var operation = event.getParam("operation");
		var selectedDate = event.getParam("selectedDate");
        
        if(message == 'Ok' && operation == 'process' ) {
        // if the user clicked the OK button do your further Action here
			helper.processCommission(component, event, helper);
        } else if(message == 'Ok' && operation == 'add paid date') {
			let selectedCommissions = [];
			selectedCommissions = component.get("v.selectedRows");
			helper.addPaidDateHelper(component, selectedCommissions, selectedDate);

		} else if(message == 'Cancel') { 
        // if the user clicked the Cancel button do your further Action here for canceling
            component.find("overlayLib").notifyClose();
        }
    },

	handleCheckedRow : function (component, event) {

		let milestoneWrapper = component.get('v.tData');
        let selectedCommissions = [];
		for(let i = 0; i < milestoneWrapper.length; i++){
			for(let j = 0; j < milestoneWrapper[i].data.length; j++){
				for(let k = 0; k < milestoneWrapper[i].data[j].CommissionsList.length; k++) {
					if(document.getElementById('checkbox-0'+i+j+k).checked){
                        selectedCommissions.push(milestoneWrapper[i].data[j].CommissionsList[k]);
						component.set('v.selectedRows', selectedCommissions);
                    }
				}
				
			}
		}
	},

	handleAddPaidDate : function (component, event, helper) {
		var selectedRows = JSON.parse(JSON.stringify(component.get("v.selectedRows")));
		if($A.util.isEmpty(selectedRows)){
			helper.fireToast('Error', 'Please, select a commission first', 'error');
		} else {
			$A.createComponent("c:CommissionTrackerConfirmOperationModal", {
				"operation" : "add paid date"
			}, function(content, status) {
				if (status === "SUCCESS") {
					var modalBody = content;
					component.find('overlayLib').showCustomModal({
						header: "Add paid date to the current selected?",
						body: modalBody, 
						showCloseButton: false,
						closeCallback: function(ovl) {
							console.log('Overlay is closing');
						}
					}).then(function(overlay){
						console.log("Overlay is made");
					});
				}
			});
		}
	},

	handleShowM1 : function (component) {
		var buttonState = component.get("v.showM1");
		component.set("v.showM1", !buttonState);
	},

	handleShowM2 : function (component) {
		var buttonState = component.get("v.showM2");
		component.set("v.showM2", !buttonState);
	},

	handleShowM3 : function (component) {
		var buttonState = component.get("v.showM3");
		component.set("v.showM3", !buttonState);
	},

	handleShowClawback : function (component) {
		var buttonState = component.get("v.showClawback");
		component.set("v.showClawback", !buttonState);
	},

	handleChangePage : function(component, event, helper) {
		helper.changePageHelper(component, event, helper);
	},

	handleSendEmailReport : function (component, event, helper) {
		helper.sendEmailReportHelper(component, event, helper);
        
    },
	showInactiveProviders : function( component, event, helper ) {
		var disabled = component.get("v.disabled");
		if(!disabled) {
			component.set("v.message", '');
			component.set('v.searchStringInactiveProvider', '');
			var providers = component.get("v.inactiveProviders");
			providers.forEach( function(element,index) {
				element.isVisible = true;
			});
			component.set("v.inactiveProviders", providers);
			if(!$A.util.isEmpty(component.get('v.inactiveProviders'))) {
				$A.util.addClass(component.find('inactiveProviderDiv'),'slds-is-open');
			} 
		}
	},
	filterInactiveProvider : function( component, event, helper ) {;
		if( !$A.util.isEmpty(component.get('v.searchStringInactiveProvider')) ) {
			helper.filterInactiveProviderHelper(component);
		} else {
			$A.util.removeClass(component.find('inactiveProviderDiv'),'slds-is-open');
		}
	},

	selectInactiveProvider : function( component, event, helper ) {
        var selectedInactiveProvider = event.currentTarget.id;
        component.set("v.selectedInactiveProvider", selectedInactiveProvider);
		if(!$A.util.isEmpty(event.currentTarget.id)) {
			helper.selectInactiveProviderHelper(component, event, helper);
			component.set("v.filterState", true);
		}

        helper.execAsync(component, function() {
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
	}
})