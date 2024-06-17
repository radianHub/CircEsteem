public with sharing class ViewCartController {
	@AuraEnabled(cacheable=true)
	public static Cart__c getCart(Id cartId) {
		try {
			return CartService.getCart(cartId);
		} catch (Exception e) {
			throw new AuraHandledException(e.getMessage());
		}
	}

	// @AuraEnabled
	// public static void cartCheckout(Id cartId) {
	// 	try {
	// 		System.debug('checkout cart ' + cartId);
	// 	} catch (Exception e) {
	// 		throw new AuraHandledException(e.getMessage());
	// 	}
	// }

	@AuraEnabled(cacheable=true)
	public static List<Credit__c> getCredits(Id contactId) {
		try {
			return CreditService.getCredits(contactId);
		}
		catch (Exception ex) {
			throw new AuraHandledException(ex.getMessage());
		}	
	}
}