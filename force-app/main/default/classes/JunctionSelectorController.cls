public with sharing class JunctionSelectorController {
	public static List<SObject> getChildRecords(String childObjectApiName) {
		String query = 'SELECT Id, Name FROM ' + childObjectApiName;
		return Database.query(query);
	}

	@AuraEnabled
	public static List<SObject> getJunctionRecords(String junctionObjectApiName, String parentFieldApiName, String childFieldApiName, Id recordId) {
		String query =
			'SELECT Id, Name, ' +
			childFieldApiName +
			' FROM ' +
			junctionObjectApiName +
			' WHERE ' +
			parentFieldApiName +
			' = \'' +
			recordId +
			'\'' +
			' ORDER BY Name DESC';
		return Database.query(query);
	}

	@AuraEnabled(cacheable=true)
	public static DataWrapper getData(
		String childObjectApiName,
		String junctionObjectApiName,
		String parentFieldApiName,
		String childFieldApiName,
		Id recordId
	) {
		try {
			return new DataWrapper(
				new Map<Id, SObject>(getChildRecords(childObjectApiName)),
				getJunctionRecords(junctionObjectApiName, parentFieldApiName, childFieldApiName, recordId)
			);
		} catch (Exception e) {
			throw new AuraHandledException(e.getMessage());
		}
	}

	@AuraEnabled
	public static void insertRecords(String parentFieldApiName, Id parentId, String childFieldApiName, Id childId, String junctionObjectApiName) {
		Type t = Type.forName(junctionObjectApiName);
		SObject c = (SObject) t.newInstance();
		c.put(parentFieldApiName, parentId);
		c.put(childFieldApiName, childId);
		insert c;
	}

	@AuraEnabled
	public static void deleteRecords(String parentFieldApiName, Id parentId, String childFieldApiName, Id childId, String junctionObjectApiName) {
		String query =
			'SELECT Id FROM ' +
			junctionObjectApiName +
			' WHERE ' +
			parentFieldApiName +
			' = \'' +
			parentId +
			'\'' +
			' AND ' +
			childFieldApiName +
			' = \'' +
			childId +
			'\'';
		delete Database.query(query);
	}

	public class DataWrapper {
		@AuraEnabled
		public Map<Id, SObject> childRecords;
		@AuraEnabled
		public List<SObject> junctionRecords;

		public DataWrapper(Map<Id, SObject> childRecords, List<SObject> junctionRecords) {
			this.childRecords = childRecords;
			this.junctionRecords = junctionRecords;
		}
	}
}