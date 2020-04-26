({ 
    MAX_FILE_SIZE: 4500000, //Max file size 4.5 MB      
    doInit : function(component, event, helper) {         
      let params = {            
        };        
        helper.callServer(component, 'c.activeNotifyUserList',
                        function(response) {
                            component.set('v.userNotifyList', response);
                        },
                        params); 
    },
    
    handleFilesChange: function(component, event, helper) {
      
        var fileInput = component.find("file").getElement();        
    	var file = fileInput.files[0]; 
        if(file != undefined){ 
        	component.set("v.fileName", file.name);
            component.set("v.fileDetails",file);
        }
    },
    
    doCancel : function(component, event, helper) { 
        // Set all variables to default values 
        component.set("v.isActive", false);  
        component.set("v.importJobName","");
        component.set("v.isUserNotification", false);
        component.set("v.fileName","");
        component.set("v.userNotify","-- None --");
        component.set("v.showNewReadingImport",false);         
    },

	doSave : function(component, event, helper) {       
        var fileInput = component.find("file").getElement();
        var file = fileInput.files[0]; 
       	      
        if(file == undefined){							
            file = component.get("v.fileDetails");
            if(!file || file == undefined){						
                this.showNotification(component, [$A.get("$Label.c.LoAp_SelectImportFile")],$A.get('$Label.c.GlAp_NotificationTypeError'));
                return false; 
            }
        }
        // check the selected file size, if select file size greter then MAX_FILE_SIZE,         
        if (file.size > this.MAX_FILE_SIZE) {
            // Sequence Spacing should be greater than or equal to 1
            this.showNotification(component, [$A.get("$Label.c.LoAp_NRIFileExceed")],$A.get('$Label.c.GlAp_NotificationTypeError'));
            return false; 
        } 
        var filename = file.name;
        if( filename.lastIndexOf('.xml') < 0 || (filename.lastIndexOf('.xml') > 0 && filename.substring(filename.lastIndexOf('.xml'), filename.length) != '.xml')){
            this.showNotification(component, [$A.get("$Label.c.CuAp_XMLFileTypeOnly")],$A.get('$Label.c.GlAp_NotificationTypeError'));
            return false; 
        }
        var action = component.get('c.saveDetails');        
        var importJobName = component.get('v.importJobName');
        var isUserNotification = component.get('v.isUserNotification');
        var userNotify = component.get('v.userNotify');
        var self = this;
        
        // create a FileReader object 
        var objFileReader = new FileReader();       
        
        // set onload function of FileReader object
        objFileReader.onload = function() { 
            var fileContents = objFileReader.result;
            var base64 = 'base64,';
            var dataStart = fileContents.indexOf(base64) + base64.length;
            fileContents = fileContents.substring(dataStart);
            action.setParams({
                'importJobName' : importJobName,
                'isUserNotification' : isUserNotification,
                'userNotify' : userNotify,               
                'fileName' : file.name,                
                'base64Data' : fileContents,
                'contentType' : file.type                           
            });
            action.setCallback(self, function(response) {
                var state = response.getState();                
                if (state === 'SUCCESS') {
                     console.log('successfully upload.');  
                }                
            });
            $A.enqueueAction(action);  
            
        };
 
        objFileReader.readAsDataURL(file);
        this.doCancel(component);
    },        
    
   // call the notification component method to show a notification
    showNotification: function(component, message, type) {
    	component.find('notification').showNotification(message, type);
    }, 
    
    
})