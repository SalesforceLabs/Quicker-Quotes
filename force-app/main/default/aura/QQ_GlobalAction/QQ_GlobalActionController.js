({
	init : function(component, event, helper) {
        
        const namespace = component.getConcreteComponent().getDef().getDescriptor().getNamespace();
        const pageApiName = (namespace=='c') ? 'QQ_New_Quote' : namespace+'__QQ_New_Quote';

        var navService = component.find('navService');
        var pageReference = {
            type: 'standard__navItemPage',
            attributes: {
                apiName: pageApiName
            }
        }
        navService.navigate(pageReference);
    },
    
})