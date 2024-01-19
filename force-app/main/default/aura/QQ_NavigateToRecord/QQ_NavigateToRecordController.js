({
	invoke : function(component, event, helper) {

        var navService = component.find('navService');
        var destinationRecordId = component.get('v.destinationRecordId');
        var destinationObjectType = component.get('v.destinationObjectType');
        var destinationAction = component.get('v.destinationAction');
        
        var pageReference = 
            {
                type: '',
                attributes: {
                    objectApiName: '',
                    actionName: ''
                },
                state: {
                    filterName: ''
                }
            }
        
        var validActionValues = ['clone','edit','view'];
        
        if(destinationRecordId && validActionValues.includes(destinationAction.toLowerCase())) {
            pageReference.type = 'standard__recordPage';
            pageReference.attributes.recordId = destinationRecordId;
            pageReference.attributes.objectApiName = destinationObjectType;
            pageReference.attributes.actionName = destinationAction.toLowerCase();
        } else {
            throw new Error('Error due to either 1) Missing RecordId. Since you have DestinationType set to record, you need to pass in a RecordId. If you want to create a new record, use a DestinationType of object instead and a DestinationAction of new or 2) You need to provide a Destination Action of edit, view or clone');
        }
        navService.navigate(pageReference); 
        
	}
})