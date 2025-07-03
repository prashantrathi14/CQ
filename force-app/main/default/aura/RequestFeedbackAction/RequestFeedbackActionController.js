({
    doInit : function(component, event, helper) {
    },
    
    handleRequest : function(component, event, helper) {
        component.set("v.isLoading", true);
		console.log('v.isLoading>>'+"v.isLoading");
        let action = component.get("c.createFeedbackRecord");
        action.setParams({ complaintId: component.get("v.recordId") });

        action.setCallback(this, function(response) {
            let state = response.getState();
            let toastEvent = $A.get("e.force:showToast");
			console.log('state>>>'+state);
            if (state === "SUCCESS") {
                toastEvent.setParams({
                    title: "Success",
                    message: "Feedback request sent successfully.",
                    type: "success"
                });
                component.set("v.isLoading", false);
            	toastEvent.fire();
            } else {
                let errors = response.getError();
                console.log('errors>>>>'+errors);
                let errorMsg = (errors && errors[0] && errors[0].message) ? errors[0].message : "Unknown error occurred.";
                toastEvent.setParams({
                    title: "Error",
                    message: errorMsg,
                    type: "error"
                });
            }
            
            $A.get("e.force:closeQuickAction").fire();
        });

        $A.enqueueAction(action);
    }
})