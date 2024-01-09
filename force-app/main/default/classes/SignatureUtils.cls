/**
 * @Class Name     : SignatureUtils
 * @Class Purpose  : Provide Utilities for the Signature Lwc to save signature images.
 * @Author         : Zachary Csotya
 * @Developed On   : 12/22/2022
 * @Last Modified  : 05/25/2023
**/
public without sharing class SignatureUtils {

    /**
    * @description : Called by Signature Lwc to save a signature image.
    * @author Zachary Csotya | 12/22/2022 
    * @param String relatedId 
    * @param String data 
    **/
    @AuraEnabled
    public static void saveSignature(String relatedId, List<String> data) {
        // No Id, No Save
        if(String.isBlank(relatedId)) {
            return;
        } else {
            saveSfFile(relatedId, data);
        }
    }


    /**
    * @description : Saves signature image data as a SF File.
    * @author Zachary Csotya | 12/22/2022 
    * @param string relatedId 
    * @param string data 
    **/
    private static void saveSfFile(string relatedId, List<String> data) {

        List<ContentVersion> cvList = new List<ContentVersion>();
        List<ContentDocumentLink> cdlList = new List<ContentDocumentLink>();
        
        for(String d : data) {
            ContentVersion cv = new ContentVersion();
            cv.PathOnClient = 'Signed-'+System.now().getTime()+'.png';
            cv.Title = 'Signed-'+System.now().getTime()+'.png';
            cv.VersionData = EncodingUtil.base64Decode(d);
            cvList.add(cv);
        }
        insert cvList;

        for (ContentVersion cv : cvList) {
            ContentDocumentLink cdl = new ContentDocumentLink();
            cdl.ContentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id=:cv.Id].ContentDocumentId;
            cdl.LinkedEntityId = relatedId;
            cdl.ShareType = 'V';
            cdlList.add(cdl);   
        }
        insert cdlList;

        system.debug('success: saved signature');
    }
}