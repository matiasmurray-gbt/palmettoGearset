({
    removePill : function( component, event, helper ){
		helper.removePillHelper(component, event, helper);
	},

    openUnprocess : function(component, event, helper){
        component.set("v.isOpen", true);
    },

    closePopUp : function(component, event, helper){
        component.set("v.isOpen", false);
    }
})