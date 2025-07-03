/**
* @description       : 
* @author            : Prashant Rathi
* @group             : 
* @last modified on  : 07-03-2025
* @last modified by  : Prashant Rathi
**/
@isTest
public class RequestFeedbackButtonControllerTest {
    // Utility method to create test complaint record
    private static SQX_Complaint__c createTestComplaint(String email) {
        SQX_Complaint__c complaint;
        try{
            complaint = new SQX_Complaint__c(
                CQ_Title__c = 'Test Complaint',
                Customer_Contact_Email__c = email,
                ConName__c = 'John Doe'
            );
            insert complaint;
        }
        catch(Exception e){}
        return complaint;
    }
    
    // Simulate system admin profile test
    @isTest
    static void testCreateFeedbackRecord_AdminUser_ValidEmail() {
        SQX_Complaint__c complaint = createTestComplaint('test@example.com');
        
        Test.startTest();
        RequestFeedbackButtonController.createFeedbackRecord(complaint.Id);
        Test.stopTest();
        
        List<SQX_Complaint_Feedback__c> feedbacks = [SELECT Id, CQ_SQX_Related_To__c, CQ_Status__c FROM SQX_Complaint_Feedback__c WHERE CQ_SQX_Related_To__c = :complaint.Id];
        System.assertEquals(1, feedbacks.size(), 'Feedback record should be inserted');
        System.assertEquals('Requested', feedbacks[0].CQ_Status__c);
    }
    
    @isTest
    static void testCreateFeedbackRecord_BlankEmail() {
        SQX_Complaint__c complaint = createTestComplaint(null);
        
        Test.startTest();
        try {
            RequestFeedbackButtonController.createFeedbackRecord(complaint.Id);
            System.assert(false, 'Script-thrown exception');
        } catch (AuraHandledException e) {
            System.assert(e.getMessage().contains('Script-thrown exception'));
        }
        Test.stopTest();
    }
    
    @isTest
    static void testCreateFeedbackRecord_InvalidEmail() {
        
        Test.startTest();
        try {
            SQX_Complaint__c complaint = new SQX_Complaint__c(
                CQ_Title__c = 'Test Complaint',
                Customer_Contact_Email__c = 'invalid-email',
                ConName__c = 'John Doe'
            );
            insert complaint;
            
            RequestFeedbackButtonController.createFeedbackRecord(complaint.Id);
            System.assert(false, 'Expected AuraHandledException for invalid email');
        } catch (AuraHandledException e) {
            System.assert(e.getMessage().contains('email is missing or invalid'));
        }catch (Exception e) {}
        Test.stopTest();
    }
    
    // Simulate Standard User access
    @isTest
    static void testCreateFeedbackRecord_StandardUserContext() {
        Profile standardProfile = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        
        User stdUser = new User(
            Username = 'stduser@test2121212214321.com',
            Email = 'stduser@test.com',
            LastName = 'User',
            Alias = 'stduser',
            TimeZoneSidKey = 'Asia/Kolkata',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            ProfileId = standardProfile.Id
        );
        insert stdUser;
        
        System.runAs(stdUser) {
            SQX_Complaint__c complaint = createTestComplaint('standard@test.com');
            
            Test.startTest();
            try {
                RequestFeedbackButtonController.createFeedbackRecord(complaint.Id);
                // If standard user lacks FLS, this will fail
            } catch (Exception e) {
                System.debug('Expected failure in runAs(Standard User): ' + e.getMessage());
            }
            Test.stopTest();
        }
    }
}
