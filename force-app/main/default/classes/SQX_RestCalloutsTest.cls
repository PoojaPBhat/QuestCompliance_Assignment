/********************************************************************************************************************
 * Create By  : Pooja P Bhat
 * Description: Test class to cover unit test for Class SQX_RestCallouts
 * CHANGE LOG
 * Date         Story#      ModifiedBy      Reason
 * 15-5-2023                Pooja P Bhat    Class Created to attain code coverage and unit test method functionality
 *******************************************************************************************************************/
@isTest
public class SQX_RestCalloutsTest {
	@isTest
    static void testMethod1(){
        Test.setMock(HttpCalloutMock.class, new SQX_RestMockCallouts());
        
        List<SQX_CQPartsParser> parserList =  SQX_RestCallouts.makeGetCallout();
        
        Assert.isTrue(parserList.size()==5,'Callout Response returned less/more than 5 elements');
        Assert.isFalse(parserList.size()>5,'Callout Response has no more than 5 elements');
    }
}