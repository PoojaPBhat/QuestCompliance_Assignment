public class SQX_BulkJobManagerStatusSync implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.Stateful {

    public Set<String> failedJobIds = new Set<String>();

    public Database.QueryLocator start(Database.BatchableContext bc) {
        String  query   =   'SELECT Id, Name, SQX_Closed__c, SQX_Bulk_Job_Id__c, SQX_Bulk_Job_Status__c,' +
                            'SQX_Records_Failed__c, SQX_Records_Processed__c, SQX_Records_Success__c' +
                            ' FROM SQX_Bulk_Job_Manager__c WHERE SQX_Closed__c = false';
        System.debug('Query***'+query);
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext BC, list<SQX_Bulk_Job_Manager__c> listBJM) {
        if(listBJM!=null && !listBJM.isEmpty() && listBJM.size()==1) {
            SQX_Bulk_Job_Manager__c oBJM = listBJM[0];
            Http oHttpJobInfo = new Http();
            HttpRequest jobInfoReq = new HttpRequest();
            jobInfoReq.setMethod('GET');
            jobInfoReq.setEndpoint(URl.getOrgDomainUrl().toExternalForm()+'/services/data/v56.0/jobs/ingest/'+oBJM.SQX_Bulk_Job_Id__c);
            jobInfoReq.setHeader('content-type', 'application/json' );
            jobInfoReq.setHeader('Authorization' ,'Bearer '+userInfo.getSessionId());
            HttpResponse jobInfoResp = oHttpJobInfo.send(jobInfoReq);
            if(jobInfoResp.getStatusCode() <= 299 && jobInfoResp.getBody() != null) {
                System.debug('jobInfoResp body***'+jobInfoResp.getBody());
                Map<String, Object> jobInfoRespMap = (Map<String, Object>) JSON.deserializeUntyped(jobInfoResp.getBody());
                Integer totalRecords=   (Integer)jobInfoRespMap.get('numberRecordsProcessed');
                Integer recordFailed=   (Integer)jobInfoRespMap.get('numberRecordsFailed');
                String state        =   (String)jobInfoRespMap.get('state');
                Integer recrdSuccess=   totalRecords - recordFailed;
                oBJM.SQX_Bulk_Job_Status__c=state;
                oBJM.SQX_Records_Processed__c=totalRecords;
                oBJM.SQX_Records_Success__c=recrdSuccess;
                oBJM.SQX_Records_Failed__c=recordFailed;
                update oBJM;
                system.debug('recordFailedCount='+recordFailed);
                if(recordFailed > 0) {
                    failedJobIds.add(oBJM.SQX_Bulk_Job_Id__c);
                }
            }
        }   
    }

    public void finish(Database.BatchableContext BC) {
        System.debug('inside finish status sync batch'+failedJobIds.size() + failedJobIds);
        if(!failedJobIds.isEmpty()) {
            Database.executeBatch(new SQX_BatchCreateCSVFailedImport(failedJobIds),1);
        }
    } 
} //End of SQX_BulkJobManagerStatusSync