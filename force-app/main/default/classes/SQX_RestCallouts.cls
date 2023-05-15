/********************************************************************************************************************
 * Create By  : Pooja P Bhat
 * Description: Makes call to External System to get the details abouts QC Parts
 * CHANGE LOG
 * Date         Story#      ModifiedBy      Reason
 * 15-5-2023                Pooja P Bhat    Class Created. Rest GET method defined.
 *******************************************************************************************************************/
public class SQX_RestCallouts {
	public static List<SQX_CQPartsParser> makeGetCallout() {
        Http http = new Http();
        
        HttpRequest request = new HttpRequest();
        request.setEndpoint('https://cqparts-3d06.restdb.io/rest/cqpart');
        request.setMethod('GET');
        request.setHeader('Content-Type', 'application/json;charset=UTF-8');
        request.setHeader('x-api-key', 'b96d75ce0f9f342d10af6710ef8ea7ed0ad06');

        HttpResponse response = http.send(request);
        
        List<SQX_CQPartsParser> lst_CQParts = new List<SQX_CQPartsParser>();
        if (response.getStatusCode() == 200 && response.getBody()!=null) {
           lst_CQParts = SQX_CQPartsParser.parse(response.getBody());
        }
        
        return lst_CQParts;
    }
}