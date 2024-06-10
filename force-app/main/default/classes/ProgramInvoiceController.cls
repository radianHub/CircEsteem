public with sharing class ProgramInvoiceController {

    @AuraEnabled(cacheable=true)
    public static Cart__c getCart(Id cartId) {
        try {
			return CartService.getCart(cartId);
		} catch (Exception e) {
			throw new AuraHandledException(e.getMessage());
		} 
    }

    @AuraEnabled
    public static Cart__c createCartWithProducts(Id sessionId, Id contactId){
        try {
            return CartService.createCartWithProducts(sessionId, contactId);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled(cacheable=true)
    public static Program__c getProgram(String sessionId) {
        try {
            return ProgramService.getProgramFromSession(sessionId);
        }
        catch (Exception ex) {
            throw new AuraHandledException(ex.getMessage());
        }
    }
}