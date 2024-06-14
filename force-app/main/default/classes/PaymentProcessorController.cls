public with sharing class PaymentProcessorController {
    
    @AuraEnabled(cacheable=true)
	public static Stripe_Bearer_Token__c getSettings() {
		return Stripe_Bearer_Token__c.getOrgDefaults();
	}

	@AuraEnabled
	public static void createAppliedCredits(Id cartId, String appliedCreditsJson){
		try {
			CreditService.createAppliedCredits(cartId, appliedCreditsJson);	
		} catch (Exception e) {
			throw new AuraHandledException(e.getMessage());
		}
	}	
}