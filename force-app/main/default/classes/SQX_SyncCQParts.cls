/********************************************************************************************************************
 * Create By  : Pooja P Bhat
 * Description: To Sync the Parts Details from External System.
 * CHANGE LOG
 * Date         Story#      ModifiedBy      Reason
 * 15-5-2023                Pooja P Bhat    Class Created to set the mock response.
 *******************************************************************************************************************/
public with Sharing class SQX_SyncCQParts {

    /*******************************************************************************************************
     * Method Name: createCQParts
     * Description: To insert/update Parts Details from External System based of Part Id
     *              a. If ‘Total Quantity Shipped' from callout response < 99, then get account with name = 'High Volume',
     *              b. If ‘Total Quantity Shipped' from callout response >= 99, get account with name = 'Low Volume'
     */
    @AuraEnabled
    public static String createCQParts() {
        Boolean hasCustomPermission = FeatureManagement.checkPermission(SQX_ConstantsUtility.INTEGRATION_ADMIN);
        List<SQX_Part__c> lst_UpsertParts = new List<SQX_Part__c>();
        List<SQX_CQPartsParser> lst_CQParts = SQX_RestCallouts.makeGetCallout();
        String message = 'Sync was successful.'; 

        if (hasCustomPermission) {    
            try {
                if(!lst_CQParts.isEmpty() && lst_CQParts.size() > 0) {
                    Map<String,Account> mAccounts = new Map<String,Account>();
                    List<Account> lAccounts = [SELECT Id,Name FROM Account WHERE Name=:SQX_ConstantsUtility.HIGH_VOLUME OR Name=:SQX_ConstantsUtility.LOW_VOLUME LIMIT 2];
                    for(Account oAcc : lAccounts) {
                        mAccounts.put(oAcc.Name,oAcc);
                    }
                    System.debug('mAccounts==='+mAccounts.size()+' '+mAccounts);
                    
                    for(SQX_CQPartsParser oParts : lst_CQParts) {
                        System.debug('oParts==='+oParts);
                        if(String.isNotBlank(oParts.partId) && String.isNotBlank(oParts.partName) && oParts.totalQuantityShipped!=null) {
                            SQX_Part__c oQcPart = new SQX_Part__c(Name=oParts.partName,SQX_Part_Number__c=oParts.partId);
                            if(!mAccounts.isEmpty() && mAccounts.containsKey(SQX_ConstantsUtility.LOW_VOLUME) && mAccounts.containsKey(SQX_ConstantsUtility.HIGH_VOLUME)) {
                                oQcPart.SQX_Related_Account__c = oParts.totalQuantityShipped >= SQX_ConstantsUtility.PARTS_UPPERBOUND 
                                                                    ? mAccounts.get(SQX_ConstantsUtility.LOW_VOLUME).Id 
                                                                    : mAccounts.get(SQX_ConstantsUtility.HIGH_VOLUME).Id;
                            }
                            lst_UpsertParts.add(oQcPart);
                        }
                    }
                }
                
                Schema.SObjectField exIdField = SQX_Part__c.Fields.SQX_Part_Number__c;
                if(lst_UpsertParts.size() > 0) {
                    Database.upsert(lst_UpsertParts,exIdField,false);
                }
            } catch (Exception ex) {
                message = 'Something went wrong while syncing process. Contact your Admin.';
                System.debug('Exception while syncing CQ PARTS = ' + ex.getLineNumber() + ' ' + ex.getMessage());
            }
        } else {
            message = 'You dont have required permission to sync the QC Parts.';
        }
        return message;
    }
    
}