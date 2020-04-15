import { LightningElement, track, api, wire } from 'lwc';

import getHelpMessages from '@salesforce/apex/HelpMessageController.getHelpMessages';
import NoHelpAvailable from '@salesforce/label/c.NoHelpMessagesAvailable';
import DraftTextMessage from '@salesforce/label/c.HelpMessageDraftMessage';

export default class helpMessage extends LightningElement {

    label = {
        NoHelpAvailable,
        DraftTextMessage,
    };
    
    @api recordId;

    @track messages;
    @track errors;

    handleGetHelpMessages() {
        getHelpMessages({
            recordId: this.recordId
        })
        .then((results) => {
            window.console.log('results > ' + results);
            this.messages = results;
            this.errors = undefined;  
        })
        .catch((error) => {
            this.errors = JSON.stringify(error);
            this.messages = undefined;
        });
    }

    get hasAnyMessageResults() {
        return this.messages.length > 0;
    }

    connectedCallback() {
        this.handleRefresh();        
    }

    errorCallback(error) {
        this.errors = error;
    }

    handleRefresh() {
        this.handleGetHelpMessages();       
    }
}