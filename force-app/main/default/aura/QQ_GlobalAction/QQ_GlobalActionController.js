({
	init : function(component, event, helper) {
        var navService = component.find('navService');
        var pageReference = {
            type: 'standard__navItemPage',
            attributes: {
                apiName: 'quickerquotes__QQ_New_Quote'
            }
        }
        navService.navigate(pageReference);
    },
    
})