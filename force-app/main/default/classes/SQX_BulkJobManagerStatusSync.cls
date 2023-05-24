/********************************************************************************************************************
 * Create By  : Pooja P Bhat
 * Description: Batch class to sync the Bulk Manager Job record status, once the BULK API job is completed.
 * CHANGE LOG
 * Date         Story#      ModifiedBy      Reason
 * 23-5-2023                Pooja P Bhat    Created.
 *******************************************************************************************************************/
public class SQX_BulkJobManagerStatusSync implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.Stateful {

    public Set<String> failedJobIds = new Set<String>();

    public Database.QueryLocator start(Database.BatchableContext bc) {
        String  query   =   'SELECT Id, Name, SQX_Closed__c, SQX_Bulk_Job_Id__c, SQX_Bulk_Job_Status__c,' +
                            'SQX_Records_Failed__c, SQX_Records_Processed__c, SQX_Records_Success__c, SQX_Error_Message__c' +
                            ' FROM SQX_Bulk_Job_Manager__c WHERE SQX_Closed__c = false';
        // System.debug('Query***'+query);
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext BC, list<SQX_Bulk_Job_Manager__c> listBJM) {
        // System.debug('listBJM before='+listBJM);
        //if(listBJM!=null && !listBJM.isEmpty() && listBJM.size()==1) {
            //SQX_Bulk_Job_Manager__c oBJM = listBJM[0];
        for(SQX_Bulk_Job_Manager__c oBJM: listBJM) {
            Http oHttpJobInfo = new Http();
            HttpRequest jobInfoReq = new HttpRequest();
            jobInfoReq.setMethod('GET');
            jobInfoReq.setEndpoint(URl.getOrgDomainUrl().toExternalForm()+'/services/data/v56.0/jobs/ingest/'+oBJM.SQX_Bulk_Job_Id__c);
            jobInfoReq.setHeader('content-type', 'application/json' );
            jobInfoReq.setHeader('Authorization' ,'Bearer '+userInfo.getSessionId());
            HttpResponse jobInfoResp = oHttpJobInfo.send(jobInfoReq);
            if(jobInfoResp.getStatusCode() <= 299 && jobInfoResp.getBody() != null) {
                // System.debug('jobInfoResp body***'+jobInfoResp.getBody());
                Map<String, Object> jobInfoRespMap = (Map<String, Object>) JSON.deserializeUntyped(jobInfoResp.getBody());
                Integer totalRecords=   Integer.valueOf(jobInfoRespMap.containsKey('numberRecordsProcessed') ? jobInfoRespMap.get('numberRecordsProcessed') : 0);
                Integer recordFailed=   Integer.valueOf(jobInfoRespMap.containsKey('numberRecordsFailed') ? jobInfoRespMap.get('numberRecordsFailed') : 0);
                Integer recrdSuccess=   totalRecords - recordFailed;
                String state        =   String.valueOf(jobInfoRespMap.containsKey('state') ? jobInfoRespMap.get('state') : '');
                String errMsg       =   String.valueOf(jobInfoRespMap.containsKey('errorMessage') ? jobInfoRespMap.get('errorMessage') : '');
                oBJM.SQX_Bulk_Job_Status__c     =   state;
                oBJM.SQX_Records_Processed__c   =   totalRecords;
                oBJM.SQX_Records_Success__c     =   recrdSuccess;
                oBJM.SQX_Records_Failed__c      =   recordFailed;
                oBJM.SQX_Error_Message__c       =   errMsg;
                // System.debug('oBJM='+oBJM);
                //update oBJM;
                // System.debug('recordFailedCount='+recordFailed);
                if(recordFailed > 0) {
                    failedJobIds.add(oBJM.SQX_Bulk_Job_Id__c);
                }
            }
        }  
        // System.debug('listBJM='+listBJM);
        if(!listBJM.isEmpty()) update listBJM;
    }

    public void finish(Database.BatchableContext BC) {
        // System.debug('inside finish status sync batch'+failedJobIds.size() + failedJobIds);
        if(!failedJobIds.isEmpty() && !Test.isRunningTest()) {
            Database.executeBatch(new SQX_BatchCreateCSVFailedImport(failedJobIds),50);
        }
    } 
} //End of SQX_BulkJobManagerStatusSync