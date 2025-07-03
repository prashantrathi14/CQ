/**
 * @description       :
 * @author            : Prashant Rathi
 * @group             :
 * @last modified on  : 07-03-2025
 * @last modified by  : Prashant Rathi
 **/
public with sharing class RequestFeedbackButtonController {
    @AuraEnabled
    public static void createFeedbackRecord(Id complaintId){
        SQX_Complaint__c complaint = [SELECT Id, CQ_Title__c, Name, Customer_Contact_Email__c, ConName__c‎ 
                                                FROM SQX_Complaint__c 
                                                WHERE Id = :complaintId WITH SECURITY_ENFORCED LIMIT 1];
        String email = complaint.Customer_Contact_Email__c;
        if (String.isBlank(email) || !Pattern.matches('^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$', email)) {
        throw new AuraHandledException('Customer Contact email is missing or invalid.');
        }
        SQX_Complaint_Feedback__c feedback = new SQX_Complaint_Feedback__c(
            CQ_SQX_Related_To__c = complaint.Id,
            CQ_Status__c = 'Requested'
        );
        insert feedback;
        sendFeedbackEmail(feedback.Id, complaint.Customer_Contact_Email__c,complaint.Name, complaint.ConName__c);
    }

    // Sending Feedback record link on email
    private static void sendFeedbackEmail(Id feedbackId, String toEmail, String complaintName, String ConName) {
        String baseUrl = URL.getOrgDomainUrl().toExternalForm();
        String formLink = baseUrl + '/lightning/r/SQX_Complaint_Feedback__c/' + feedbackId + '/view';

        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.setToAddresses(new String[] { toEmail });
        email.setSubject('Please fill your feedback for Compliant : '+complaintName);
        email.setPlainTextBody('Hi '+ ConName+'\n\nPlease share your thoughts by clicking the link below:\n' + formLink +'\n\n Regards\n System Admin');
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email });
    }
}
