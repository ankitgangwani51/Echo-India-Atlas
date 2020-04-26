({
    afterRender : function(component, helper){
        this.superAfterRender();
        var targetE1 = component.find("GenericRow").getElement();
        targetE1.addEventListener("click", function(e){helper.doRowClick(component, e, helper);}, false);
    }
})