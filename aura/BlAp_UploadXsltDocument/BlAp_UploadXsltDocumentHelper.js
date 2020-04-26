({
    DEBUG : 'UploadXsltDocumentTemplate',
    MAX_FILE_SIZE: 4350000, //After Base64 Encoding, this is the max file size.
    
    // function is used to intialize attributes and load component.
    doInit : function(component, event, helper) {
        component.set('v.fileSelectedMessage', $A.get("$Label.c.BlAp_SelectFileMessage"));  
        this.initializeVariables(component, event, helper);
    },
    // call the notifier method to show a message on the notification component on the wizard
    showNotification: function(component, message, type) {
        component.find('notifier').showNotification(message, type);
    },
    
    // call the notifier method to clear a message on the notification component on the wizard
    clearNotification: function(component) {
        component.find('notifier').clearNotification();
    },
    
    // Used to initialize variables 
    initializeVariables : function(component, event, helper) {
        debugger;
        component.find("spinner").show();
        //Send LC Host as parameter to VF page so VF page can send message to LC; make it all dynamic
        component.set('v.lcHost', window.location.hostname);
        var lcHost = component.get('v.lcHost') ;
        var frameSrc = '/apex/' + this.setPrefixedString('BlAp_UploadXsltDocumentPage') + '?' + '&lcHost=' + component.get('v.lcHost');
        component.set('v.frameSrc', frameSrc);
        //Add message listener
        window.addEventListener("message", function(event) {
            
            if(component.get("v.savePressed")){
                component.set("v.fileSelectedMessage",'');
                component.set("v.fileSizeMessage",'');
                component.set("v.fileTypeMessage",'');
                component.set("v.savePressed",false);
            }
            
            if(event.data.eventType && atob(event.data.eventType) == 'custom'){
                // Handle the message
                if(atob(event.data.state) == 'LOADED'){
                    //Set vfHost which will be used later to send message
                    component.set('v.vfHost', atob(event.data.vfHost)); //AT-4889 Code Check marx Changes Starts/Ends here
                    component.find("spinner").hide();
                }
                if(atob(event.data.state) == 'uploadFileSelected'){
                    component.set('v.fileSelectedMessage', '');
                }else{
                    component.set('v.fileSelectedMessage', $A.get("$Label.c.BlAp_SelectFileMessage"));  
                }
                // If state is "invalidFileSize"  then size is greater than 4.5 Mb and setting message in attribute.
                if(atob(event.data.state) == 'invalidFileSize'){
                    component.set('v.fileSizeMessage', $A.get("$Label.c.BlAp_FileSizeMessage"));
                }
                // If state is "invalidFileType"  then file type is not xslt and setting  message in attribute.
                if(atob(event.data.state) == 'invalidFileType'){
                    component.set('v.fileTypeMessage', $A.get("$Label.c.BlAp_FileTypeXsltMessage"));
                }
                // If state is "fileUploadprocessed" the file success fully uploaded.
                if(atob(event.data.state) == 'fileUploadprocessed'){
                   /*AT-4889 Code Check marx Changes Starts here*/
                    //var uiMessage = component.find('uiMessage');
                    var returnMessages  = atob(event.data.message);
                    //Disable Upload button until file is selected again
                    //component.find('saveButton').set('v.disabled', true);
                   /* $A.createComponents([
                        ["markup://ui:message",{
                            "body" : atob(event.data.message),
                            "severity" : atob(event.data.messageType),
                        }]
                    ],
                                        function(components, status, errorMessage){
                                            
                                            if (status === "SUCCESS") {
                                                var message = components[0];
                                                // set the body of the ui:message to be the ui:outputText
                                                component.find('uiMessage').set("v.body", message);
                                            }
                                            
                                            else if (status === "INCOMPLETE") {
                                                console.log("No response from server or client is offline.")
                                                // Show offline error
                                            }
                                                else if (status === "ERROR") {
                                                    console.log("Error: " + errorMessage);
                                                    // Show error message
                                                }
                                        }
                                       );*/   
                   /*AT-4889 Code Check marx Changes Ends here*/
                    if(returnMessages == $A.get("$Label.c.BlAp_FileUploadSuccesFullyMessage")){
                        debugger;
                    	component.set("v.isSetTab", false);  //AT-3032           
                        var compEvent = component.getEvent("refreshEvent");
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            message: returnMessages,
                            duration:' 3000',
                            key: 'info_alt',
                            type: 'success',
                            mode: 'pester',
                        });
                        toastEvent.fire();
                        component.set("v.isSetTab", true);
                        component.set("v.isActive", false);
                }else{
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        message: returnMessages,
                        duration:' 3000',
                        key: 'info_alt',
                        type: 'error',
                        mode: 'pester',
                    });
                    toastEvent.fire();
                }
            }
          }
            
        }, false);
        
    },
    doCancel : function(component, event, helper) {
        component.set("v.isActive", false) ;
    } , 
    doSave : function(component, event, helper) {
        debugger;
        var isValidate = this.validatePage(component, event, helper);
        if(isValidate){
            //Clear UI message before trying for file upload again
            //component.find('uiMessage').set("v.body",[]); //AT-4889 Code Check marx Changes Starts/Ends here
            var fileName  = component.get("v.importFileName"); 
            //Prepare message in the format required in VF page
            var message = {
                "uploadFile" : true,
                "fileName": fileName
            } ;
            //Send message to VF
            helper.sendMessage(component, helper, message);
        }
    } ,
    // Method is used to apply all mandatory validation on page.
    validatePage: function(component, event, helper) {
        var errorMessages = [];
        var isValid= true;
        if(component.get("v.importFileName")){
            var isTemplateNotExist = this.checkValueExist(component.get("v.importFileName") , component.get("v.xsltDocumentList"))
            if(!isTemplateNotExist){
                errorMessages.push($A.get("$Label.c.BlAp_XsltDocumentNameAlreadyExist"));
                this.showNotification(component, errorMessages,$A.get("$Label.c.GlAp_NotificationTypeError"));
                isValid = false;
            }else{
                if(component.get("v.fileSelectedMessage")){
                    errorMessages.push(component.get("v.fileSelectedMessage"));
                    component.set("v.savePressed",true);
                    this.showNotification(component, errorMessages,$A.get("$Label.c.GlAp_NotificationTypeError"));
                      
                    isValid = false; 
                }
                if(component.get("v.fileSizeMessage")){
                    errorMessages.push(component.get("v.fileSizeMessage"));
                    component.set("v.savePressed",true);
                    this.showNotification(component, errorMessages,$A.get("$Label.c.GlAp_NotificationTypeError"));
                    
                    isValid = false;
                }
                if(component.get("v.fileTypeMessage")){
                    errorMessages.push(component.get("v.fileTypeMessage"));
                    component.set("v.savePressed",true);
                    this.showNotification(component, errorMessages,$A.get("$Label.c.GlAp_NotificationTypeError"));
                    isValid = false;
                }
            }
        }else{
            errorMessages.push($A.get("$Label.c.BlAp_FileNameMustBeProvided"));
            this.showNotification(component, errorMessages,$A.get("$Label.c.GlAp_NotificationTypeError"));
            isValid = false;
        }
        
        return isValid;  
    },
    checkValueExist: function(strValue, arr) {
        var status = true;
        for(var i=0; i<arr.length; i++){
            var name = arr[i].replace(/\.[^/.]+$/, "");
            if(name == strValue){
                status = false;
                break;
            }
        }
        return status;
    },
    sendMessage: function(component, helper, message){
        //Send message to VF
        message.origin = window.location.hostname;
        var vfWindow = component.find("vfFrame").getElement().contentWindow;
        vfWindow.postMessage(message, component.get("v.vfHost"));
    } 
})