/**
 * @description       : javascript for core help messages component
 * @author            : daniel@hyphen8.com
 * @last modified on  : 14-02-2024
 * @last modified by  : daniel@hyphen8.com
**/
import { LightningElement, track, api, wire } from 'lwc';

import getHelpMessages from '@salesforce/apex/HelpMessageController.getHelpMessages';
import canViewRecordActions from '@salesforce/apex/HelpMessageController.canViewRecordActions';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getRecord } from "lightning/uiRecordApi";
import { reduceErrors } from 'c/helpMessageUtils';
import labels from 'c/helpMessageLabels';
export default class helpMessage extends LightningElement {

    label = labels;
    
    @api recordId;
    @api objectApiName;
    @api selectedIcon = 'utility:help';
    @api componentTitle = 'Help Messages';
    @api displayViewCount = false;
    @api displayLikeCount = false;

    messages;
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
            this.showToast('Error accessing record', reduceErrors(error).toString(), 'error');
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
        })
        .catch((error) => {
            this.showToast('Error getting messages', reduceErrors(error).toString(), 'error');
            this.messages = undefined;
        });
    }

    // method to check if the current user is an editor
    handleCanViewRecordActions() {
        canViewRecordActions({})
        .then((results) => {
            let resultsJSON = JSON.parse(results);
            this.displayActions = resultsJSON.success;
        })
        .catch((error) => {
            this.showToast('Error chercking permissions', reduceErrors(error).toString(), 'error');
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
        this.showToast('Error loading component', reduceErrors(error).toString(), 'error');
    }

    // handle the refresh button
    handleRefresh() {
        this.handleGetHelpMessages();  
        this.handleCanViewRecordActions();     
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

    // generic dispatch toast event
    showToast(toastTitle, toastMessage, toastVariant){
       this.dispatchEvent(new ShowToastEvent({title: toastTitle, message: toastMessage, variant: toastVariant}));
    }
}