/********************************************************************************************************************
 * Create By  : Pooja P Bhat
 * Description: Test class to cover code coverage and verify logic for class SQX_BatchCreateCSVFailedImport
 * CHANGE LOG
 * Date         Story#      ModifiedBy      Reason
 * 24-5-2023                Pooja P Bhat    Created.
 *******************************************************************************************************************/
@isTest
public class SQX_BatchCreateCSVFailedImportTest {
	
    @TestSetup
    static void makeData(){
        List<SQX_Bulk_Job_Manager__c> insertBjmLst = new List<SQX_Bulk_Job_Manager__c>();
        SQX_Bulk_Job_Manager__c oBJM1 = new SQX_Bulk_Job_Manager__c(SQX_Bulk_Job_Id__c='750B0000009aLc7',SQX_Bulk_Job_Status__c='JobComplete',SQX_Records_Processed__c=100,SQX_Records_Success__c=99,SQX_Records_Failed__c=1);
        insertBjmLst.add(oBJM1);
        SQX_Bulk_Job_Manager__c oBJM2 = new SQX_Bulk_Job_Manager__c(SQX_Bulk_Job_Id__c='750B0000009aLc8',SQX_Bulk_Job_Status__c='JobComplete',SQX_Records_Processed__c=200,SQX_Records_Success__c=198,SQX_Records_Failed__c=2);
        insertBjmLst.add(oBJM2);
        SQX_Bulk_Job_Manager__c oBJM3 = new SQX_Bulk_Job_Manager__c(SQX_Bulk_Job_Id__c='750B0000009aLc9',SQX_Bulk_Job_Status__c='JobComplete',SQX_Records_Processed__c=150,SQX_Records_Success__c=0,SQX_Records_Failed__c=0);
        insertBjmLst.add(oBJM3);
        insert insertBjmLst;
    }
    
    @isTest
    static void testBatchJobBJMFailedCSVCreation() {
        Test.setMock(HttpCalloutMock.class, new SQX_BulkAPI2UtilityMock()); //Setting the fake response using MockCallout
        Set<String> sBjmIds = new Set<String>();
        for(SQX_Bulk_Job_Manager__c oBjm : [SELECT Id,SQX_Bulk_Job_Id__c FROM SQX_Bulk_Job_Manager__c WHERE SQX_Records_Failed__c>0]) {
            sBjmIds.add(oBjm.SQX_Bulk_Job_Id__c);
        }
        Test.startTest();
        Database.executeBatch(new SQX_BatchCreateCSVFailedImport(sBjmIds)); //Executing the batch to create Failed records CSV
        Test.stopTest();
        Map<Id,SQX_Bulk_Job_Manager__c> mapBJM = new Map<Id,SQX_Bulk_Job_Manager__c>([SELECT Id, Name, SQX_Closed__c, SQX_Bulk_Job_Id__c, 
            SQX_Bulk_Job_Status__c, SQX_Records_Failed__c, SQX_Records_Processed__c, SQX_Records_Success__c, SQX_Error_Message__c
            FROM SQX_Bulk_Job_Manager__c]);
        Assert.areEqual(3, mapBJM.size());
         Set<String> sCDLIds = new Set<String>();
        for(ContentDocumentLink cdl : [SELECT Id,LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId IN:mapBJM.keySet() ]) {
            sCDLIds.add(cdl.LinkedEntityId);
        }
        for(SQX_Bulk_Job_Manager__c oBJM: mapBJM.values()) { //To assert, if BJM records with Record Failed Count > 0 has the CSV file created with the help of above batch job.
            if(oBJM.SQX_Records_Failed__c>0)
                Assert.isTrue(sCDLIds.contains(oBJM.Id));
            else
                Assert.isFalse(sCDLIds.contains(oBJM.Id));
        }                 
    }
}