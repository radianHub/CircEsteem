@RestResource(UrlMapping='/Stripe')
global without sharing class StripeCallbackClass {
	@HttpPost
	global static void doPost() {
		String headers = JSON.serialize(RestContext.request.headers);
		String data = RestContext.request.requestBody.toString();

		String formattedJSONString = data.replace('object', 'objectz');

		StripeResponse stripeResponse = (StripeResponse) JSON.deserialize(formattedJSONString, StripeResponse.class);

		Cart__c cart = [
			SELECT Id, Status__c
			FROM Cart__c
			WHERE Stripe_Transaction_Id__c = :stripeResponse.data.objectz.id
		];

		cart.Status__c = 'Paid';

		update cart;
	}
}