public with sharing class ProgramService {
    
    public static Program__c getProgramFromSession(String sessionId) {
        return [
            SELECT Id, Payment_Frequency__c, (SELECT Id, Start_Date__c, End_Date__c FROM Program_Sessions__r WHERE Id = :sessionId)
            FROM Program__c
            WHERE Id IN (SELECT Program__c FROM Program_Session__c WHERE Id = :sessionId)
            LIMIT 1
        ];
    }
}