public class fileUpload 
{
	@AuraEnabled(cacheable=true)
    public static List<Opportunity> oppId()
    {
        return [select name,(select title,FileType from CombinedAttachments) from Opportunity];
    }
    
    @AuraEnabled(cacheable=true)
    public static List<ContentDocument> oppAtta(String di)
    {
        list<ContentDocumentLink> cdl=[SELECT ContentDocumentId, LinkedEntityId FROM ContentDocumentLink where LinkedEntityId= :di ];
        list<id> ids=new List<id>();
        for(ContentDocumentLink c:cdl)
        {
            ids.add(c.ContentDocumentId);
        }
        return [select title,FileExtension from ContentDocument where id= :ids];
    }
    @AuraEnabled
    public static id file(String base64,String filename,String parentid)
    {
        ContentVersion cv=new ContentVersion();
        cv.VersionData=EncodingUtil.base64Decode(base64);
        cv.Title=filename;
        cv.PathOnClient=filename;
        insert cv;
        
        Id di = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cv.Id].ContentDocumentId;
        
        ContentDocumentLink cdl=new ContentDocumentLink();
        cdl.ContentDocumentId= di;
        cdl.LinkedEntityId=parentId;
        cdl.ShareType = 'V';
        insert cdl;
        
        return di;
    }
    
    @AuraEnabled
    public static void del(String di)
    {
        delete [select id from ContentDocument where id = :di];
    }
    
    @AuraEnabled
    public static void mail(String to,String di)
    {
        ContentVersion cv=[select id from ContentVersion where ContentDocumentId = :di];
        
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    String[] Address = new String[]{to};
                    mail.setToAddresses(Address);
        			mail.setEntityAttachments(new list<id>{cv.Id});
					mail.setSubject('Attachments');
        			mail.setPlainTextBody('Doc');
                    Messaging.sendEmail(new Messaging.SingleEmailMessage[]{mail});
    }
}