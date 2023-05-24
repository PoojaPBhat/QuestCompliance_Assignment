public class SQX_BatchCreateCSVFailedImport implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.Stateful {

    public Set<String> sfailedRecordsJobIds = new Set<String>();

    public SQX_BatchCreateCSVFailedImport(Set<String> sFailedJobIds) {
        sfailedRecordsJobIds.addAll(sFailedJobIds);
    }

    public Database.QueryLocator start(Database.BatchableContext bc) {
        String  query   =   'SELECT Id, Name, SQX_Closed__c, SQX_Bulk_Job_Id__c, SQX_Bulk_Job_Status__c,' +
                            'SQX_Records_Failed__c, SQX_Records_Processed__c, SQX_Records_Success__c' +
                            ' FROM SQX_Bulk_Job_Manager__c WHERE SQX_Bulk_Job_Id__c IN:sfailedRecordsJobIds';
        System.debug('Query***'+query);
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext BC, list<SQX_Bulk_Job_Manager__c> listBJM) {
        if(listBJM!=null && !listBJM.isEmpty() && listBJM.size()==1) {
            SQX_Bulk_Job_Manager__c oBJM = listBJM[0];
            Http oHttpJobInfo = new Http();
            HttpRequest failedInfoReq = new HttpRequest();
            failedInfoReq.setMethod('GET');
            failedInfoReq.setEndpoint(URl.getOrgDomainUrl().toExternalForm()+'/services/data/v56.0/jobs/ingest/'+oBJM.SQX_Bulk_Job_Id__c+'/failedResults/');
            failedInfoReq.setHeader('content-type', 'application/json' );
            failedInfoReq.setHeader('Authorization' ,'Bearer '+userInfo.getSessionId());
            HttpResponse failedInfoResp = oHttpJobInfo.send(failedInfoReq);
            if(failedInfoResp.getStatusCode() <= 299 && failedInfoResp.getBody() != null) {
                System.debug('failedInfoResp body***'+failedInfoResp.getBody());
                String strFailedInfoResp = (String) failedInfoResp.getBody();
                System.debug('strFailedInfoResp==='+strFailedInfoResp);
                Blob csvfile = Blob.valueOf(strFailedInfoResp);
                System.debug('csvfile==='+csvfile);
                ContentVersion oCV = new ContentVersion();
                oCV.ContentLocation = 'S';
                oCV.PathonClient = 'FailedRecords.csv';
                oCV.Title = 'FailedRecords.csv';
                oCV.VersionData = csvfile;
                insert oCV;
                String contDocId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id=:oCV.Id LIMIT 1].ContentDocumentId;
                insert (new ContentDocumentLink(LinkedEntityId=oBJM.Id, ContentDocumentId=contDocId, shareType='V'));
            }
        }   
    }

    public void finish(Database.BatchableContext BC) {

    } 
} //End of SQX_BatchCreateCSVFailedImport