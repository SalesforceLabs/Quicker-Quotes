global with sharing class QQ_CreateQuotePdf {

    @InvocableMethod(label='Create PDF' description='Creates a Quote PDF document using the provided template' )
    global static void createPdf(List<RequestInput> inputs) {
        callFutureMethod(inputs[0].quoteId, inputs[0].templateId);        
    }
    
    @future(callout=true)
    public static void callFutureMethod (Id quoteId, Id templateId) {
        
		String quoteUrl = '/quote/quoteTemplateDataViewer.apexp?';

        quoteUrl += 'id=' + quoteId;
        quoteUrl += '&headerHeight=197&footerHeight=10';
        quoteUrl += '&summlid=' + templateId;

        PageReference pageRef = new PageReference(quoteUrl);
        
        QuoteDocument quoteDoc = new QuoteDocument();
        if(Test.isRunningTest()) {
            quoteDoc.Document = Blob.valueOf('Generate PDF');
        } else {
	        quoteDoc.Document = pageRef.getContentAsPDF();        
        }
        quoteDoc.QuoteId = quoteId;

        if(QuoteDocument.sObjectType.getDescribe().isCreateable()) insert(quoteDoc);

	}

    global class RequestInput {
        @InvocableVariable(label='Quote Id' required=true) global Id quoteId;
        @InvocableVariable(label='Quote Template Id' required=true) global Id templateId;
    }
    
}