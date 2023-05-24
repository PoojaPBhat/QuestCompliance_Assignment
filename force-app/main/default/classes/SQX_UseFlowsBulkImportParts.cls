public with sharing class SQX_UseFlowsBulkImportParts {
    
    @InvocableMethod(label='Flow Import CSV File' description='Import Data from the CSV file')
    public static void bulkImportParts(List<RequestWrapper> listRequestWrapper) {
        if(listRequestWrapper!=null && !listRequestWrapper.isEmpty() && listRequestWrapper.size()==1) {
            RequestWrapper reqWrap      =   listRequestWrapper[0];
            String objectName           =   reqWrap.objectName;
            String externalIdFieldApi   =   String.isBlank(reqWrap.externalIdFieldApi) ? 'Id' : reqWrap.externalIdFieldApi ;
            String operation            =   reqWrap.operation;
            String contDocId            =   reqWrap.listFileId[0];
            Boolean hasCustomPermission =   FeatureManagement.checkPermission(SQX_ConstantsUtility.INTEGRATION_ADMIN);
            if(hasCustomPermission) {
                SQX_BulkAPI2Utility.createBulkJob(contDocId,objectName,externalIdFieldApi,'CSV',operation,'CRLF');
            } else {
                SQX_Bulk_Job_Manager__c oBJM = new SQX_Bulk_Job_Manager__c(SQX_Bulk_Job_Status__c='Failed. No Admin permission to bulk upload records.');
                insert oBJM;
                insert (new ContentDocumentLink(LinkedEntityId=oBJM.Id, ContentDocumentId=contDocId, shareType='V'));
            }
        } //End of if(listRequestWrapper!=null && !listRequestWrapper.isEmpty()) 
    } //End of bulkImportParts()

    public class RequestWrapper {
        @InvocableVariable(label='File Ids' description='File Ids' required=true)
        public List<String> listFileId;
        @InvocableVariable(label='Object Name' description='Object Name' required=true)
        public String objectName;
        @InvocableVariable(label='External Field Api Name' description='Update record using Object External Field Id' required=false)
        public String externalIdFieldApi;
        @InvocableVariable(label='Operation' description='Operation' required=true)
        public String operation;
    }

} //End of SQX_UseFlowsBulkImportParts
