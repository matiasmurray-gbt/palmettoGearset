({
    doInit : function(component, event, helper) {
        
    },

    openModal: function(component, event, helper) {
        var display = component.get("v.display");
        if(display == 'To Be Processed') {
            this.fireToast("Error","Commission to be processed can't be Emailed","error")
        } else {
            component.set("v.isOpen", true);
            
            helper.fetchData(component, event, helper);
        }
    },

    updateSelectedText: function (component, event) {
        var selectedRows = event.getParam('selectedRows');
        component.set('v.selectedRowsCount', selectedRows.length);
    },

    updateSelectedTextSecondTable: function (component, event) {
        var selectedRows = event.getParam('selectedRows');
        component.set('v.selectedRowsCountTwo', selectedRows.length);
    },

    handleCloseModal : function (component) {
        component.find("overlayLib").notifyClose();
    },

    handleSendEmail : function(component, event, helper) {
        helper.sendEmailHelper(component, event, helper);
    },

    closeModal: function(component) {
        component.set("v.isOpen", false);
    },

    handleApplicationEvent : function(component, event, helper) {
        var message = event.getParam("message");
        var operation = event.getParam("operation");
        if(message == 'Ok' && operation == 'send email') {
            helper.sendEmailHelper(component, event, helper);
        } else if(message == 'Cancel') {
            component.find("overlayLib").notifyClose();
        }
    },

    handleShowConfirmationModal : function(component) {
        $A.createComponent("c:CommissionTrackerConfirmOperationModal", {
            "operation" : "send email"
        }, function(content, status) {
                if (status === "SUCCESS") {
                    var modalBody = content;
                    component.find('overlayLib').showCustomModal({
                        header: "Are you sure you want to send the email/s?",
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
})