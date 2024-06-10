@RestResource(UrlMapping='/Stripe')
global without sharing class StripeCallbackClass {
	@HttpPost
	global static void doPost() {
		String headers = JSON.serialize(RestContext.request.headers);
		String data = RestContext.request.requestBody.toString();

		String formattedJSONString = data.replace('object', 'objectz');

		StripeResponse stripeResponse = (StripeResponse) JSON.deserialize(formattedJSONString, StripeResponse.class);

		Cart__c cart = [
			SELECT Id, Status__c, Stripe_Subscription_Id__c, Recurrence__c, Length__c
			FROM Cart__c
			WHERE Stripe_Transaction_Id__c = :stripeResponse.data.objectz.id
		];
		
		if (stripeResponse.data.objectz.mode == 'subscription') {
			StripeResponse.cls_subscriptionInfo subInfo = new StripeResponse.cls_subscriptionInfo().parse(stripeResponse.data.objectz.metadata.subscriptionInfo);
			
			cart.Status__c = 'Payment Plan';
			
			// TODO: MAKE CALL TO GET INVOICE DATA


			// TODO: MAKE CALL TO CREATE SUBSCRIPTION SCHEDULE

			
		} else { 
			cart.Status__c = 'Paid';
			update cart;
		}

	}
}