({
    removePillHelper : function(component, event, helper) {
        var value = event.getSource().get('v.name');
        var count = 0;

        var options = component.get("v.providers");
        var values = component.get('v.selectedProviders') || [];
        options.forEach( function(element, index) {
            if(element.value === value) {
                element.selected = false;
                values.splice(values.indexOf(element.value), 1);
            }
            if(element.selected) {
                count++;
            }
        });
        component.set('v.picklistLabel', count + ' providers selected');
        component.set('v.selectedProviders', values)
        component.set("v.providers", options);
    }
})