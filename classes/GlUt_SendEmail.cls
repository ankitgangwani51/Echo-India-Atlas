/******************************************************************************************************
@author         Echo: Vivek Sethi
@date           24 April 2019  
@description    Common Utility to send emails
* Send Email with plain text body.
* Send Email with html body.
* Send Email Using Template.

For Ex-:
Id userId = GlUt_AccountUtilities.getContactByCustomSetting();  
//use the new util class to send an email
GlUt_SendEmail emailUtil = new GlUt_SendEmail();
emailUtil.targetObjectId('0031v00001mgciLAAQ' );  //Required if using a template, optional otherwise. The ID of the contact, lead, or user...
emailUtil.TemplateName(Label.CuAp_MeasuredLocWelcomeLetterTemplate);
emailUtil.WhatId('0011v00001oW2zcAAC');   //Account Id for Ex.
emailUtil.senderDisplayName('test');   
emailUtil.SaveAsActivity(true);
emailUtil.sendEmail();

/**************************************************************************************************************************/

public class GlUt_SendEmail {
    private Messaging.SingleEmailMessage singleEmailMessage;
    //optional parameters set to default   
    private List<String> toAddresses;
    private Id templateId; 
    private Id targetObjectId;
    private Id whatId;    
    private Boolean saveAsActivity = false;
    private String subject = '';
    private String htmlBody = ''; 
    private Boolean useSignature = false;
    private List<Messaging.EmailFileAttachment> fileAttachments = null;
    private String senderDisplayName  = UserInfo.getFirstName()+' '+ UserInfo.getLastName();
    private String replyTo  =  '';
    private String plainTextBody = '';
    
    public GlUt_SendEmail ToAddress(List<String> addresses) {
        this.toAddresses = addresses;
        return this;
    }
    
    public GlUt_SendEmail TemplateName(String val) {
        List<EmailTemplate> emailTemplateList = [SELECT Id 
                                                 FROM EmailTemplate 
                                                 WHERE DeveloperName =: val]; 
        
        if(emailTemplateList != null && !emailTemplateList.isEmpty())
            this.templateId = emailTemplateList[0].Id;
        
        return this;
    }
    
    public GlUt_SendEmail TargetObjectId(Id val) {
        this.targetObjectId = val;
        return this;
    }
    
    public GlUt_SendEmail WhatId(Id val) {
        this.whatId = val;
        return this;
    }
    
    public GlUt_SendEmail SaveAsActivity(Boolean val) {
        this.saveAsActivity = val;
        return this;
    }
    
    public GlUt_SendEmail senderDisplayName(String val) {
        senderDisplayName = val;
        return this;
    }
    
    public GlUt_SendEmail subject(String val) {
        subject = val;
        return this;
    }
    
    public GlUt_SendEmail htmlBody(String val) {
        htmlBody = val;
        return this;
    }
    
    public GlUt_SendEmail useSignature(Boolean bool) {
        useSignature = bool;
        return this;
    }
    
    public GlUt_SendEmail replyTo(String val) {
        replyTo = val;
        return this;
    }
    
    public GlUt_SendEmail plainTextBody(String val) {
        plainTextBody = val;
        return this;
    }
    
    public GlUt_SendEmail fileAttachments(List<Messaging.Emailfileattachment> val) {
        fileAttachments = val;
        return this;
    }
    
    /******************************************************************************
    @author         Echo: Vivek Sethi
    @date           24 April 2019
    @param          None
    @return     	None
    @description    Private Method used to build SingleEmailMessage instance 
                    called from sendEmail()  
    *******************************************************************************/
    
    private GlUt_SendEmail build() {
        singleEmailMessage = new Messaging.SingleEmailMessage();
        
        if(this.toAddresses != null && !this.toAddresses.isEmpty())
            singleEmailMessage.setToAddresses(this.toAddresses);
        
        singleEmailMessage.setSenderDisplayName(this.senderDisplayName);
        
        if(string.isNotBlank(this.subject))
            singleEmailMessage.setSubject(this.subject);
        
        if(string.isNotBlank(this.htmlBody))
            singleEmailMessage.setHtmlBody(this.htmlBody);
        
        if(this.useSignature == true)
            singleEmailMessage.setUseSignature(this.useSignature);
        
        if(string.isNotBlank(this.replyTo))
            singleEmailMessage.setReplyTo(this.replyTo);
            
        if(string.isNotBlank(this.plainTextBody))
            singleEmailMessage.setPlainTextBody(this.plainTextBody);
        
        if(this.fileAttachments != null)
            singleEmailMessage.setFileAttachments(this.fileAttachments);
        
        if(this.targetObjectId != null)
            singleEmailMessage.setTargetObjectId(this.targetObjectId);
        
        if(this.saveAsActivity != null)
            singleEmailMessage.setSaveAsActivity(this.saveAsActivity);
        
        if(this.templateId != null)
            singleEmailMessage.setTemplateId(this.templateId);
        
        if(this.whatId != null)
            singleEmailMessage.setWhatId(this.whatId);
        
        return this;
    }
    
    /******************************************************************************
    @author         Echo: Vivek Sethi
    @date           24 April 2019
    @param          None
    @return     	None
    @description    Main Method  used to send an emails    
    *******************************************************************************/
    //send the email message
    public void sendEmail() {
        try {
            //call build first to create the email message object
            build();
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { singleEmailMessage });
        } catch (Exception ex) {
           
        }                
    }
}