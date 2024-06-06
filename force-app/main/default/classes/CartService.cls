public with sharing class CartService {

	public static List<Cart__c> getUserCart(Id userId) {
		try {
			Id uCon = ContactService.getIdFromUser(userId);
			return [
				SELECT Id, Total__c
				FROM Cart__c
				WHERE Contact__c = :uCon AND Status__c = 'Open'
			];	
		} catch (QueryException e) {
			throw new AuraHandledException('No contact associated with the current user.');
		} catch (Exception e) {
			throw new AuraHandledException(e.getMessage());
		}
	}

	public static Cart__c createUserCart(Id userId) {
		try {
			Cart__c cart = new Cart__c(
				Contact__c = ContactService.getIdFromUser(userId)
			);
			insert cart;

			return getUserCart(userId)[0];
		} catch (QueryException e) {
			throw new AuraHandledException('No contact associated with the current user.');
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