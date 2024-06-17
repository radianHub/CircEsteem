public with sharing class UnpaidProgramBannerController {

    @AuraEnabled(cacheable=true)
    public static List<Cart__c> getUserProgramCart(Id userId) {
        try {
            return CartService.getUserProgramCart(userId);
        }
        catch (Exception ex) {
            throw new AuraHandledException(ex.getMessage());
        }
    }
}