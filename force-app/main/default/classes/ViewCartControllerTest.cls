@isTest
private class ViewCartControllerTest {

    @testSetup
    private static void makeData() {

        Account acc = (Account) new SObjectBuilder(Account.SObjectType)
            .create()
            .getRecord();

        Contact uContact = (Contact) new SObjectBuilder(Contact.SObjectType)
            .put(Contact.AccountId, acc.Id)
            .create()
            .getRecord(); 
        
        Cart__c cart = (Cart__c) new SObjectBuilder(Cart__c.SObjectType)
            .put(Cart__c.Status__c, 'Open')
            .create()
            .getRecord();
        
        Credit__c credit = (Credit__c) new SObjectBuilder(Credit__c.SObjectType)
            .put(Credit__c.Household__c, acc.Id)
            .put(Credit__c.Credit_Amount__c, 60)
            .create()
            .getRecord();
    }

    @isTest
    private static void getCartTest() {
        Cart__c cart = ViewCartController.getCart([SELECT Id FROM Cart__c LIMIT 1].Id);
        Assert.isNotNull(cart, 'No Cart Returned.');

        try {
            cart = ViewCartController.getCart(null);
        }
        catch (Exception ex) {
            Assert.isNotNull(ex.getMessage(), 'Returned cart with a null Id.');
        }
    }
    
    @isTest
    private static void getCreditsTest() {
        List<Credit__c> credits = ViewCartController.getCredits([SELECT Id FROM Contact LIMIT 1].Id);
        Assert.isTrue(credits.size() > 0, 'No Credits returned.');

        try {
            credits = ViewCartController.getCredits(null);
        }
        catch (Exception ex) {
            Assert.isNotNull(ex.getMessage(), 'Returned Credits with a null Id.');
        }
    }

}