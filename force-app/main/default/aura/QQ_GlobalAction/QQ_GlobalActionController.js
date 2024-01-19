({
	init : function(component, event, helper) {
        var navService = component.find('navService');
        var pageReference = {
            type: 'standard__navItemPage',
            attributes: {
                apiName: 'QQ_New_Quote'
            }
        }
        navService.navigate(pageReference);
    },
    
})