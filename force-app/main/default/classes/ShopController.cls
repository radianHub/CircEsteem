public with sharing class ShopController {
	@AuraEnabled(cacheable=true)
	public static List<Cart__c> getCart() {
		try {
			return CartService.getUserCart(UserInfo.getUserId());
		} catch (Exception e) {
			throw new AuraHandledException(e.getMessage());
		}
	}

	@AuraEnabled
	public static Cart__c createCart() {
		try {
			return CartService.createUserCart(UserInfo.getUserId());
		} catch (Exception e) {
			throw new AuraHandledException(e.getMessage());
		}
	}

	@AuraEnabled(cacheable=true)
	public static List<PricebookEntry> getPricebookEntries() {
		try {
			return PricebookEntryService.getPricebookEntries('Merchandise');
		} catch (Exception e) {
			throw new AuraHandledException(e.getMessage());
		}
	}
}