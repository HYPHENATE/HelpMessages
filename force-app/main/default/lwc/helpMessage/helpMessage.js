/**
 * @description       : help messages JS file
 * @author            : daniel@hyphen8.com
 * @group             : 
 * @last modified on  : 01-08-2021
 * @last modified by  : daniel@hyphen8.com
 * Modifications Log 
 * Ver   Date         Author               Modification
 * 1.0   01-08-2021   daniel@hyphen8.com   Initial Version
**/
import { LightningElement, track, api, wire } from 'lwc';

import getHelpMessages from '@salesforce/apex/HelpMessageController.getHelpMessages';
import canViewRecordActions from '@salesforce/apex/HelpMessageController.canViewRecordActions';
import changeMessageStatus from '@salesforce/apex/HelpMessageController.changeMessageStatus';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import labels from './labels';
export default class helpMessage extends NavigationMixin(LightningElement) {

    label = labels;
    
    @api recordId;

    messages;
    errors;
    displayActions = false;

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
    handleCanViewRecordActions() {
        canViewRecordActions({})
        .then((results) => {
            this.displayActions = results;
            this.errors = undefined;  
        })
        .catch((error) => {
            this.errors = JSON.stringify(error);
            this.displayActions = undefined;
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
        this.handleCanViewRecordActions();     
    }

    // handle the edit message button
    editMessage(event){
        let messageId = event.target.value;
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: messageId,
                objectApiName: 'Help_Message__c', 
                actionName: 'edit'
            }
        });
    }

    // handle the view message button
    viewMessage(event){
        let messageId = event.target.value;
        window.console.log('view message id > ' + messageId);
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: messageId,
                objectApiName: 'Help_Message__c', 
                actionName: 'view'
            }
        });
    }

    // handle publish action
    publishMessage(event){
        let messageId = event.target.value;
        changeMessageStatus({
            recordId: messageId,
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
    unpublishMessage(event){
        let messageId = event.target.value;
        changeMessageStatus({
            recordId: messageId,
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