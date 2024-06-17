/**
 * @Class Name     : StripeCalloutUtility
 * @Class Purpose  : Make http call-outs to the stripe api.
 * @Author         : Zachary Csotya
 * @Developed On   : 
 * @Last Modified  : 06/13/2024
**/
public with sharing class StripeCalloutUtility {
	private static String baseStripeUrl = 'https://api.stripe.com/';
	private static Stripe_Bearer_Token__c stripeAuth = Stripe_Bearer_Token__c.getOrgDefaults();

	/**
	* @description Make a callout to the stripe api
	* @author Jake Karl 
	* @param String requestEndpoint 
	* @param String requestMethod 
	* @param String requestBody 
	* @param Integer requestTimeout 
	* @return HttpResponse 
	**/
	public static HttpResponse getResponse(
		String requestEndpoint,
		String requestMethod,
		String requestBody,
		Integer requestTimeout
	) {
		HttpRequest req = new HttpRequest();
		req.setEndpoint(requestEndpoint);
		req.setMethod(requestMethod);
		req.setTimeout(requestTimeout);
		req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
		req.setHeader('Authorization', 'Bearer ' + stripeAuth.Bearer_Token__c);
		req.setHeader('Accept-Encoding', 'gzip, deflate, br');
		req.setHeader('Accept', '*/*');
		if (requestBody != null && requestBody != '') {
			req.setBody(requestBody);
		}

		System.debug(req.getBody());
		System.debug(requestEndpoint);
		System.debug(req);

		Http http = new Http();
		HTTPResponse response = http.send(req);

		if (response.getStatusCode() == 200 || response.getStatusCode() == 201) {
			system.debug('Successful callout.');
			system.debug('Response Body: ' + response.getBody());
			return response;
		} else {
			System.debug(response);
			throw new CalloutException(response.getBody());
		}
	}

    /**
    * @description Encode a body or url query in x-www-form-urlencoded format
    * @author Zachary Csotya | 06/11/2024 
    * @param Map<String Object> payload 
    * @return String 
    **/
    private static String encodePayload(Map<String, Object> payload) {
        String body = '';
        for (String key : payload.keySet()) {
            if (body.length() != 0) {
                body += '&';
            }
            body += key + '=' + payload.get(key);
        }
        return body;
    }

	/**
	* @description Create a subscription schedule for a given number of iterations
	* @author Zachary Csotya | 06/11/2024 
	* @param String stripeSubscriptionId 
	* @param Integer iterations 
	**/
	@Future(callout=true)
	public static void createSubscriptionSchedule(
		String stripeSubscriptionId,
		Integer iterations
	) {

        // * CALL TO CREATE THE SUBSCRIPTION SCHEDULE
        HttpResponse scheduleResp = getResponse(
            baseStripeUrl + 'v1/subscription_schedules',
            'POST',
            encodePayload(new Map<String, Object>{
                'from_subscription' => stripeSubscriptionId
            }),
            120000
        );

        // * DESERIALIZE THE SUBSCRIPTION SCHEDULE RESPONSE
        String scheduleJson = scheduleResp.getBody().toString().replaceAll('object', 'objectz');
        scheduleJson = scheduleJson.replaceAll('currency', 'currencyz');
        StripeSubscriptionScheduleResponse scheduleData = StripeSubscriptionScheduleResponse.parse(scheduleJson);

        // * BUILD PAYLOAD TO UPDATE THE SUBSCRIPTION SCHEDULE
        Map<String, Object> schedUpdatePayload = new Map<String, Object>();
        schedUpdatePayload.put('end_behavior', 'cancel');
        schedUpdatePayload.put('phases[0][start_date]', scheduleData.phases[0].start_date);
        schedUpdatePayload.put('phases[0][iterations]', iterations);

        Integer i = 0;
        for (StripeSubscriptionScheduleResponse.cls_items item : scheduleData.phases[0].items) {
            String phaseBase = String.format(
                'phases[0][items][{0}]',
                new List<String>{String.valueOf(i)}
            );
            schedUpdatePayload.put(phaseBase + '[price]', item.price);
            schedUpdatePayload.put(phaseBase + '[quantity]', item.quantity);
            i++;
        }
        
        // * CALL TO UPDATE THE SUBSCRIPTION SCHEDULE
        HttpResponse scheduleUpdateResp = getResponse(
            baseStripeUrl + 'v1/subscription_schedules/' + scheduleData.id,
            'POST',
            encodePayload(schedUpdatePayload),
            120000
        );
	}
}