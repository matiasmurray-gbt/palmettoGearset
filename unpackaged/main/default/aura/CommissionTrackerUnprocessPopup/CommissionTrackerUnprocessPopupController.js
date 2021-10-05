({
    doInit : function(component, event, helper) {
    },

    openUnprocess : function(component, event, helper){
		
        if($A.util.isEmpty(component.get("v.tableSelectedRows"))) {
            helper.fireToast("Error", "Please select at least one commission", "error");
        } else {
            helper.getTableData(component,helper);
            component.set("v.isOpen", true);
        }
    },

    closePopUp : function(component, event, helper){
        component.set("v.isOpen", false);
    },

    handleShowModal: function(component) {
        $A.createComponent("c:CommissionTrackerConfirmOperationModal", {
            "operation" : "normal unprocess"
        },
                           function(content, status) {
                               if (status === "SUCCESS") {
                                   var modalBody = content;
                                   component.find('overlayLib').showCustomModal({
                                       header: "Are you sure you want to unprocess the selected commissions?",
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
        
        if(message == 'Ok' && operation == 'normal unprocess') {
        // if the user clicked the OK button do your further Action here
            helper.unprocessCommission(component,helper);
        } else if(message == 'Cancel') { 
        // if the user clicked the Cancel button do your further Action here for canceling
            component.find("overlayLib").notifyClose();
        }
    },

    doUnprocess : function(component, event, helper){
        
        helper.unprocessCommission(component,helper);
    },

    updateSelectedText : function (component, event, helper) {
        var selectedRows = event.getParam('selectedRows');
        component.set('v.selectedRowsCount', selectedRows.length);
    },

    handleSelectAll: function(component, event, helper){
        let selectAllValue = document.getElementById('checkbox-up-select-all').checked;
        let commission = component.get('v.negativeCommisions');
        for(let i = 0; i < commission.length; i++){
            document.getElementById('checkbox-up-0'+i).checked = selectAllValue;
        }
    },

    handleSelectRow : function (component, event, helper){
        let commission = component.get('v.negativeCommisions');
        if(commission.length > 0){
            let selectAllValue = commission.reduce(function(acc,cur,idx){
                if(acc && document.getElementById('checkbox-up-0'+idx).checked){
                    return true;
                }
                return false;
            },true);

            document.getElementById('checkbox-up-select-all').checked = selectAllValue;
        }
    }
})