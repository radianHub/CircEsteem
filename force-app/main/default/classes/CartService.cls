public with sharing class CartService {

	public static List<Cart__c> getUserCart(Id userId) {
		try {
			Id uCon = ContactService.getIdFromUser(userId);
			return [
				SELECT Id, Total__c
				FROM Cart__c
				WHERE Contact__c = :uCon AND Status__c = 'Open' AND RecordType.DeveloperName = 'Shop'
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
				Contact__c = ContactService.getIdFromUser(userId),
				RecordTypeId = [SELECT Id FROM RecordType WHERE DeveloperName = 'Shop' AND SObjectType = 'Cart__c'].Id
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

	public static Cart__c createCartWithProducts(Id sessionId, Id contactId) {
		Program_Session__c session = [
			SELECT
				Id,
				Name,
				Program__r.Price__c
			FROM Program_Session__c
			WHERE Id = :sessionId
		];

		Contact con = [
			SELECT Id, AccountId
			FROM Contact
			WHERE Id = :contactId
		];

		List<Program_Engagement__c> engagementList = [
			SELECT
				Id,
				Child__c,
				Child_Name__c
			FROM Program_Engagement__c
			WHERE Program_Session__c = :sessionId
				AND Account__c = :con.AccountId
				AND Payment_Status__c = 'Not Paid'
		];

		Cart__c cart = new Cart__c(
			Contact__c = contactId,
			Status__c = 'Open',
			RecordTypeId = [SELECT Id FROM RecordType WHERE DeveloperName = 'Program' AND SObjectType = 'Cart__c'].Id
		);
		insert cart;

		List<Cart_Product__c> productList = new List<Cart_Product__c>();
		for (Program_Engagement__c engagement : engagementList) {
			productList.add(new Cart_Product__c(
				Cart__c = cart.Id,
				Name = String.format('{0} - {1}', new List<String>{
					session.Name,
					engagement.Child_Name__c
				}),
				Price__c = session.Program__r.Price__c,
				Program_Engagement__c = engagement.Id,
				Quantity__c = 1
			));
		}
		insert productList;
		
		return getCart(cart.Id);
	}
}