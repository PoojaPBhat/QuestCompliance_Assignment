public class SQX_BulkAPI2Utility {
    
    //Reference Link: https://developer.salesforce.com/docs/atlas.en-us.api_asynch.meta/api_asynch/walkthrough_upsert.htm

    public static void createBulkJob(String contDocId, String objName, String externalIdFieldApiName, String contentType, String operation, String lineEnding) {
        // Step 1: Getting the file from Content Version
        ContentVersion oCV = [SELECT Id, ContentDocumentId, VersionData FROM ContentVersion WHERE ContentDocumentId =: contDocId ];
        System.debug('oCV*** ' + oCV);
        // Step 2: Creating JOB
        Http oHttpJob = new Http();
        HttpRequest jobReq = new HttpRequest();
        jobReq.setMethod('POST');
        jobReq.setEndpoint(URl.getOrgDomainUrl().toExternalForm()+'/services/data/v56.0/jobs/ingest');
        jobReq.setHeader('content-type', 'application/json' );
        jobReq.setHeader('Authorization' ,'Bearer '+userInfo.getSessionId() );
        String body =   '{' + 
                            '"object":"'+ objName + '",' +
                            '"externalIdFieldName":"'+ externalIdFieldApiName + '",' +
                            '"contentType":"'+ contentType + '",' +
                            '"operation":"'+ operation + '",' +
                            '"lineEnding":"'+ lineEnding + '"' +
                        '}';
        jobReq.setBody(body);
        System.debug('body***'+body);
        System.debug('job req body***'+jobReq.getBody());
        HttpResponse jobResp = oHttpJob.send(jobReq);
        System.debug('jobResp.getBody()***'+ jobResp.getBody());
        if(jobResp.getStatusCode() <= 299 && jobResp.getBody() != null) {
            Map<String, Object> respMap = (Map<String, Object>) JSON.deserializeUntyped(jobResp.getBody());
            String jobId = (String)respMap.get('id');
            // Step 3: Creating Batches to process data
            Http oHttpBatch = new Http();
            HttpRequest batchReq = new HttpRequest();
            batchReq.setMethod('PUT');
            batchReq.setEndpoint(URl.getOrgDomainUrl().toExternalForm()+'/services/data/v56.0/jobs/ingest/'+jobId+'/batches');
            batchReq.setHeader('content-type', 'text/csv' );
            batchReq.setHeader('Authorization' ,'Bearer '+userInfo.getSessionId() );  
            batchReq.setBody(oCV.VersionData.toString());
            System.debug('job req body***'+batchReq.getBody());
            HttpResponse batchResp = oHttpBatch.send(batchReq);
            if(batchResp.getStatusCode() <= 299) {
                // Step 4: After submitting data, tell Salesforce servers that the job is ready for processing by closing the job.
                Http oHttpJobClose = new Http();
                HttpRequest closeReq = new HttpRequest();
                closeReq.setMethod('PATCH');
                closeReq.setEndpoint(URl.getOrgDomainUrl().toExternalForm()+'/services/data/v56.0/jobs/ingest/'+jobId);
                closeReq.setHeader('content-type', 'application/json' );
                closeReq.setHeader('Authorization' ,'Bearer '+userInfo.getSessionId() );  
                closeReq.setBody('{"state":"UploadComplete"}');
                HttpResponse closeResp = oHttpJobClose.send(closeReq);
                System.debug('close resp body***'+closeResp.getBody());
                //Step 5: Getting the Job Info
                Http oHttpJobInfo = new Http();
                HttpRequest jobInfoReq = new HttpRequest();
                jobInfoReq.setMethod('GET');
                jobInfoReq.setEndpoint(URl.getOrgDomainUrl().toExternalForm()+'/services/data/v56.0/jobs/ingest/'+jobId);
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
                    //Step 5: Updating Job status in Bulk Job Manager
                    SQX_Bulk_Job_Manager__c oBJM = new SQX_Bulk_Job_Manager__c(
                        SQX_Bulk_Job_Id__c=jobId,
                        SQX_Bulk_Job_Status__c=state,
                        SQX_Records_Processed__c=totalRecords,
                        SQX_Records_Success__c=recrdSuccess,
                        SQX_Records_Failed__c=recordFailed);
                    insert oBJM;
                    insert (new ContentDocumentLink(LinkedEntityId=oBJM.Id, ContentDocumentId=contDocId, shareType='V'));
                }

            }
        } //End of if(jobResp.getStatusCode() <= 299 && jobResp.getBody() != null)

    } //End of createBulkJob()

}   //End of SQX_BulkAPI2Utility