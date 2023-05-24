trigger CQPartTrigger on SQX_Part__c (before insert, before update) {

    if(trigger.isBefore) {
        if(trigger.isInsert || trigger.isUpdate) {
            Map<String,Account> mAccounts = new Map<String,Account>();
            List<Account> lAccounts = [SELECT Id,Name FROM Account WHERE Name=:SQX_ConstantsUtility.HIGH_VOLUME OR Name=:SQX_ConstantsUtility.LOW_VOLUME LIMIT 2];
            for(Account oAcc : lAccounts) {
                mAccounts.put(oAcc.Name,oAcc);
            }
            System.debug('mAccounts==='+mAccounts.size()+' '+mAccounts);
            for(SQX_Part__c oParts : trigger.new) {
                System.debug('oParts==='+oParts);
                if(oParts.SQX_Total_Quantity_Shipped__c!=null) {
                    if(!mAccounts.isEmpty() && mAccounts.containsKey(SQX_ConstantsUtility.LOW_VOLUME) && mAccounts.containsKey(SQX_ConstantsUtility.HIGH_VOLUME)) {
                        oParts.SQX_Related_Account__c = oParts.SQX_Total_Quantity_Shipped__c >= SQX_ConstantsUtility.PARTS_UPPERBOUND 
                                                            ? mAccounts.get(SQX_ConstantsUtility.LOW_VOLUME).Id 
                                                            : mAccounts.get(SQX_ConstantsUtility.HIGH_VOLUME).Id;
                    }
                }
            }
        }
    }
    
}