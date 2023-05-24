/********************************************************************************************************************
 * Create By  : Pooja P Bhat
 * Description: HttpCalloutMock Class for to test BULK API 2.0 Responses [Reference Class: SQX_BulkAPI2Utility]
 * CHANGE LOG
 * Date         Story#      ModifiedBy      Reason
 * 24-5-2023                Pooja P Bhat    Created.
 *******************************************************************************************************************/
global class SQX_BulkAPI2UtilityMock implements HttpCalloutMock {
    
    global HTTPResponse respond(HTTPRequest request) {
        // Create a fake response
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setStatusCode(200);
        if(request.getEndpoint().endsWith('750B0000009aLc5')){
            response.setBody('{"id":"750B0000009aLc5","operation":"upsert","object":"SQX_Part__c","state":"Failed","externalIdFieldName":"SQX_Part_Number__c","concurrencyMode":"Parallel",'+
                            '"contentType":"CSV","apiVersion":56.0,"jobType":"V2Ingest","lineEnding":"CRLF","columnDelimiter":"COMMA","numberRecordsProcessed":0,"numberRecordsFailed":0,'+
                            '"retries":0,"totalProcessingTime":0,"apiActiveProcessingTime":0,"apexProcessingTime":0,"errorMessage":"InvalidBatch:InvalidBatch:Field name not found:Name"}'
                            );
        } else if(request.getEndpoint().endsWith('750B0000009aLc6')){
            response.setBody('{"id":"750B0000009aLc6","operation":"upsert","object":"SQX_Part__c","state":"Failed","externalIdFieldName":"SQX_Part_Number__c","concurrencyMode":"Parallel",'+
            '"contentType":"CSV","apiVersion":56.0,"jobType":"V2Ingest","lineEnding":"CRLF","columnDelimiter":"COMMA","numberRecordsProcessed":0,"numberRecordsFailed":0,'+
            '"retries":0,"totalProcessingTime":0,"apiActiveProcessingTime":0,"apexProcessingTime":0,"errorMessage":"InvalidBatch:InvalidBatch:Field name not found:SQX_Part_Number__c"}'
            );
        } else if(request.getEndpoint().endsWith('750B0000009aLc7')){
            response.setBody('{"id":"750B0000009aLc7","operation":"upsert","object":"SQX_Part__c","state":"JobComplete","externalIdFieldName":"SQX_Part_Number__c","concurrencyMode":"Parallel",'+
            '"contentType":"CSV","apiVersion":56.0,"jobType":"V2Ingest","lineEnding":"CRLF","columnDelimiter":"COMMA","numberRecordsProcessed":100,"numberRecordsFailed":1,'+
            '"retries":0,"totalProcessingTime":0,"apiActiveProcessingTime":0,"apexProcessingTime":0}'
            );
        } else if(request.getEndpoint().endsWith('750B0000009aLc8')){
            response.setBody('{"id":"750B0000009aLc8","operation":"upsert","object":"SQX_Part__c","state":"JobComplete","externalIdFieldName":"SQX_Part_Number__c","concurrencyMode":"Parallel",'+
            '"contentType":"CSV","apiVersion":56.0,"jobType":"V2Ingest","lineEnding":"CRLF","columnDelimiter":"COMMA","numberRecordsProcessed":200,"numberRecordsFailed":2,'+
            '"retries":0,"totalProcessingTime":0,"apiActiveProcessingTime":0,"apexProcessingTime":0}'
            );
        } else if(request.getEndpoint().endsWith('750B0000009aLc9')){
            response.setBody('{"id":"750B0000009aLc9","operation":"upsert","object":"SQX_Part__c","state":"JobComplete","externalIdFieldName":"SQX_Part_Number__c","concurrencyMode":"Parallel",'+
            '"contentType":"CSV","apiVersion":56.0,"jobType":"V2Ingest","lineEnding":"CRLF","columnDelimiter":"COMMA","numberRecordsProcessed":150,"numberRecordsFailed":0,'+
            '"retries":0,"totalProcessingTime":0,"apiActiveProcessingTime":0,"apexProcessingTime":0}'
            );
        } else if(request.getEndpoint().endsWith('750B0000009aLc7/failedResults/')) {
            response.setBody('"sf__Id","sf__Error",Name,SQX_Part_Number__c,SQX_Total_Quantity_Shipped__c\r\n' +
            '"","MISSING_ARGUMENT:SQX_Part_Number__c not specified:--","JCXYM-82","","640.0"');
        } else if(request.getEndpoint().endsWith('750B0000009aLc8/failedResults/')) { 
            response.setBody('"sf__Id","sf__Error",Name,SQX_Part_Number__c,SQX_Total_Quantity_Shipped__c\r\n' +
            '"","MISSING_ARGUMENT:SQX_Part_Number__c not specified:--","JCXYM-82","","640.0\r\n"'+
            '"","MISSING_ARGUMENT:SQX_Part_Number__c not specified:--","JCXYM-83","","898.0\r\n"');
        } else {
            response.setBody('{"id":"750B0000009aLab","numberRecordsProcessed":"1000","numberRecordsFailed":"50","object":"SQX_Part__c","operation":"upsert"}');
        }
        return response;
    }
}