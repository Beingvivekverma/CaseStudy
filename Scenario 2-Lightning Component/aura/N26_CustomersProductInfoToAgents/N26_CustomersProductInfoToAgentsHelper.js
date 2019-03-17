({
	doInit : function(component, event, helper) {
       	//Calling Apex Method passing parameters retrieved by LDS to save additional server call.
       	console.log('record ID--> ' +component.get("v.recordId"));

		var responseFromDB = component.get("c.returnProductDetailsUsingWrapper");
        responseFromDB.setParams({
                "recordId" : component.get("v.recordId")
            })
        responseFromDB.setCallback(this,function(response){
            
            //Handling Success to load attributes.
            if (response.getState() === "SUCCESS") {
        		//got successful response from backend
                var res = response.getReturnValue();
                console.log('response from DB:: ' +res);
                component.set("v.costPerCalendarMonth", res.costPerCalendarMonth);
                component.set("v.atmFeeInOtherCurr", res.atmFeeInOtherCurr);
                component.set("v.cardReplacementCost", res.cardReplacementCost);
            
            }else if(response.getState() === "ERROR"){
                //Toast for Error
                this.showToast(component,event,helper);
            } else if(response.getState() === "INCOMPLETE"){
                //Toast for Incomplete
                this.showToast(component,event,helper); 
            }
        }); 
        $A.enqueueAction(responseFromDB);		
	},
    
    showToast : function(component, event, helper) {
    	var toastEvent = $A.get("e.force:showToast");
    	toastEvent.setParams({
        	"title": "Error",
        	"message": "Please Contact N26 Administrator!!"
    	});
    	toastEvent.fire();
}
})