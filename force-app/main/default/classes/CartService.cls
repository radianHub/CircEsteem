public with sharing class CartService {
	public static List<Cart__c> getUserCart(Id userId) {
		try {
			return [
				SELECT Id, Total__c
				FROM Cart__c
				WHERE User__c = :userId AND Status__c = 'Open'
			];
		} catch (Exception e) {
			throw new AuraHandledException(e.getMessage());
		}
	}

	public static Cart__c createUserCart(Id userId) {
		try {
			Cart__c cart = new Cart__c(User__c = userId);
			insert cart;

			return getUserCart(userId)[0];
		} catch (Exception e) {
			throw new AuraHandledException(e.getMessage());
		}
	}

	public static Cart__c getCart(Id cartId) {
		return [
			SELECT Id, Total__c, (SELECT Id, Name, Price__c, Quantity__c, Price_Cents__c, Total__c FROM Cart_Products__r)
			FROM Cart__c
			WHERE Id = :cartId
		];
	}
}