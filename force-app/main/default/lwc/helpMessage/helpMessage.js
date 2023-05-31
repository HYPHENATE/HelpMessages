/**
 * @description       : help messages JS file
 * @author            : daniel@hyphen8.com
 * @group             : 
 * @last modified on  : 31/05/2023
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
import { getRecord, notifyRecordUpdateAvailable  } from "lightning/uiRecordApi";

import labels from './labels';
export default class helpMessage extends NavigationMixin(LightningElement) {

    label = labels;
    
    @api recordId;
    @api objectApiName;
    @api selectedIcon = 'utility:help';
    @api componentTitle = 'Help Messages';

    messages;
    errors;
    expectedWireList;
    @track wireFieldList = this.fields;
    displayActions = false;

    currentRecord;

    @wire(getRecord, { recordId: "$recordId", fields: '$fields' })
    wiredRecord({ error, data }) {
        if (data) {
            if(null == this.currentRecord){
                this.currentRecord = data.fields;
            } else if(JSON.stringify(this.currentRecord) != JSON.stringify(data.fields)) {
                this.currentRecord = data.fields;
                this.handleRefresh();
            }
        } else if (error) {
            console.error("error getting record", JSON.stringify(error));
        }
    }


    // method to pull in the messages to display
    handleGetHelpMessages() {
        getHelpMessages({
            recordId: this.recordId
        })
        .then((results) => {
            let resultsJSON = JSON.parse(results);
            this.messages = resultsJSON.messages;
            let fieldsArrayJSON = [];
            resultsJSON.fieldArray.forEach(item => fieldsArrayJSON.push(item.fieldAPIName));
            this.expectedWireList = fieldsArrayJSON;
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
            let resultsJSON = JSON.parse(results);
            this.displayActions = resultsJSON.success;
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
            let resultJSON = JSON.parse(results);
            if(resultJSON.message == 'You have successfully changed the status'){
                const evt = new ShowToastEvent({
                    title: 'Success',
                    message: resultJSON.message,
                    variant: 'success',
                });
                this.dispatchEvent(evt);
            } else {
                const evt = new ShowToastEvent({
                    title: 'Error',
                    message: resultJSON.message,
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
            let resultJSON = JSON.parse(results);
            if(resultJSON.message == 'You have successfully changed the status'){
                const evt = new ShowToastEvent({
                    title: 'Success',
                    message: resultJSON.message,
                    variant: 'success',
                });
                this.dispatchEvent(evt);
            } else {
                const evt = new ShowToastEvent({
                    title: 'Error',
                    message: resultJSON.message,
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


    // function to support dynamic wire methods with fields driven by apex controller for filters detection of changes
    get fields() {
        if (null == this.expectedWireList && null != this.objectApiName) {
            let baseFieldValue = this.objectApiName + '.Id';
            return baseFieldValue;
        } else if(null != this.expectedWireList) {
            return this.expectedWireList;
        } else {
            return 'Id';
        }
    }
}