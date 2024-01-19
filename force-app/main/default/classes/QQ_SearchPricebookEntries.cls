public with sharing class QQ_SearchPricebookEntries {
    
    @AuraEnabled
    public static String getQuoteLines(Id quoteId) {

        List<QuoteLineItem> qlis = [SELECT Id, PricebookEntryId, PricebookEntry.UnitPrice, Product2Id, Product2.Name, Product2.ProductCode, Quantity, UnitPrice, Discount FROM QuoteLineItem WHERE QuoteId = :String.escapeSingleQuotes(quoteId) ORDER BY LineNumber ASC];
        
        QuoteLineResponse qlr = new QuoteLineResponse();
        qlr.quoteLines = qlis;
        
        if(UserInfo.isMultiCurrencyOrganization()) {
            String queryStr = 'SELECT CurrencyIsoCode FROM Quote WHERE Id=\''+String.escapeSingleQuotes(quoteId)+'\'';
            Quote q = Database.Query(queryStr);
            qlr.currencyCode = (String)q.get('CurrencyIsoCode');
        }
        
        return JSON.serialize(qlr);                
    }


    @AuraEnabled
    public static Integer getTotalPricebookEntryCount(String keyword, String pricebookId, String currencyCode) {
        String queryStr = '';
        if(keyword != null && keyword != '') {
            queryStr = 'SELECT Count() FROM PricebookEntry WHERE ( Name LIKE \'%'+String.escapeSingleQuotes(keyword)+'%\' OR ProductCode LIKE \'%'+String.escapeSingleQuotes(keyword)+'%\' ) AND IsActive=TRUE AND Product2.IsActive=TRUE AND Pricebook2Id=\''+String.escapeSingleQuotes(pricebookId)+'\' '+((!String.isBlank(currencyCode)) ? 'AND CurrencyIsoCode=\''+String.escapeSingleQuotes(currencyCode)+'\'' : '');
        } else {
            queryStr = 'SELECT Count() FROM PricebookEntry WHERE IsActive=TRUE AND Pricebook2Id=\''+String.escapeSingleQuotes(pricebookId)+'\' '+((!String.isBlank(currencyCode)) ? 'AND CurrencyIsoCode=\''+String.escapeSingleQuotes(currencyCode)+'\'' : '');
        }
        return Database.CountQuery(queryStr); 
    }
    
    @AuraEnabled
    public static Response getResults(String keyword, String pricebookId, String currencyCode) {
        String queryStr = 'SELECT Id, Name, ProductCode, Product2.Family, UnitPrice FROM PricebookEntry WHERE ( Name LIKE \'%'+String.escapeSingleQuotes(keyword)+'%\' OR ProductCode LIKE \'%'+String.escapeSingleQuotes(keyword)+'%\' ) AND IsActive=TRUE AND Product2.IsActive=TRUE AND Pricebook2Id=\''+String.escapeSingleQuotes(pricebookId)+'\' '+((!String.isBlank(currencyCode)) ? 'AND CurrencyIsoCode=\''+String.escapeSingleQuotes(currencyCode)+'\' ' : '') + 'LIMIT 20';
        List<PricebookEntry> output = Database.Query(queryStr);
        Response r = new Response();
        r.records = output;
        r.count = output.size();
        return r;
    }
    
	@AuraEnabled(cacheable=true)
    public static Response getPricebookEntries(String keyword, String pricebookId, Integer offset, Integer resultLimit, String currencyCode) {
        String queryStr = '';
        if(keyword != null && keyword != '') {
            queryStr = 'SELECT Id, Name, ProductCode, Product2.Family, UnitPrice FROM PricebookEntry WHERE ( Name LIKE \'%'+String.escapeSingleQuotes(keyword)+'%\' OR ProductCode LIKE \'%'+String.escapeSingleQuotes(keyword)+'%\' ) AND IsActive=TRUE AND Product2.IsActive=TRUE AND Pricebook2Id=\''+String.escapeSingleQuotes(pricebookId)+'\' '+((!String.isBlank(currencyCode)) ? 'AND CurrencyIsoCode=\''+String.escapeSingleQuotes(currencyCode)+'\' ' : '') + 'ORDER BY Name ASC LIMIT '+resultLimit+' OFFSET '+offset;
        } else {
            queryStr = 'SELECT Id, Name, ProductCode, Product2.Family, UnitPrice FROM PricebookEntry WHERE IsActive=TRUE AND Product2.IsActive=TRUE AND Pricebook2Id=\''+String.escapeSingleQuotes(pricebookId)+'\' '+((!String.isBlank(currencyCode)) ? 'AND CurrencyIsoCode=\''+String.escapeSingleQuotes(currencyCode)+'\' ' : '') + 'ORDER BY Name ASC LIMIT '+resultLimit+' OFFSET '+offset;
        }
        List<PricebookEntry> output = Database.Query(queryStr);
        Response r = new Response();
        r.records = output;
        r.count = output.size();
        r.totalCount = getTotalPricebookEntryCount(keyword, pricebookId, currencyCode);
        return r;
    }
    
    public class Response {
        @AuraEnabled public List<PricebookEntry> records;
        @AuraEnabled public Integer count;
        @AuraEnabled public Integer totalCount;
    }
    
    public class QuoteLineResponse {
        @AuraEnabled public String currencyCode;
        @AuraEnabled public List<QuoteLineItem> quoteLines;
    }
    
}