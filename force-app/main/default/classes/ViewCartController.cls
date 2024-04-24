public with sharing class ViewCartController {
	@AuraEnabled(cacheable=true)
	public static Cart__c getCart(Id cartId) {
		try {
			return CartService.getCart(cartId);
		} catch (Exception e) {
			throw new AuraHandledException(e.getMessage());
		}
	}

	@AuraEnabled
	public static void cartCheckout(Id cartId) {
		try {
			System.debug('checkout cart ' + cartId);
		} catch (Exception e) {
			throw new AuraHandledException(e.getMessage());
		}
	}

	@AuraEnabled(cacheable=true)
	public static Stripe_Bearer_Token__c getSettings() {
		return Stripe_Bearer_Token__c.getOrgDefaults();
	}
}