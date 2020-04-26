({
	doInit : function(component, event, helper) {
        helper.clearAll(component, event);
        helper.doInit(component, event, helper);
        component.set("v.selectedTabName", $A.get('$Label.c.PDF_Templates'));
	},
    
    handleRowSelectEvent: function(component, event, helper) {
         helper.handleRowSelectEvent(component, event, helper);
    },
    
    fetchPdfTemplates: function(component, event, helper) {
        helper.clearAll(component, event);
        //make PdfTemplates tab active and show tab data
        component.find("pdfTemplates").getElement().className = 'slds-tabs--scoped__item slds-active customClassForTab';
        component.find("pdfTemplatesDataId").getElement().className = 'slds-tabs--scoped__content slds-show customClassForTabData';      
        component.set("v.selectedTabName", component.find("pdfTemplates").getElement().title) ;
    }, 
    
    fetchXsltDocuments: function(component, event, helper) {
        helper.clearAll(component, event);
        //make XsltDocuments tab active and show tab data
        component.find("xsltDocuments").getElement().className = 'slds-tabs--scoped__item slds-active customClassForTab';
        component.find("xsltDocumentsDataId").getElement().className = 'slds-tabs--scoped__content slds-show customClassForTabData';
        component.set("v.selectedTabName", component.find("xsltDocuments").getElement().title) ;
    },
    
    newXsltUploadRequest : function(component, event, helper) {
        component.set("v.isShowPdfComponent", false) ;
        component.set("v.isShowXSLTComponent", true) ;
    } ,
    newPdfUploadRequest : function(component, event, helper) {
        //debugger;
        component.set("v.isShowXSLTComponent", false) ;
        component.set("v.isShowPdfComponent", true) ;
        
    } ,
    
	// handler for refresh Event
    handleRefreshEvent: function(component, event, helper) {
        debugger;
        // allow event propagation
    	helper.handleRefreshEvent(component, event, helper);
    }, 
    	// handler for refresh Event
    isSetTabChange: function(component, event, helper) {
        debugger;
       	helper.isSetTabChange(component, event, helper);
    }
    
})