public with sharing class CreditService {
    public static List<Credit__c> getCredits(Id contactId) {
        Contact con = [
            SELECT Id, AccountId
            FROM Contact
            WHERE Id = :contactId
        ];

        return [
            SELECT Type__c, Credit_Percentage__c, Credit_Amount__c, Credits_Available__c
            FROM Credit__c
            WHERE Household__c = :con.AccountId AND (Credits_Available__c > 0 OR Credits_Available__c = NULL)
        ];
    }

    public static void createAppliedCredits(Id cartId, String appliedCreditsJson) {
        List<AppliedCredit> appCredits = (List<AppliedCredit>) System.JSON.deserialize(appliedCreditsJson, List<AppliedCredit>.class);
        System.debug(appCredits);

        List<Credit__c> updateCredits = new List<Credit__c>();
        List<Applied_Credit__c> insertAppliedCredits = new List<Applied_Credit__c>();
        for (AppliedCredit appCredit : appCredits) {
            if (appCredit.type == 'Percentage') {
                updateCredits.add(new Credit__c(
                    Id = appCredit.id,
                    Credit_Amount__c = appCredit.value
                ));
            }

            insertAppliedCredits.add(new Applied_Credit__c(
                Cart__c = cartId,
                Credit__c = appCredit.id,
                Applied_Amount__c = appCredit.value
            ));
        }
        if (updateCredits.size() > 0) {
            update updateCredits;
        }
        if (insertAppliedCredits.size() > 0) {
            insert insertAppliedCredits; 
        }
    }

    public class AppliedCredit {
        public String id;
        public Decimal value;
        public String type;
    }
}