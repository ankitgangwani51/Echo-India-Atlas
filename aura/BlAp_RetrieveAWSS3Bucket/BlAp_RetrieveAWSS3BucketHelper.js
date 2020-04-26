({
    doInit : function(component, event, helper) {           
        helper.callServer(component,'c.retrieveTemplateHeaderPdfPropDetails',
                          function(response){
                              component.set("v.pdfTemplateS3BucketFieldList", response);
                          },
                          null);
        
        helper.callServer(component,'c.retrieveTemplateHeaderXsltPropDetails',
                          function(response){
                              component.set("v.xsltDocumentS3BucketFieldList", response);                         
                          },
                          null);
        
        helper.callServer(component,'c.getAWSS3PdfTemplates',
                          function(response){
                              console.log('getAWSS3XsltTemplates => ' + JSON.stringify(response)) ;
							  var pdfTemplateArr ;
                              var pdfTemplateTransformedArr = [] ;
							  pdfTemplateArr = response ;
							  var pdfFileNameList = [] ;
							  for(var i = 0; i < pdfTemplateArr.length; i++) {
								  var tempFileName = pdfTemplateArr[i].transformFieldMap.AWSS3PDFBUCKET.TemplateName__c ;
								  if(tempFileName.lastIndexOf('/') != -1) {
										if(tempFileName.lastIndexOf('.') != -1) {
											var fileName = tempFileName.substring(tempFileName.lastIndexOf('/') + 1, tempFileName.length) ;
											pdfFileNameList.push(fileName) ;
											pdfTemplateArr[i].transformFieldMap.AWSS3PDFBUCKET.TemplateName__c = fileName ;
                                            pdfTemplateTransformedArr.push(pdfTemplateArr[i]) ;
										}
                                  } else {
                                      pdfTemplateTransformedArr.push(pdfTemplateArr[i]) ;
                                      pdfFileNameList.push(pdfTemplateArr[i].transformFieldMap.AWSS3PDFBUCKET.TemplateName__c) ;
                                  }
							  }
                              console.log('pdfFileNameList=> ' + pdfFileNameList) ;
                              component.set("v.pdfTemplateS3BucketObjectList", pdfTemplateTransformedArr);
                              component.set("v.pdfTemplateNameList", pdfFileNameList) ;
                          },
                          null);
        
        helper.callServer(component,'c.getAWSS3XsltTemplates',
                          function(response){
                              console.log('getAWSS3XsltTemplates => ' + JSON.stringify(response)) ;
                              var xsltTemplateArr ;
                              var xsltTemplateTransformedArr = [] ;
							  xsltTemplateArr = response ;
							  var xsltFileNameList = [] ;
							  for(var i = 0; i < xsltTemplateArr.length; i++) {
								  var tempFileName = xsltTemplateArr[i].transformFieldMap.AWSS3XSLTBUCKET.TemplateName__c ;
								  if(tempFileName.lastIndexOf('/') != -1) {
										if(tempFileName.lastIndexOf('.') != -1) {
											var fileName = tempFileName.substring(tempFileName.lastIndexOf('/') + 1, tempFileName.lastIndexOf('.')) ;
											xsltFileNameList.push(fileName) ;
											xsltTemplateArr[i].transformFieldMap.AWSS3XSLTBUCKET.TemplateName__c = fileName ;
                                            xsltTemplateTransformedArr.push(xsltTemplateArr[i]) ;
										}
                                  } else {
                                      xsltFileNameList.push(xsltTemplateArr[i].transformFieldMap.AWSS3XSLTBUCKET.TemplateName__c) ;
                                      xsltTemplateTransformedArr.push(xsltTemplateArr[i]) ;
                                  }
							  }
                              console.log('xsltFileNameList=> ' + xsltFileNameList) ;
                              component.set("v.xsltDocumentS3BucketObjectList", xsltTemplateTransformedArr);
                              component.set("v.xsltDocumentNameList", xsltFileNameList) ;
                          },
                          null);
                          
    }, 
    
    clearAll: function(component, event) {		// this method set all tabs to hide and inactive
        var getAllLI = document.getElementsByClassName("customClassForTab");
        var getAllDiv = document.getElementsByClassName("customClassForTabData");
        for (var i = 0; i < getAllLI.length; i++) {
            getAllLI[i].className = "slds-tabs--scoped__item slds-text-title--caps customClassForTab";
            getAllDiv[i].className = "slds-tabs--scoped__content slds-hide customClassForTabData";
        }
    },
    
    handleRowSelectEvent: function(component, event, helper) {
        var sRowId = event.getParam('RowId');
        var componentId;
        if(component.get("v.selectedTabName") == $A.get('$Label.c.XSLT_Documents')) {
            var xsltDocumentList = component.get('v.xsltDocumentS3BucketObjectList');
            for(var i = 0; i < xsltDocumentList.length; i++){
                if(xsltDocumentList[i].uniqueId == sRowId){
                    componentId = xsltDocumentList[i].transformFieldMap.AWSS3XSLTBUCKET.Action__c;
                }
            }
        }
        if(component.get("v.selectedTabName") == $A.get('$Label.c.PDF_Templates')) {
            var pdfTemplateList = component.get('v.pdfTemplateS3BucketObjectList');
            for(var i = 0; i < pdfTemplateList.length; i++){
                if(pdfTemplateList[i].uniqueId == sRowId){
                    componentId = pdfTemplateList[i].transformFieldMap.AWSS3PDFBUCKET.Action__c;
                }
            }
        }
        
        if(componentId) {
            var urlEvent = $A.get("e.force:navigateToURL");
            urlEvent.setParams({
                "url": componentId
            });
            urlEvent.fire();
        }
    } ,
    isSetTabChange: function(component, event, helper) {
        debugger;
        if (component.get("v.isSetTab") == false)  //AT-3032
            return; 
        helper.callServer(component,'c.getAWSS3XsltTemplates',
                          function(response){
                              console.log('getAWSS3XsltTemplates => ' + JSON.stringify(response)) ;
                              var xsltTemplateArr ;
                              var xsltTemplateTransformedArr = [] ;
                              xsltTemplateArr = response ;
                              var xsltFileNameList = [] ;
                              for(var i = 0; i < xsltTemplateArr.length; i++) {
                                  var tempFileName = xsltTemplateArr[i].transformFieldMap.AWSS3XSLTBUCKET.TemplateName__c ;
                                  if(tempFileName.lastIndexOf('/') != -1) {
                                      if(tempFileName.lastIndexOf('.') != -1) {
                                          var fileName = tempFileName.substring(tempFileName.lastIndexOf('/') + 1, tempFileName.lastIndexOf('.')) ;
                                          xsltFileNameList.push(fileName) ;
                                          xsltTemplateArr[i].transformFieldMap.AWSS3XSLTBUCKET.TemplateName__c = fileName ;
                                          xsltTemplateTransformedArr.push(xsltTemplateArr[i]) ;
                                      }
                                  } else {
                                      xsltFileNameList.push(xsltTemplateArr[i].transformFieldMap.AWSS3XSLTBUCKET.TemplateName__c) ;
                                      xsltTemplateTransformedArr.push(xsltTemplateArr[i]) ;
                                  }
                              }
                              console.log('xsltFileNameList=> ' + xsltFileNameList) ;
                              component.set("v.xsltDocumentS3BucketObjectList", xsltTemplateTransformedArr);
                              component.set("v.xsltDocumentNameList", xsltFileNameList) ;
                          },
                          null);
        component.find("xsltDocuments").getElement().className = 'slds-tabs--scoped__item slds-active customClassForTab';
        //component.find("xsltDocuments").set("v.class", "slds-tabs--scoped__item slds-text-title--caps slds-active customClassForTab");
    }, 
})