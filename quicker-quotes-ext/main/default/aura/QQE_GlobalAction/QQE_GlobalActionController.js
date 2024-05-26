({
	init : function(component, event, helper) {
        
        const namespace = component.getConcreteComponent().getDef().getDescriptor().getNamespace();
        const pageApiName = (namespace=='c') ? 'QQE_New_Quote' : namespace+'__QQE_New_Quote';

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