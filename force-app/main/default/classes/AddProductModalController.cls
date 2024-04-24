public with sharing class AddProductModalController {
	@AuraEnabled(cacheable=true)
	public static PricebookEntry getPricebookEntry(Id pricebookEntryId) {
		try {
			return PricebookEntryService.getPricebookEntry(pricebookEntryId);
		} catch (Exception e) {
			throw new AuraHandledException(e.getMessage());
		}
	}
}