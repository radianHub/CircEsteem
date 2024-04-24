@isTest
private class JunctionSelectorControllerTest {
	@TestSetup
	private static void makeData() {
		Account account = new Account(Name = 'Test Account 123');
		insert account;

		Product2 product = new Product2(IsActive = true, Name = 'Test Product 123');
		insert product;

		PricebookEntry pricebookEntry = new PricebookEntry(
			Pricebook2Id = Test.getStandardPricebookId(),
			Product2Id = product.Id,
			IsActive = true,
			UnitPrice = 1
		);
		insert pricebookEntry;
	}

	@isTest
	private static void getChildRecords() {
		Test.startTest();
		List<SObject> records = JunctionSelectorController.getChildRecords('Account');
		Test.stopTest();

		Assert.areEqual(1, records.size(), 'Did not return exactly 1 record');
	}

	@isTest
	private static void getJunctionRecords() {
		Test.startTest();
		List<SObject> records = JunctionSelectorController.getJunctionRecords('PricebookEntry', 'Pricebook2Id', 'Product2Id', Test.getStandardPricebookId());
		Test.stopTest();

		Assert.areEqual(1, records.size(), 'Did not return exactly 1 record');
	}

	@isTest
	private static void getData() {
		Test.startTest();
		JunctionSelectorController.DataWrapper data = JunctionSelectorController.getData(
			'Product2',
			'PricebookEntry',
			'Pricebook2Id',
			'Product2Id',
			Test.getStandardPricebookId()
		);
		Test.stopTest();

		Assert.areEqual(1, data.childRecords.size(), 'Did not return exactly 1 product');
		Assert.areEqual(1, data.junctionRecords.size(), 'Did not return exactly 1 pricebook entry');
	}

	// @isTest
	// private static void insertRecords() {
	// 	Product2 product = new Product2(IsActive = true, Name = 'Test Product 456');
	// 	insert product;

	// 	Test.startTest();
	// 	JunctionSelectorController.insertRecords('Pricebook2Id', Test.getStandardPricebookId(), 'Product2Id', product.Id, 'PricebookEntry');
	// 	Test.stopTest();

	// 	List<PricebookEntry> pricebookEntries = [SELECT Id FROM PricebookEntry WHERE Product2Id = :product.Id];
	// 	Assert.areEqual(1, pricebookEntries.size(), 'Did not return exactly 1 pricebook entry');
	// }

	@isTest
	private static void deleteRecords() {
		Product2 product = [SELECT Id FROM Product2 WHERE Name = 'Test Product 123' LIMIT 1];
		Test.startTest();
		JunctionSelectorController.deleteRecords('Pricebook2Id', Test.getStandardPricebookId(), 'Product2Id', product.Id, 'PricebookEntry');
		Test.stopTest();

		List<PricebookEntry> pricebookEntries = [SELECT Id FROM PricebookEntry WHERE Product2Id = :product.Id];
		Assert.areEqual(0, pricebookEntries.size(), 'Did not return exactly 0 pricebook entries');
	}
}