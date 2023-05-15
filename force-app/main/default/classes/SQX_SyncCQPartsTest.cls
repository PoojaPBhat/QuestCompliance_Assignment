/********************************************************************************************************************
 * Create By  : Pooja P Bhat
 * Description: Test class to cover unit test for Class SQX_SyncCQParts
 * CHANGE LOG
 * Date         Story#      ModifiedBy      Reason
 * 15-5-2023                Pooja P Bhat    Class Created to attain code coverage and unit test method functionality
 *******************************************************************************************************************/
@isTest
public class SQX_SyncCQPartsTest {
	
    @TestSetup
    static void makeData(){
        List<Account> accList = new List<Account>();
        Account acc1 =  new Account(Name='Low Volume');     accList.add(acc1);
        Account acc2 =  new Account(Name='High Volume');    accList.add(acc2);
        insert accList;
    }
    
    @isTest
    static void defaultTestMethod(){
        Test.setMock(HttpCalloutMock.class, new SQX_RestMockCallouts());
        Test.startTest();
        String message = SQX_SyncCQParts.createCQParts();
        Assert.areEqual('Sync was successful.', message);
        Test.stopTest();
        System.debug(message);
    }

    @isTest
    static void testMethod_noPermToSyncQCParts(){
        Test.setMock(HttpCalloutMock.class, new SQX_RestMockCallouts());
        User user1 = new User(
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'Standard User'].Id,
            LastName = 'last',
            Email = 'puser000@amamama.com',
            Username = 'puser000@amamama.com' + System.currentTimeMillis(),
            CompanyName = 'TEST',
            Title = 'title',
            Alias = 'alias',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US'
        );
        insert user1;
        Test.startTest();
        System.runAs(user1) {
            String message = SQX_SyncCQParts.createCQParts();
            System.debug(message);
            Assert.areNotEqual('Sync was successful.', message);
            Assert.areEqual('You dont have required permission to sync the QC Parts.', message);
            Test.stopTest();
        }
    }

    @isTest
    static void testMethod_integrationAdmin_SyncPermEnabled() {
        System.assertEquals(true, FeatureManagement.checkPermission(SQX_ConstantsUtility.INTEGRATION_ADMIN));
        Test.setMock(HttpCalloutMock.class, new SQX_RestMockCallouts());
        User user1 = new User(
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'Integration Admin'].Id,
            LastName = 'last',
            Email = 'puser000@amamama.com',
            Username = 'puser000@amamama.com' + System.currentTimeMillis(),
            CompanyName = 'TEST',
            Title = 'title',
            Alias = 'alias',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US'
        );
        insert user1;
        Test.startTest();
        System.runAs(user1) {
            String message = SQX_SyncCQParts.createCQParts();
            System.debug(message);
            Assert.areEqual('Sync was successful.', message);
            Assert.areNotEqual('You dont have required permission to sync the QC Parts.', message);
            Test.stopTest();
        }
    }
}