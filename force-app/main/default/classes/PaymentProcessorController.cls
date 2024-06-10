public with sharing class PaymentProcessorController {
    
    @AuraEnabled(cacheable=true)
	public static Stripe_Bearer_Token__c getSettings() {
		return Stripe_Bearer_Token__c.getOrgDefaults();
	}
}