import { LightningElement, track, api, wire } from 'lwc';

import getHelpMessages from '@salesforce/apex/HelpMessageController.getHelpMessages';
import canViewRecordActions from '@salesforce/apex/HelpMessageController.canViewRecordActions';
import changeMessageStatus from '@salesforce/apex/HelpMessageController.changeMessageStatus';
import NoHelpAvailable from '@salesforce/label/c.NoHelpMessagesAvailable';
import DraftTextMessage from '@salesforce/label/c.HelpMessageDraftMessage';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class helpMessage extends NavigationMixin(LightningElement) {

    label = {
        NoHelpAvailable,
        DraftTextMessage,
    };
    
    @api recordId;

    @track messages;
    @track errors;
    @track displayactions = false;

    // method to pull in the messages to display
    handleGetHelpMessages() {
        getHelpMessages({
            recordId: this.recordId
        })
        .then((results) => {
            this.messages = results;
            this.errors = undefined;  
        })
        .catch((error) => {
            this.errors = JSON.stringify(error);
            this.messages = undefined;
        });
    }

    // method to check if the current user is an editor
    handlecanViewRecordActions() {
        canViewRecordActions({})
        .then((results) => {
            this.displayactions = results;
            this.errors = undefined;  
        })
        .catch((error) => {
            this.errors = JSON.stringify(error);
            this.displayactions = undefined;
        });
    }

    // check to see if there were any messages
    get hasAnyMessageResults() {
        return this.messages.length > 0;
    }

    connectedCallback() {
        this.handleRefresh();        
    }

    errorCallback(error) {
        this.errors = error;
    }

    // handle the refresh button
    handleRefresh() {
        this.handleGetHelpMessages();  
        this.handlecanViewRecordActions();     
    }

    // handle the edit message button
    editmessage(event){
        let messageid = event.target.value;
        window.console.log('edit message id > ' + messageid);
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: messageid,
                objectApiName: 'Help_Message__c', 
                actionName: 'edit'
            }
        });
    }

    // handle the view message button
    viewmessage(event){
        let messageid = event.target.value;
        window.console.log('view message id > ' + messageid);
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: messageid,
                objectApiName: 'Help_Message__c', 
                actionName: 'view'
            }
        });
    }

    // handle publish action
    publishmessage(event){
        let messageid = event.target.value;
        changeMessageStatus({
            recordId: messageid,
            status: 'Published'
        })
        .then((results) => {
            if(results == 'You have successfully changed the status'){
                const evt = new ShowToastEvent({
                    title: 'Success',
                    message: results,
                    variant: 'success',
                });
                this.dispatchEvent(evt);
            } else {
                const evt = new ShowToastEvent({
                    title: 'Error',
                    message: results,
                    variant: 'error',
                });
                this.dispatchEvent(evt);
            }
            this.handleRefresh();
        })
        .catch((error) => {
            this.errors = JSON.stringify(error);
        });
    }

    // handle unpublish action
    unpublishmessage(event){
        let messageid = event.target.value;
        changeMessageStatus({
            recordId: messageid,
            status: 'Unpublished'
        })
        .then((results) => {
            if(results == 'You have successfully changed the status'){
                const evt = new ShowToastEvent({
                    title: 'Success',
                    message: results,
                    variant: 'success',
                });
                this.dispatchEvent(evt);
            } else {
                const evt = new ShowToastEvent({
                    title: 'Error',
                    message: results,
                    variant: 'error',
                });
                this.dispatchEvent(evt);
            }
            this.handleRefresh();
        })
        .catch((error) => {
            this.errors = JSON.stringify(error);
        });
    }
}