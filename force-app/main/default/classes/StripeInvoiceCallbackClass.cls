/**
 * @Class Name     : 
 * @Class Purpose  : 
 * @Author         : Zachary Csotya
 * @Developed On   : 
 * @Last Modified  : 06/13/2024
**/
@RestResource(UrlMapping='/StripeInvoice')
global without sharing class StripeInvoiceCallbackClass {
	@httpPost
	global static void doPost() {
		// * CONVERT INVOICE BODY JSON TO CLASS DATA
		String invData = Restcontext.request.requestBody.toString();
		invData = invData.replaceAll('object', 'objectz');
		invData = invData.replaceAll('currency', 'currenyz');
		StripeInvoiceResponse stripeInvResp = (StripeInvoiceResponse) System.JSON.deserialize(
			invData,
			StripeInvoiceResponse.class
		);

		// * QUERY FOR CART
		Cart__c cart = [
			SELECT Id, Status__c, Amount_Paid__c, Total__c
			FROM Cart__c
			WHERE Stripe_Subscription_Id__c = :stripeInvResp.data.objectz.subscription
		];
		

        // * UPDATE CART INFO
		if (cart.Amount_Paid__c + (stripeInvResp.data.objectz.amount_paid / 100) >= cart.Total__c) {
            cart.Status__c = 'Paid';
		}

        // * CREATE INVOICE RECORD AGAIN CART
        Invoice__c inv = new Invoice__c(
            Cart__c = cart.Id,
            Amount__c = stripeInvResp.data.objectz.amount_paid / 100,
            Stripe_Invoice_Id__c = stripeInvResp.data.objectz.id,
			Invoice_PDF__c = stripeInvResp.data.objectz.hosted_invoice_url
        );

        upsert inv Stripe_Invoice_Id__c;
        update cart;
	}
}
