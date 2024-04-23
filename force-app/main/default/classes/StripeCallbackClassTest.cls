@isTest
private class StripeCallbackClassTest {
	// @isTest
	// static void testStripeCallback() {
	//     // Create test data
	//     Cart__c testCart = new Cart__c();
	//     testCart.Stripe_Transaction_Id__c = 'testTransactionId';
	//     //testCart.Status__c = 'Unpaid';
	//     insert testCart;

	//     // Set up mock callout
	//     Test.setMock(HttpCalloutMock.class, new StripeCallbackMock());

	//     // Call the REST endpoint
	//     Test.startTest();
	//     RestRequest req = new RestRequest();
	//     RestResponse res = new RestResponse();
	//     req.requestURI = 'https://example.com/Stripe';
	//     req.httpMethod = 'POST';
	//     RestContext.request = req;
	//     RestContext.response = res;
	//     StripeCallbackClass.doPost();
	//     Test.stopTest();

	//     // Verify that the cart status is updated
	//     Cart__c updatedCart = [SELECT Status__c FROM Cart__c WHERE Id = :testCart.Id];
	//     System.assertEquals('Paid', updatedCart.Status__c,'Status is not paid');
	// }
}