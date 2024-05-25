global with sharing class QQ_UpsertAndDeleteQuoteLineItems {

    @InvocableMethod(label='Upsert Quote Line Items' description='Upserts quote line items after an update to the BOM' )
    global static void upsertQuoteLineItems(List<RequestInput> inputs) {
        RequestInput ri = inputs[0];
        List<QuoteLineItem> lineItems = ri.lineItems;
        List<QuoteLineItem> deletedLineItems = ri.deletedLineItems;
        if(lineItems.size() > 0) {
            if (Schema.SObjectType.QuoteLineItem.isCreateable() == false || Schema.SObjectType.QuoteLineItem.isUpdateable() == false) {
                throw new DmlException('User does not have access to upsert Quote Line Items');
            }

            try {
                if(Schema.sObjectType.QuoteLineItem.fields.Product2Id.isCreateable() &&
                Schema.sObjectType.QuoteLineItem.fields.Quantity.isCreateable() &&
                Schema.sObjectType.QuoteLineItem.fields.UnitPrice.isCreateable() &&
                Schema.sObjectType.QuoteLineItem.fields.Discount.isCreateable() &&
                Schema.sObjectType.QuoteLineItem.fields.Quantity.isUpdateable() &&
                Schema.sObjectType.QuoteLineItem.fields.UnitPrice.isUpdateable() &&
                Schema.sObjectType.QuoteLineItem.fields.Discount.isUpdateable()) {
                    upsert lineItems;
                }
            } catch(Exception e) {
                System.debug(e.getMessage());
            }
        }
        if(deletedLineItems.size() > 0) {
            try {
                if (QuoteLineItem.SObjectType.getDescribe().isDeletable() ) {
                    delete deletedLineItems;
                }
            } catch(Exception e) {
                System.debug(e.getMessage());
            }
        }
    }
    
    global class RequestInput {
        @InvocableVariable(label='Quote Line Items' required=true) global List<QuoteLineItem> lineItems;
        @InvocableVariable(label='Deleted Line Items' required=true) global List<QuoteLineItem> deletedLineItems;
    }
}