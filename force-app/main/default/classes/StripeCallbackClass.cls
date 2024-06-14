@RestResource(UrlMapping='/Stripe')
global without sharing class StripeCallbackClass {
	@HttpPost
	global static void doPost() {

		// * CONVERT CHECKOUT BODY JSON TO CLASS DATA
		String data = RestContext.request.requestBody.toString();
		String formattedJSONString = data.replace('object', 'objectz');
		StripeResponse stripeResponse = (StripeResponse) JSON.deserialize(formattedJSONString, StripeResponse.class);

		// * QUERY FOR CART
		Cart__c cart = [
			SELECT Id, Status__c, Stripe_Subscription_Id__c, Recurrence__c, Length__c
			FROM Cart__c
			WHERE Stripe_Transaction_Id__c = :stripeResponse.data.objectz.id
		];

		// * UPDATE CART INFO
		cart.Status__c = 'Paid';

		// * CREATE INVOICE RECORD AGAINST CART
		Invoice__c inv = new Invoice__c(
			Cart__c = cart.Id,
			Amount__c = stripeResponse.data.objectz.amount_total / 100
		);

		// * PROCESS ADDITIONAL DATA IF CHECKOUT IS A SUBSCRIPTION
		if (stripeResponse.data.objectz.mode == 'subscription') {
			// * GET SUBSCRIPTION INFO
			StripeResponse.cls_subscriptionInfo subInfo = new StripeResponse.cls_subscriptionInfo()
				.parse(stripeResponse.data.objectz.metadata.subscriptionInfo);

			// * UPDATE CART INFO
			cart.Status__c = 'Payment Plan';
			cart.Recurrence__c = subInfo.frequency;
			cart.Length__c = subInfo.length;
			cart.Stripe_Subscription_Id__c = stripeResponse.data.objectz.subscription;
			
			// * ADD STRIPE INVOICE ID TO INV RECORD
			inv.Stripe_Invoice_Id__c = stripeResponse.data.objectz.invoice;

			// * CREATE SUBSCRIPTION SCHEDULE
			StripeCalloutUtility.createSubscriptionSchedule(stripeResponse.data.objectz.subscription, subInfo.length);
		}

		insert inv;
		update cart;
	}
}
