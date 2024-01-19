public with sharing class QQ_UpsertAndDeleteQuoteLineItems {

    @InvocableMethod(label='Upsert Quote Line Items' description='Upserts quote line items after an update to the BOM' )
    public static void upsertQuoteLineItems(List<RequestInput> inputs) {
        RequestInput ri = inputs[0];
        try {
            if(ri.lineItems.size() > 0) {
                upsert ri.lineItems;
            }
            if(ri.deletedLineItems.size() > 0) {
                if(QuoteLineItem.sObjectType.getDescribe().isDeletable()) {
                    delete ri.deletedLineItems;
                }
            }
        } catch(Exception e) {
            System.debug(e.getMessage());
        }
    }
    
    public class RequestInput {
        @InvocableVariable(label='Quote Line Items' required=true) public List<QuoteLineItem> lineItems;
        @InvocableVariable(label='Deleted Line Items' required=true) public List<QuoteLineItem> deletedLineItems;
    }
}