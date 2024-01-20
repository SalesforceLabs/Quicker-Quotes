public with sharing class QQ_SearchPricebookEntries {
    
    @AuraEnabled
    public static String getQuoteLines(Id quoteId) {

        if(QuoteLineItem.sObjectType.getDescribe().isAccessible() &&
            Schema.sObjectType.QuoteLineItem.fields.Discount.isAccessible() &&
            Schema.sObjectType.QuoteLineItem.fields.LineNumber.isAccessible() &&
            Schema.sObjectType.QuoteLineItem.fields.Product2Id.isAccessible() &&
            Schema.sObjectType.QuoteLineItem.fields.Quantity.isAccessible() &&
            Schema.sObjectType.QuoteLineItem.fields.QuoteId.isAccessible() &&
            Schema.sObjectType.QuoteLineItem.fields.UnitPrice.isAccessible() &&
            Schema.sObjectType.QuoteLineItem.fields.PricebookEntryId.isAccessible() &&
            Schema.sObjectType.PricebookEntry.fields.UnitPrice.isAccessible() &&
            Schema.sObjectType.Product2.fields.Name.isAccessible() &&
            Schema.sObjectType.Product2.fields.ProductCode.isAccessible()) {

            
            List<QuoteLineItem> qlis = [SELECT Id, PricebookEntryId, PricebookEntry.UnitPrice, Product2Id, Product2.Name, Product2.ProductCode, Quantity, UnitPrice, Discount FROM QuoteLineItem WHERE QuoteId = :String.escapeSingleQuotes(quoteId) ORDER BY LineNumber ASC];
            
            QuoteLineResponse qlr = new QuoteLineResponse();
            qlr.quoteLines = qlis;
            
            if(UserInfo.isMultiCurrencyOrganization()) {
                Map<String, Schema.SObjectField> quoteFields = Quote.getSObjectType().getDescribe().fields.getMap();
                if(quoteFields.get('CurrencyIsoCode').getDescribe().isAccessible()) {
                    Quote q = Database.Query('SELECT CurrencyIsoCode FROM Quote WHERE Id=\''+String.escapeSingleQuotes(quoteId)+'\'');
                    qlr.currencyCode = (String)q.get('CurrencyIsoCode');                    
                }
            }
            
            return JSON.serialize(qlr);                
            
        }
        return null;
    }


    @AuraEnabled
    public static Integer getTotalPricebookEntryCount(String keyword, String pricebookId, String currencyCode) {
        String queryStr = '';
        if(keyword != null && keyword != '') {
            return Database.CountQuery('SELECT Count() FROM PricebookEntry WHERE ( Name LIKE \'%'+String.escapeSingleQuotes(keyword)+'%\' OR ProductCode LIKE \'%'+String.escapeSingleQuotes(keyword)+'%\' ) AND IsActive=TRUE AND Product2.IsActive=TRUE AND Pricebook2Id=\''+String.escapeSingleQuotes(pricebookId)+'\' '+((!String.isBlank(currencyCode)) ? 'AND CurrencyIsoCode=\''+String.escapeSingleQuotes(currencyCode)+'\'' : ''));
        }
        return Database.CountQuery('SELECT Count() FROM PricebookEntry WHERE IsActive=TRUE AND Pricebook2Id=\''+String.escapeSingleQuotes(pricebookId)+'\' '+((!String.isBlank(currencyCode)) ? 'AND CurrencyIsoCode=\''+String.escapeSingleQuotes(currencyCode)+'\'' : ''));
    }
    
    @AuraEnabled
    public static Response getResults(String keyword, String pricebookId, String currencyCode) {
        if(Schema.sObjectType.PricebookEntry.fields.Name.isAccessible() &&
           Schema.sObjectType.PricebookEntry.fields.ProductCode.isAccessible() &&
           Schema.sObjectType.PricebookEntry.fields.UnitPrice.isAccessible() &&
           Schema.sObjectType.Product2.fields.Family.isAccessible()) {
            List<PricebookEntry> output = Database.Query('SELECT Id, Name, ProductCode, Product2.Family, UnitPrice FROM PricebookEntry WHERE ( Name LIKE \'%'+String.escapeSingleQuotes(keyword)+'%\' OR ProductCode LIKE \'%'+String.escapeSingleQuotes(keyword)+'%\' ) AND IsActive=TRUE AND Product2.IsActive=TRUE AND Pricebook2Id=\''+String.escapeSingleQuotes(pricebookId)+'\' '+((!String.isBlank(currencyCode)) ? 'AND CurrencyIsoCode=\''+String.escapeSingleQuotes(currencyCode)+'\' ' : '') + 'LIMIT 20');
            Response r = new Response();
            r.records = output;
            r.count = output.size();
            return r;    
        }
        return null;
    }
    
	@AuraEnabled(cacheable=true)
    public static Response getPricebookEntries(String keyword, String pricebookId, Integer offset, Integer resultLimit, String currencyCode) {
        List<PricebookEntry> output = null;
        if(Schema.sObjectType.PricebookEntry.fields.Name.isAccessible() &&
           Schema.sObjectType.PricebookEntry.fields.ProductCode.isAccessible() &&
           Schema.sObjectType.PricebookEntry.fields.UnitPrice.isAccessible() &&
           Schema.sObjectType.Product2.fields.Family.isAccessible()) {
            if(keyword != null && keyword != '') {
                output = Database.Query('SELECT Id, Name, ProductCode, Product2.Family, UnitPrice FROM PricebookEntry WHERE ( Name LIKE \'%'+String.escapeSingleQuotes(keyword)+'%\' OR ProductCode LIKE \'%'+String.escapeSingleQuotes(keyword)+'%\' ) AND IsActive=TRUE AND Product2.IsActive=TRUE AND Pricebook2Id=\''+String.escapeSingleQuotes(pricebookId)+'\' '+((!String.isBlank(currencyCode)) ? 'AND CurrencyIsoCode=\''+String.escapeSingleQuotes(currencyCode)+'\' ' : '') + 'ORDER BY Name ASC LIMIT '+resultLimit+' OFFSET '+offset);
            } else {
                output = Database.Query('SELECT Id, Name, ProductCode, Product2.Family, UnitPrice FROM PricebookEntry WHERE IsActive=TRUE AND Product2.IsActive=TRUE AND Pricebook2Id=\''+String.escapeSingleQuotes(pricebookId)+'\' '+((!String.isBlank(currencyCode)) ? 'AND CurrencyIsoCode=\''+String.escapeSingleQuotes(currencyCode)+'\' ' : '') + 'ORDER BY Name ASC LIMIT '+resultLimit+' OFFSET '+offset);
            }
            Response r = new Response();
            r.records = output;
            r.count = output.size();
            r.totalCount = getTotalPricebookEntryCount(keyword, pricebookId, currencyCode);
            return r;
        }
        return null;
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