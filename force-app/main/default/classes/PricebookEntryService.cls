public with sharing class PricebookEntryService {
	public static List<PricebookEntry> getPricebookEntries(String pricebookName) {
		try {
			List<PricebookEntry> pricebookEntries = [
				SELECT Id, Name, UnitPrice, Product2.DisplayUrl
				FROM PricebookEntry
				WHERE Pricebook2.Name = :pricebookName AND IsActive = TRUE
			];

			return pricebookEntries;
		} catch (Exception e) {
			throw new AuraHandledException(e.getMessage());
		}
	}

	public static PricebookEntry getPricebookEntry(Id pricebookEntryId) {
		try {
			return [SELECT Id, Name, UnitPrice, Product2.DisplayUrl FROM PricebookEntry WHERE Id = :pricebookEntryId];
		} catch (Exception e) {
			throw new AuraHandledException(e.getMessage());
		}
	}
}