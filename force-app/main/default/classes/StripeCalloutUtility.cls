public with sharing class StripeCalloutUtility {
    

    private static String baseStripeUrl = 'https://api.stripe.com/';

    @Future(callout=true)
    public static void checkout(String cartId) {

        List<Cart_Product__c> cart = [select Id, 
        Name, 
        Price_Cents__c, 
        Quantity__c 
        from Cart_Product__c 
        where Cart__c = :cartId
        ];

        String url = '';
        String calloutUrl = baseStripeUrl + 'v1/checkout/sessions';
        String requestMethed = 'POST';
        String requestBody = '';
        
        Integer currentItem = 0;
        for(Cart_Product__c product : cart) {
            requestBody += EncodingUtil.urlEncode('cancel_url', 'UTF-8') + '=' + EncodingUtil.urlEncode('https://www.radianhub.com', 'UTF-8') + '&';
            requestBody += EncodingUtil.urlEncode('success_url', 'UTF-8') + '=' + EncodingUtil.urlEncode('https://www.radianhub.com', 'UTF-8') + '&';
            requestBody += EncodingUtil.urlEncode('line_items[' + currentItem + '][price_data][currency]', 'UTF-8') + '=' + EncodingUtil.urlEncode('usd', 'UTF-8') + '&';
            requestBody += EncodingUtil.urlEncode('line_items[' + currentItem + '][price_data][product_data][name]', 'UTF-8') + '=' + EncodingUtil.urlEncode(Product.Name, 'UTF-8') + '&';
            requestBody += EncodingUtil.urlEncode('line_items[' + currentItem + '][price_data][unit_amount]', 'UTF-8') + '=' + EncodingUtil.urlEncode(String.valueOf(product.Price_Cents__c), 'UTF-8') + '&';
            requestBody += EncodingUtil.urlEncode('line_items[' + currentItem + '][quantity]', 'UTF-8') + '=' + EncodingUtil.urlEncode(String.valueOf(product.Quantity__c), 'UTF-8') + '&';
            requestBody += EncodingUtil.urlEncode('mode', 'UTF-8') + '=' + EncodingUtil.urlEncode('payment', 'UTF-8') + '&';
            requestBody += EncodingUtil.urlEncode('payment_method_types[' + currentItem + ']', 'UTF-8') + '=' + EncodingUtil.urlEncode('card', 'UTF-8') + '&';
            currentItem ++;
        }
        requestBody = requestBody.removeEnd('&');
        System.debug(requestBody);

        System.debug(requestBody);
        HttpResponse res = getResponse(calloutUrl, 'POST', requestBody, 120000);

        //return url;

    }

    public static HttpResponse getResponse(String requestEndpoint, String requestMethod, String requestBody, Integer requestTimeout) {
		HttpRequest req = new HttpRequest();
		req.setEndpoint(requestEndpoint);
		req.setMethod(requestMethod);
		if (requestBody != null && requestBody != '') {
			req.setBody(requestBody);
		}
		System.debug(req.getBody());
        System.debug(requestEndpoint);
		req.setTimeout(requestTimeout);
		//        for(String HeaderKey : Headers.keySet())
		//req.setHeader('Accept', 'application/vnd.oracle.resource+json; type=collection');
		req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
		req.setHeader('Authorization', 'Bearer sk_test_il83KwEBxwbiwEDoqlqY5cF7');
        req.setHeader('Accept-Encoding', 'gzip, deflate, br');
        req.setHeader('Accept', '*/*');
		System.debug(req);
		Http http = new Http();
		HTTPResponse response = http.send(req);

		if (response.getStatusCode() == 200 || response.getStatusCode() == 201) {
			system.debug('Successful callout.');
			system.debug('Response Body: ' + response.getBody());
			return response;
		} else {
			/**Callout_Log__c callout = new Callout_Log__c();
			callout.Request_Header__c = req.getHeader('Content-Type');
			callout.Request_Body__c = req.getBody();
			callout.Response_Body__c = response.getBody();
			callout.Response_Code__c = String.valueOf(response.getStatusCode());
			callout.Status__c = 'ERROR';
			insert callout;
			//throw new CalloutException(response.getBody());**/
            System.debug(response);
			return response;
		}
	}

}