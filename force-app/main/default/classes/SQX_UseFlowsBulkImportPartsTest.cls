/********************************************************************************************************************
 * Create By  : Pooja P Bhat
 * Description: Test class to cover code coverage and verify logic for the class SQX_UseFlowsBulkImportParts
 * CHANGE LOG
 * Date         Story#      ModifiedBy      Reason
 * 24-5-2023                Pooja P Bhat    Created.
 *******************************************************************************************************************/
@isTest
public class SQX_UseFlowsBulkImportPartsTest {
	
    @TestSetup
    static void makeData(){
        List<Account> accList = new List<Account>();
        Account acc1 =  new Account(Name='Low Volume');     accList.add(acc1);
        Account acc2 =  new Account(Name='High Volume');    accList.add(acc2);
        insert accList;

        ContentVersion contentVer = new ContentVersion(
            ContentLocation = 'S',
            PathOnClient = 'Att1',
            Title = 'Att1',
            VersionData = Blob.valueOf('Name,SQX_Part_Number__c,SQX_Total_Quantity_Shipped__c\r\n'+
            'OKYPI-30,619683d69402c24f000XM96,842\r\n'+
            'HTEOM-79,619683d69402c24f000VS72,985\r\n'+
            'NGTSB-84,619683d69402c24f000GC49,892\r\n'));
        insert contentVer;
    }
    
    @isTest
    static void userWithoutPermission() {
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

        ContentVersion oCV = [SELECT Id, ContentDocumentId, VersionData FROM ContentVersion LIMIT 1];
        SQX_UseFlowsBulkImportParts.RequestWrapper reqWrap =  new SQX_UseFlowsBulkImportParts.RequestWrapper();
        reqWrap.listFileId = new List<String>{oCV.ContentDocumentId};
        reqWrap.objectName = 'SQX_Part__c';
        reqWrap.externalIdFieldApi = 'SQX_Part_Number__c';
        reqWrap.operation = 'upsert';

        List<SQX_UseFlowsBulkImportParts.RequestWrapper> lstReqWrap = new List<SQX_UseFlowsBulkImportParts.RequestWrapper>();
        lstReqWrap.add(reqWrap);
        
        Test.startTest();
        System.runAs(user1) {
            SQX_UseFlowsBulkImportParts.bulkImportParts(lstReqWrap);
            List<SQX_Bulk_Job_Manager__c> bjmLst =  [SELECT Id, Name, SQX_Closed__c, SQX_Bulk_Job_Id__c, 
            SQX_Bulk_Job_Status__c, SQX_Records_Failed__c, SQX_Records_Processed__c, SQX_Records_Success__c
            FROM SQX_Bulk_Job_Manager__c];
            Assert.areEqual(1, bjmLst.size());
            Assert.areEqual(null, bjmLst[0].SQX_Bulk_Job_Id__c);
            Assert.areEqual('Failed. No Admin permission to bulk upload records.',bjmLst[0].SQX_Bulk_Job_Status__c);
        }
        Test.stopTest();
    }

    @isTest
    static void userWithPermission() {
        Test.setMock(HttpCalloutMock.class, new SQX_BulkAPI2UtilityMock());
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

        ContentVersion oCV = [SELECT Id, ContentDocumentId, VersionData FROM ContentVersion LIMIT 1];
        SQX_UseFlowsBulkImportParts.RequestWrapper reqWrap =  new SQX_UseFlowsBulkImportParts.RequestWrapper();
        reqWrap.listFileId = new List<String>{oCV.ContentDocumentId};
        reqWrap.objectName = 'SQX_Part__c';
        reqWrap.externalIdFieldApi = 'SQX_Part_Number__c';
        reqWrap.operation = 'upsert';

        List<SQX_UseFlowsBulkImportParts.RequestWrapper> lstReqWrap = new List<SQX_UseFlowsBulkImportParts.RequestWrapper>();
        lstReqWrap.add(reqWrap);

        Test.startTest();
        System.runAs(user1) {
            System.assertEquals(true, FeatureManagement.checkPermission(SQX_ConstantsUtility.INTEGRATION_ADMIN));
            SQX_UseFlowsBulkImportParts.bulkImportParts(lstReqWrap);
            List<SQX_Bulk_Job_Manager__c> bjmLst =  [SELECT Id, Name, SQX_Closed__c, SQX_Bulk_Job_Id__c, 
            SQX_Bulk_Job_Status__c, SQX_Records_Failed__c, SQX_Records_Processed__c, SQX_Records_Success__c
            FROM SQX_Bulk_Job_Manager__c];
            Assert.areEqual(1, bjmLst.size());
            Assert.areEqual('750B0000009aLab', bjmLst[0].SQX_Bulk_Job_Id__c);
            Assert.areEqual(1000, bjmLst[0].SQX_Records_Processed__c);
            Assert.areEqual(950, bjmLst[0].SQX_Records_Success__c);
            Assert.areEqual(50, bjmLst[0].SQX_Records_Failed__c);
        }
        Test.stopTest();
    }
}