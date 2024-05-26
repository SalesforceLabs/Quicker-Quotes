({
    afterRender : function(component, helper) {
        this.superAfterRender();
        $A.get("e.force:closeQuickAction").fire();
    }
})