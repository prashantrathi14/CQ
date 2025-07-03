({
    handleRequest : function(component, event, helper) {
        component.set("v.isLoading", true);

        let action = component.get("c.createFeedbackRecord");
        action.setParams({ complaintId: component.get("v.recordId") });

        action.setCallback(this, function(response) {
            let state = response.getState();
            let toastEvent = $A.get("e.force:showToast");

            console.log('Apex callback state: ' + state);

            if (state === "SUCCESS") {
                toastEvent.setParams({
                    title: "Success",
                    message: "Feedback request sent successfully.",
                    type: "success"
                });
            } else {
                let errors = response.getError();
                console.error('Apex error response:', errors);
                let errorMsg = (errors && errors[0] && errors[0].message)
                    ? errors[0].message
                    : "Unknown error occurred.";

                toastEvent.setParams({
                    title: "Error",
                    message: errorMsg,
                    type: "error"
                });
            }
            toastEvent.fire();
            
            $A.get("e.force:closeQuickAction").fire();
        });

        $A.enqueueAction(action);
    }
})
