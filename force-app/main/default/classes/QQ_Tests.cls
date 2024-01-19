@isTest
private class QQ_Tests {

    @testSetup static void setupTestData() {
        String[] productCodes = new String[]{'TEST1', 'TEST2', 'TEST3'};
        String[] productNames = new String[]{'Alpha Product', 'Beta Product', 'Charlie Product'};
        Decimal[] productUnitPrices = new Decimal[]{10.50, 13.15, 103.00};
        
        List<Product2> prods = new List<Product2>();
        for(Integer i=0; i<productCodes.size(); i++) {
            prods.add(new Product2( ProductCode=productCodes[i], Name=productNames[i], IsActive=TRUE ));
        }
        insert(prods);
        Id standardPricebookId = Test.getStandardPricebookId();
        
        List<PricebookEntry> standardPrices = new List<PricebookEntry>();
        for(Integer i=0; i<prods.size(); i++) {
            standardPrices.add(new PricebookEntry( Pricebook2Id=standardPriceBookId, Product2Id=prods[i].Id, UnitPrice=productUnitPrices[i], IsActive=TRUE ));
        }
		insert(standardPrices);
        
        Pricebook2 pb = new Pricebook2( Name='Test Price Book', IsActive=TRUE);
        insert(pb);
        
        List<PricebookEntry> testPrices = new List<PricebookEntry>();
        for(Integer i=0; i<prods.size(); i++) {
            testPrices.add(new PricebookEntry( Pricebook2Id=pb.Id, Product2Id=prods[i].Id, UnitPrice=productUnitPrices[i], UseStandardPrice=TRUE, IsActive=TRUE ));
        }
		insert(testPrices);
        
        Account testAccount = new Account( Name='Test Account' );
        insert testAccount;
        
        Contact testContact = new Contact( AccountId=testAccount.Id, FirstName='Test', LastName='Contact', Phone='0411123123', Email='test@example.com' );
        insert testContact;
        
        Schema.picklistEntry opptyStage = Opportunity.stagename.getDescribe().getPicklistValues()[0];
        Opportunity testOpportunity = new Opportunity( AccountId=testAccount.Id, Name='Test Opportunity', StageName=opptyStage.getValue(), Pricebook2Id=pb.Id, CloseDate=Date.Today() );
        insert testOpportunity;
        
        Quote testQuote = new Quote( OpportunityId=testOpportunity.Id, Name='Test Quote', Pricebook2Id=pb.Id, ContactId=testContact.Id );
        insert testQuote;
        
        List<QuoteLineItem> lines = new List<QuoteLineItem>();
        for(Integer i=0; i<testPrices.size(); i++) {
            lines.add(new QuoteLineItem( QuoteId=testQuote.Id, PricebookEntryId=testPrices[i].Id, UnitPrice=productUnitPrices[i], Quantity=i+1, Discount=i*10));
        }
        insert(lines);
        
    }
    
    @isTest static void testPricebookSearch() {
        Pricebook2 pb = [SELECT Id FROM Pricebook2 WHERE Name='Test Price Book' LIMIT 1];
        Test.startTest();
        QQ_SearchPricebookEntries.Response getResultsResponse = QQ_SearchPricebookEntries.getResults('test', pb.Id, null);
        QQ_SearchPricebookEntries.Response getPBEntriesResponse1 = QQ_SearchPricebookEntries.getPricebookEntries('alpha', pb.Id, 0, 50, null);
        QQ_SearchPricebookEntries.Response getPBEntriesResponse2 = QQ_SearchPricebookEntries.getPricebookEntries(null, pb.Id, 0, 50, null);
		Test.stopTest();

		System.assertEquals(3, getResultsResponse.count);
        System.assertEquals(1, getPBEntriesResponse1.count);
        System.assertEquals(3, getPBEntriesResponse2.count);
    }
    
    @isTest static void testQuoteLineSearch() {
        Quote testQuote = [SELECT Id, Pricebook2Id FROM Quote WHERE Name='Test Quote' LIMIT 1];
        Test.startTest();
        String line = QQ_SearchPricebookEntries.getQuoteLines(testQuote.Id);
        QQ_SearchPricebookEntries.QuoteLineResponse qlr = (QQ_SearchPricebookEntries.QuoteLineResponse)JSON.deserialize(line, QQ_SearchPricebookEntries.QuoteLineResponse.class);
		Test.stopTest();

		System.assertEquals(3, qlr.quoteLines.size());        
    }
    
    @isTest static void testQuotePDFGeneration() {
        Quote testQuote = [SELECT Id, Pricebook2Id FROM Quote WHERE Name='Test Quote' LIMIT 1];
        QQ_CreateQuotePdf.RequestInput input = new QQ_CreateQuotePdf.RequestInput();
        input.quoteId = testQuote.Id;
        input.templateId = '0Q05h000000i1t1CAA';
        List<QQ_CreateQuotePdf.RequestInput> inputList = new List<QQ_CreateQuotePdf.RequestInput>();
		inputList.add(input);        

        Test.startTest();
        QQ_CreateQuotePdf.createPdf(inputList);
        Test.stopTest();
    }
    
    @isTest static void testUpsertLineItems() {
        Quote testQuote = [SELECT Id, Pricebook2Id FROM Quote WHERE Name='Test Quote' LIMIT 1];
        List<QuoteLineItem> lineItems = [SELECT Id, QuoteId, PricebookEntryId, Product2Id, Quantity, UnitPrice, Discount FROM QuoteLineItem WHERE QuoteId=:testQuote.Id];
        
        QuoteLineItem extraLineItem = new QuoteLineItem(QuoteId=testQuote.Id, PricebookEntryId=lineItems[0].PricebookEntryId, Quantity=20, UnitPrice=lineItems[0].UnitPrice, Discount=30);
        lineItems.add(extraLineItem);
        lineItems[1].Quantity=lineItems[1].Quantity*5;
        QQ_UpsertAndDeleteQuoteLineItems.RequestInput input = new QQ_UpsertAndDeleteQuoteLineItems.RequestInput();
        
        input.deletedLineItems = new List<QuoteLineItem>();
        input.deletedLineItems.add(lineItems.remove(0));

        input.lineItems = new List<QuoteLineItem>();
        input.lineItems = lineItems;
        
        List<QQ_UpsertAndDeleteQuoteLineItems.RequestInput> inputList = new List<QQ_UpsertAndDeleteQuoteLineItems.RequestInput>();
        inputList.add(input);
        
        Test.startTest();
        QQ_UpsertAndDeleteQuoteLineItems.upsertQuoteLineItems(inputList);
        Test.stopTest();
        
    }
}