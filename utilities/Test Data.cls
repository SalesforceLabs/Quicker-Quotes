// Generate Sample Data
/**/
List<Account> accts = new List<Account>();
accts.add(new Account(Name='Account A'));
accts.add(new Account(Name='Account B'));
insert(accts);

List<Contact> cts = new List<Contact>();
for(Integer i=0; i<accts.size(); i++) {
    cts.add(new Contact(FirstName='Test'+i, LastName='Contact', AccountId=accts[i].Id, Email='contact'+i+'@example.com'));
}
insert(cts);

List<Decimal> prices = new List<Decimal>{100, 250, 500};

List<Product2> prods = new List<Product2>();
prods.add(new Product2(Name='Sample Product 1', ProductCode='ABC1', IsActive=TRUE));
prods.add(new Product2(Name='Sample Product 2', ProductCode='ABC2', IsActive=TRUE));
prods.add(new Product2(Name='Sample Product 3', ProductCode='ABC3', IsActive=TRUE));
insert(prods);

            
            
PriceBook2 spb = [SELECT Id FROM PriceBook2 WHERE IsStandard = TRUE];
List<PriceBookEntry> pbes = new List<PriceBookEntry>();
for(Integer i=0; i<prods.size(); i++) {
	pbes.add(new PriceBookEntry(Product2Id=prods[i].Id, Pricebook2Id=spb.Id, UnitPrice=prices[i], IsActive=TRUE));    
}
insert(pbes);

PriceBook2 tpb = new PriceBook2(Name='Test Pricebook', IsActive=TRUE);
insert(tpb);

List<PriceBookEntry> pbes2 = new List<PriceBookEntry>();
for(Integer i=0; i<prods.size(); i++) {
	pbes2.add(new PriceBookEntry(Product2Id=prods[i].Id, Pricebook2Id=tpb.Id, UnitPrice=prices[i], IsActive=TRUE));    
}
insert(pbes2);
/**/

// Delete All Data
// First manually delete the Pricebook entries from the Test Price Book. Then run this:
/*
delete([SELECT Id FROM PriceBookEntry]);
delete([SELECT Id FROM Product2]);
delete([SELECT Id FROM PriceBook2 WHERE IsStandard = FALSE]);
delete([SELECT Id FROM Contact]);
delete([SELECT Id FROM Account WHERE Name LIKE 'Account%']);
*/