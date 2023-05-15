import { LightningElement } from 'lwc';
import syncParts from '@salesforce/apex/SQX_SyncCQParts.createCQParts';
import {ShowToastEvent} from "lightning/platformShowToastEvent";
import isIntegrationAdmin from '@salesforce/customPermission/Integration_Admin';

export default class SqxSyncQCPartsLWC extends LightningElement {

    syncQCParts() {
        if(isIntegrationAdmin) {
            syncParts()
                .then(result => {
                    let msg = result;
                    let msgTitle = ((msg !== undefined && msg !== null && msg !== "" && msg.toLowerCase().includes('successful')) ? 'Success' : 'Error');
                    let msgVariant = ((msg !== undefined && msg !== null && msg !== "" && msg.toLowerCase().includes('successful')) ? 'success' : 'error');
                    this.dispatchEvent( new ShowToastEvent({
                        title   : msgTitle,
                        message : msg,
                        variant : msgVariant
                    }));

                })
                .catch(error => {
                    this.dispatchEvent( new ShowToastEvent({
                        title   :   'Error',
                        message :   error.message,
                        variant :   'error'
                    }));
                });
        } else {
            this.dispatchEvent( new ShowToastEvent({
                title   :   'Error',
                message :   'You dont have required permission to sync the QC Parts!',
                variant :   'error'
            }));
        }
    }
}