/********************************************************************************************************************
 * Create By  : Pooja P Bhat
 * Description: Test class to cover code coverage and verify logic of class SQX_BulkJobManagerStatusSync
 * CHANGE LOG
 * Date         Story#      ModifiedBy      Reason
 * 24-5-2023                Pooja P Bhat    Created.
 *******************************************************************************************************************/
@isTest
public class SQX_BulkJobManagerStatusSyncTest {
	
    @TestSetup
    static void makeData(){
        List<SQX_Bulk_Job_Manager__c> insertBjmLst = new List<SQX_Bulk_Job_Manager__c>();
        SQX_Bulk_Job_Manager__c oBJM1 = new SQX_Bulk_Job_Manager__c(SQX_Bulk_Job_Id__c='750B0000009aLc5',SQX_Bulk_Job_Status__c='Initializing',SQX_Records_Processed__c=0,SQX_Records_Success__c=0,SQX_Records_Failed__c=0);
        insertBjmLst.add(oBJM1);
        SQX_Bulk_Job_Manager__c oBJM2 = new SQX_Bulk_Job_Manager__c(SQX_Bulk_Job_Id__c='750B0000009aLc6',SQX_Bulk_Job_Status__c='Initializing',SQX_Records_Processed__c=0,SQX_Records_Success__c=0,SQX_Records_Failed__c=0);
        insertBjmLst.add(oBJM2);
        SQX_Bulk_Job_Manager__c oBJM3 = new SQX_Bulk_Job_Manager__c(SQX_Bulk_Job_Id__c='750B0000009aLc7',SQX_Bulk_Job_Status__c='Initializing',SQX_Records_Processed__c=0,SQX_Records_Success__c=0,SQX_Records_Failed__c=0);
        insertBjmLst.add(oBJM3);
        SQX_Bulk_Job_Manager__c oBJM4 = new SQX_Bulk_Job_Manager__c(SQX_Bulk_Job_Id__c='750B0000009aLc8',SQX_Bulk_Job_Status__c='Initializing',SQX_Records_Processed__c=0,SQX_Records_Success__c=0,SQX_Records_Failed__c=0);
        insertBjmLst.add(oBJM4);
        SQX_Bulk_Job_Manager__c oBJM5 = new SQX_Bulk_Job_Manager__c(SQX_Bulk_Job_Id__c='750B0000009aLc9',SQX_Bulk_Job_Status__c='Initializing',SQX_Records_Processed__c=0,SQX_Records_Success__c=0,SQX_Records_Failed__c=0);
        insertBjmLst.add(oBJM5);
        insert insertBjmLst;
    }
    
    @isTest
    static void testBatchJobBJMStatusSync() {
        Test.setMock(HttpCalloutMock.class, new SQX_BulkAPI2UtilityMock());
        Test.startTest();
        Database.executeBatch(new SQX_BulkJobManagerStatusSync());
        Test.stopTest();
        List<SQX_Bulk_Job_Manager__c> bjmLst =  [SELECT Id, Name, SQX_Closed__c, SQX_Bulk_Job_Id__c, 
            SQX_Bulk_Job_Status__c, SQX_Records_Failed__c, SQX_Records_Processed__c, SQX_Records_Success__c, SQX_Error_Message__c
            FROM SQX_Bulk_Job_Manager__c];
        Assert.areEqual(5, bjmLst.size());
        for(SQX_Bulk_Job_Manager__c oBJM : bjmLst) {
            if(oBJM.SQX_Bulk_Job_Id__c=='750B0000009aLc5'){
                Assert.areEqual('Failed',oBJM.SQX_Bulk_Job_Status__c);
                Assert.areEqual(0, oBJM.SQX_Records_Processed__c);
                Assert.areEqual(0, oBJM.SQX_Records_Success__c);
                Assert.areEqual(0, oBJM.SQX_Records_Failed__c);
                Assert.areEqual('InvalidBatch:InvalidBatch:Field name not found:Name',oBJM.SQX_Error_Message__c);
            } else if(oBJM.SQX_Bulk_Job_Id__c=='750B0000009aLc6'){
                Assert.areEqual('Failed',oBJM.SQX_Bulk_Job_Status__c);
                Assert.areEqual(0, oBJM.SQX_Records_Processed__c);
                Assert.areEqual(0, oBJM.SQX_Records_Success__c);
                Assert.areEqual(0, oBJM.SQX_Records_Failed__c);
                Assert.areEqual('InvalidBatch:InvalidBatch:Field name not found:SQX_Part_Number__c',oBJM.SQX_Error_Message__c);
            } else if(oBJM.SQX_Bulk_Job_Id__c=='750B0000009aLc7'){
                Assert.areEqual('JobComplete',oBJM.SQX_Bulk_Job_Status__c);
                Assert.areEqual(100, oBJM.SQX_Records_Processed__c);
                Assert.areEqual(99, oBJM.SQX_Records_Success__c);
                Assert.areEqual(1, oBJM.SQX_Records_Failed__c);
                Assert.isNull(oBJM.SQX_Error_Message__c);
            } else if(oBJM.SQX_Bulk_Job_Id__c=='750B0000009aLc8'){
                Assert.areEqual('JobComplete',oBJM.SQX_Bulk_Job_Status__c);
                Assert.areEqual(200, oBJM.SQX_Records_Processed__c);
                Assert.areEqual(198, oBJM.SQX_Records_Success__c);
                Assert.areEqual(2, oBJM.SQX_Records_Failed__c);
                Assert.isNull(oBJM.SQX_Error_Message__c);
            } else if(oBJM.SQX_Bulk_Job_Id__c=='750B0000009aLc9'){
                Assert.areEqual('JobComplete',oBJM.SQX_Bulk_Job_Status__c);
                Assert.areEqual(150, oBJM.SQX_Records_Processed__c);
                Assert.areEqual(150, oBJM.SQX_Records_Success__c);
                Assert.areEqual(0, oBJM.SQX_Records_Failed__c);
                Assert.isNull(oBJM.SQX_Error_Message__c);
            }
        }             
    }
}