({
    //Initialize lightning constructor.
    doInit : function(component, event, helper) {
        let params ={
            "recordId": component.get('v.recordId')
        };
        //component.find('spinner').show();
        helper.callServer(component,'c.getAWSS3CorrespondencePDFDocument',
                          function(response) {
                              var signedUrl;
                              signedUrl = response ;
                              component.set('v.signedUrl',signedUrl);
                              //component.find('spinner').hide();
                          },
                          params);
    },
    //View S3 Document
    ViewDocument:function(component, event, helper) {
        component.find('spinner').show();
        if(component.get('v.signedUrl')) {
            var urlEvent = $A.get("e.force:navigateToURL");
            urlEvent.setParams({
                "url": component.get('v.signedUrl')
            });
            urlEvent.fire();
        }
        component.find('spinner').hide();
    },
    
})