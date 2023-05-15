/********************************************************************************************************************
 * Create By  : Pooja P Bhat
 * Description: Set the mock response for SQX_RestCallouts
 * CHANGE LOG
 * Date         Story#      ModifiedBy      Reason
 * 15-5-2023                Pooja P Bhat    Class Created to set the mock response.
 *******************************************************************************************************************/
@isTest
global class SQX_RestMockCallouts implements HttpCalloutMock{
    global HttpResponse respond(HttpRequest req){
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json;charset=UTF-8');
        res.setHeader('x-api-key', 'b96d75ce0f9f342d10af6710ef8ea7ed0ad06');
        res.setBody('[' +
            '{"_id":"619683d69402c24f000aaaaa","Part Name":"AAA","Total Quantity Shipped":789},' +
            '{"_id":"619643769402c24f000bbbbb","Part Name":"BBB","Total Quantity Shipped":960},' +
            '{"_id":"629989816a50f02a000ccccc","Part Name":"CCC","Total Quantity Shipped":12},'+
            '{"_id":"619643919402c24f000ddddd","Part Name":"DDD","Total Quantity Shipped":56},' +
            '{"_id":"62998ecc6a50f02a000eeeee","Part Name":"EEE","Total Quantity Shipped":99, "Active":true}' +
            ']');
        res.setStatusCode(200);
        return res;
    }
}