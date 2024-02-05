public with sharing class ContactService {
    private static Id childRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName()
		.get('Child')
		.getRecordTypeId();

    
    @AuraEnabled(cacheable=true)
    public static boolean needsNewReleaseFormSubmission() {
        Id userId = UserInfo.getUserId();
        User currentUser = [Select Id, ContactId from User where Id = :userId];
        Contact contact = [select Id, AccountId from Contact where Id = :currentUser.ContactId];
        List<Contact> householdContacts = [select Id from Contact where AccountId = :contact.AccountId and Form_is_Active__c = false and RecordTypeId = :childRecordTypeId];

        Boolean inactiveForm = false;

        if(householdContacts.size() > 0) {
            inactiveForm = true;
        }

        System.debug(inactiveForm);

        return inactiveForm;
    }
}