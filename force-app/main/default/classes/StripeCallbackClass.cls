@RestResource(UrlMapping='/Stripe')
global without sharing class StripeCallbackClass {
    
    @HttpPost
    global static void doPost() {
        String headers = JSON.serialize(RestContext.request.headers);
        String data = RestContext.request.requestBody.toString();
        System.debug(data);
        String formattedJSONString = data.replace('object', 'objectz');
        
        StripeResponse stripeResponse = (StripeResponse) JSON.deserialize(formattedJSONString, StripeResponse.class);

        System.debug(stripeResponse.data.objectz.id);

        Cart__c cart = [Select Id, Status__c from Cart__c where Stripe_Transaction_Id__c = :stripeResponse.data.objectz.id];

        cart.Status__c = 'Paid';

        update cart;
        
    }

    
}