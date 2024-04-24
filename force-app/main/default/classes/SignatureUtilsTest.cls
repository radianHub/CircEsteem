@isTest
public with sharing class SignatureUtilsTest {
    @isTest
    public static void SaveSignatureTest() {

        List<String> data = new List<String>{EncodingUtil.base64Encode(blob.valueOf('test'))};

        Account acc = new Account(Name = 'Test');
        insert acc;

        SignatureUtils.saveSignature(String.valueOf(acc.Id), data);

        system.assertEquals(1, [SELECT count() FROM ContentDocumentLink WHERE LinkedEntityId = :acc.Id]);
        
    }    
}