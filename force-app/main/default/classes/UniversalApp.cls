// RadianHub - Developer p.hart
// Apex class for a LWC based universal application dependent on  custom metadata and object field sets

public with sharing class UniversalApp {
	public final static String NOT_FOUND = 'Application \'DeveloperName\' not found in Custom Metadata.';
	public final static String NO_SECTION = 'Application sections were not found in Custom Metadata.';
	public final static String NO_FIELDSETS = 'Field sets were not found for object: {0}.';
	public final static String NULL_FIELDSETS = 'The field set(s) were not found for the following Universal App Sections: {0}.';
	public final static String NULL_FIELDSET = 'The field set {0} was not found on {1}.';

	public static Universal_App__mdt[] apps;
	public static Universal_App_Section__mdt[] sects;

	// Method   - queryApps
	// Descr.   - Segregated (for testing) mdt query which updates the class static variable "apps"
	// Input    - String DeveloperName of CustomMetadata 'Universal App'
	private static void queryApps(String appDevName) {
		apps = [
			SELECT
				Id,
				CSS__c,
				DeveloperName,
				Logo_URL__c,
				MasterLabel,
				Object__c,
				Post_Submit_Fields__c,
				Page_Redirect__c,
				Object_with_Boolean__c,
				Boolean_Field__c,
				Page_Redirect_if_True__c,
				Page_Redirect_if_False__c,
				vfPageRedirect__c
			FROM Universal_App__mdt
			WHERE DeveloperName = :appDevName
		];
	}

	// Method   - querySects
	// Descr.   - Segregated (for testing) mdt query which updates the class static variable "sects"
	// Input    - Id of 'Universal App'
	private static void querySects(String appId) {
		sects = [
			SELECT
				Id,
				DeveloperName,
				MasterLabel,
				Order__c,
				Page__c,
				Section_Body__c,
				Section_Field_Set__c,
				Section_Field_Columns__c,
				Section_Field_Flow__c,
				Section_Header__c,
				conditionalRequire__c,
				conditionalRender__c,
				DisplayByDefault__c,
				AddChildButtonLabel__c,
				ChildFieldSet__c,
				ChildObject__c,
				ChildObjectRecordLimit__c,
				ChildTableTitle__c,
				ParentField__c,
				isEnableChildRecords__c,
				Include_Signature__c
			FROM Universal_App_Section__mdt
			WHERE Universal_App__c = :appId
		];
	}

	/**
	 * @description : QUERIES FOR A LIST OF FIELD SETTINGS TO BE USED AS ALTERNATIVE LABELS.
	 * @author Zachary Csotya | 08/31/2023
	 * @return List<Universal_App_Field_Setting__mdt>
	 **/
	private static List<Universal_App_Field_Setting__mdt> queryFieldSettings() {
		return [
			SELECT Id, DeveloperName, MasterLabel, Expected_Field_Label__c, Field_Name__c, Universal_App_Section__c
			FROM Universal_App_Field_Setting__mdt
		];
	}

	/**
	 * @description : Query all fields in a sObject and return the results.
	 * @author Zachary Csotya | 06/28/2022
	 * @param Id rId
	 * @param String objName
	 * @return sObject
	 **/
	public static sObject queryRecord(Id rId, String objName) {
		Map<String, Schema.SObjectField> fields = ((SObject) Type.forName('Schema', objName)?.newInstance())
			?.getSObjectType()
			?.getDescribe()
			?.fields
			?.getMap();

		String expr = ' ';
		SObject obj = null;
		for (Integer i = 0; i < fields.values().size() - 1; i++) {
			expr += fields.values()[i] + ', ';
		}
		expr += fields.values()[fields.values().size() - 1];
		String qry = 'SELECT' + expr + ' FROM ' + objName + ' WHERE Id = ' + '\'' + rId + '\'';
		obj = Database.query(qry);

		return obj;
	}

	/**
	 * @description : Query all fields in a sObject and return the results.
	 * @author Zachary Csotya | 08/02/2022
	 * @param String fieldName
	 * @param String objName
	 * @param String recordId
	 * @return sObject
	 **/
	@AuraEnabled
	public static sObject queryForBoolean(String fieldName, String objName, String recordId) {
		List<SObject> obj = null;
		String qry = 'SELECT ' + fieldName + ' FROM ' + objName + ' WHERE Id = ' + '\'' + recordId + '\'';
		obj = Database.query(qry);

		if (obj.size() == 1) {
			return obj[0];
		} else {
			return null;
		}
	}

	// Method   - retrieveApp
	// Descr.   - Aura enabled (LWC c-univ-app) method for returning map of Universal Application and field sets
	// Input    - String DeveloperName of CustomMetadata 'Universal App'
	// Output   - Map<String, Object> {'data' -> [{api -> fieldAPI__c, options...}, ...], 'error' -> 'String'}
	@AuraEnabled(cacheable=true)
	public static Map<String, Object> retrieveApp(String appDevName, Id recordId) {
		Map<String, Object> ret = new Map<String, Object>();

		try {
			// Query for application, prepopulate in testing
			if (apps == null) {
				queryApps(appDevName);
			}

			if (apps == null || apps.size() != 1) {
				ret.put('error', NOT_FOUND);
			} else {
				Universal_App__mdt application = apps[0];

				// Query for sections, prepopulate in testing
				if (sects == null) {
					querySects(application.Id);
				}

				if (sects == null || sects.size() == 0) {
					ret.put('error', NO_SECTION);
				} else {
					Map<String, List<Object>> fieldsetmap = new Map<String, List<Object>>();

					Map<String, Schema.FieldSet> objectFieldSetMap = ((SObject) Type.forName(
								'Schema',
								application.Object__c
							)
							?.newInstance())
						?.getSObjectType()
						?.getDescribe()
						?.fieldSets
						?.getMap();

					if (objectFieldSetMap == null) {
						ret.put('error', String.format(NO_FIELDSETS, new List<Object>{ application.Object__c }));
					} else {
						Map<String, Set<String>> mapfieldset = new Map<String, Set<String>>();
						Map<String, Map<String, String>> mapFieldSetting = new Map<String, Map<String, String>>();

						for (Universal_App_Section__mdt s : sects) {
							String sfs = s.Section_Field_Set__c;
							if (String.isNotBlank(sfs)) {
								for (Universal_App_Field_Setting__mdt fieldSetting : queryFieldSettings()) {
									if (fieldSetting.Universal_App_Section__c == s.Id) {
										if (mapFieldSetting.containsKey(sfs)) {
											if (!mapFieldSetting.get(sfs).containsKey(fieldSetting.Field_Name__c)) {
												mapFieldSetting.get(sfs)
													.put(
														fieldSetting.Field_Name__c,
														fieldSetting.Expected_Field_Label__c
													);
											}
										} else {
											mapFieldSetting.put(
												sfs,
												new Map<String, String>{
													fieldSetting.Field_Name__c => fieldSetting.Expected_Field_Label__c
												}
											);
										}
									}
								}
								if (mapfieldset.containsKey(sfs)) {
									mapfieldset.get(sfs).add(s.DeveloperName);
								} else {
									mapfieldset.put(sfs, new Set<String>{ s.DeveloperName });
								}
							}
						}

						Set<String> nullFieldSets = new Set<String>();
						sObject fieldValues = null;

						if (recordId != null) {
							fieldValues = queryRecord(recordId, application.Object__c);
						}

						for (String fs : mapfieldset.keySet()) {
							Schema.FieldSet objFieldSet = objectFieldSetMap.get(fs);
							if (objFieldSet != null) {
								List<Schema.FieldSetMember> fields = objFieldSet.getFields();
								List<Object> fieldMembers = new List<Object>();
								for (Schema.FieldSetMember member : fields) {
									String altLabel;
									Boolean hasAltLabel = false;

									if (mapFieldSetting?.containsKey(fs)) {
										if (mapFieldSetting.get(fs)?.containsKey(member.getFieldPath())) {
											hasAltLabel = true;
											altLabel = mapFieldSetting.get(fs).get(member.getFieldPath());
										}
									}

									Map<String, Object> fieldMember = new Map<String, Object>{
										'api' => member.getFieldPath(),
										'req' => (member.getDBRequired() || member.getRequired()),
										'label' => member.getLabel(),
										'type' => member.getType().name(),
										'hasAltLabel' => hasAltLabel,
										'altLabel' => altLabel,
										'isBool' => member.getType().name() == 'BOOLEAN' ? true : false
									};
									if (recordId != null) {
										fieldMember.put('value', fieldValues.get(member.getFieldPath()));
									}
									fieldMembers.add(fieldMember);
								}
								fieldsetmap.put(fs, fieldMembers);
							} else {
								nullFieldSets.addAll(new List<String>(mapfieldset.get(fs)));
							}
						}

						if (nullFieldSets.size() > 0) {
							ret.put('error', String.format(NULL_FIELDSETS, new List<Object>{ nullFieldSets }));
						}

						ret.put(
							'data',
							new Map<String, Object>{
								'application' => application,
								'sections' => sects,
								'fieldsetmap' => fieldsetmap
							}
						);
					}
				}
			}
		} catch (Exception e) {
			ret.put('error', e.getTypeName() + ' | ' + e.getMessage() + ' | ' + e.getStackTraceString());
		}

		return ret;
	}

	@AuraEnabled
	public static Map<String, Object> submitApp(SObject sObj, String form, String recordIds) {
		Map<String, Object> ret = new Map<String, Object>();

		try {
			switch on form {
				when 'General_Release_Form' {
					List<Form__c> generalReleasesToInsert = new List<Form__c>();
					List<Id> childIds = new List<Id>();
					List<String> childIdStrings = recordIds.split(';');

					for (String childIdString : childIdStrings) {
						Id childId = (Id) childIdString.trim();
						childIds.add(childId);
					}

					Form__c releaseForm = (Form__c) sObj;

					for (Id childId : childIds) {
						Form__c childReleaseForm = releaseForm.clone(false, true, true);
						childReleaseForm.Parent_Guardian_Email__c = UserInfo.getUserEmail();
						childReleaseForm.RecordTypeId = Fetch.recordTypeIdFromDeveloperName(
							Form__c.SObjectType,
							'General_Release'
						);
						childReleaseForm.Child__c = childId;

						generalReleasesToInsert.add(childReleaseForm);
					}

					upsert generalReleasesToInsert;
					ret.put('data', generalReleasesToInsert);
					// upsert newForm;
					// ret.put('data', newForm.Id);
				}
				when 'General_Release_Form_Bday_and_Workshop' {
					Form__c newForm = (Form__c) sObj;

					newForm.RecordTypeId = Fetch.recordTypeIdFromDeveloperName(
						Form__c.SObjectType,
						'Birthday_Workshop'
					);

					upsert newForm;
					ret.put('data', newForm.Id);
				}
				when else {
					upsert sObj;
					ret.put('data', sObj.Id);
				}
			}
		} catch (Exception e) {
			ret.put('error', e.getTypeName() + ' | ' + e.getMessage() + ' | ' + e.getStackTraceString());
		}

		return ret;
	}

	@AuraEnabled
	public static void submitChildObjects(List<childRecordsWrapper> childObjs, Id parentId) {
		try {
			List<SObject> records = new List<SObject>();
			for (childRecordsWrapper wrapper : childObjs) {
				for (SObject record : wrapper.records) {
					record.put(wrapper.parentField, parentId);
				}
				records.addAll(wrapper.records);
			}
			insert records;
		} catch (Exception e) {
			throw new AuraHandledException(e.getMessage());
		}
	}

	@AuraEnabled
	public static Map<String, Object> getChildObjectFields(String ObjectName, String FieldSetName) {
		Map<String, Object> ret = new Map<String, Object>();

		Map<String, List<Object>> fieldsetmap = new Map<String, List<Object>>();

		Schema.FieldSet objFieldSet = ((SObject) Type.forName('Schema', ObjectName)?.newInstance())
			?.getSObjectType()
			?.getDescribe()
			?.fieldSets
			?.getMap()
			?.get(FieldSetName);

		if (objFieldSet == null) {
			ret.put('error', String.format(NULL_FIELDSET, new List<Object>{ FieldSetName, ObjectName }));
		} else {
			Map<String, Set<String>> mapfieldset = new Map<String, Set<String>>();
			Map<String, Map<String, String>> mapFieldSetting = new Map<String, Map<String, String>>();

			Set<String> nullFieldSets = new Set<String>();
			sObject fieldValues = null;

			List<Schema.FieldSetMember> fields = objFieldSet.getFields();
			List<Object> fieldMembers = new List<Object>();
			for (Schema.FieldSetMember member : fields) {
				String altLabel;
				Boolean hasAltLabel = false;

				if (mapFieldSetting?.containsKey(FieldSetName)) {
					if (mapFieldSetting.get(FieldSetName)?.containsKey(member.getFieldPath())) {
						hasAltLabel = true;
						altLabel = mapFieldSetting.get(FieldSetName).get(member.getFieldPath());
					}
				}

				Map<String, Object> fieldMember = new Map<String, Object>{
					'api' => member.getFieldPath(),
					'req' => (member.getDBRequired() || member.getRequired()),
					'label' => member.getLabel(),
					'type' => member.getType().name(),
					'hasAltLabel' => hasAltLabel,
					'altLabel' => altLabel
				};

				fieldMembers.add(fieldMember);
			}
			//fieldsetmap.put(FieldSetName, fieldMembers);

			ret.put('fielddata', fieldMembers);
		}

		return ret;
	}

	public class childRecordsWrapper {
		@AuraEnabled
		public String objectName { get; set; }
		@AuraEnabled
		public String parentField { get; set; }
		@AuraEnabled
		public List<SObject> records { get; set; }
	}
}