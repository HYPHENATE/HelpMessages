/**
 * @description       : javascript file for outputting the individual help message record
 * @author            : daniel@hyphen8.com
 * @last modified on  : 14-02-2024
 * @last modified by  : daniel@hyphen8.com
**/
import { LightningElement, api } from 'lwc';


import changeMessageStatus from '@salesforce/apex/HelpMessageController.changeMessageStatus';
import generateViewRecord from '@salesforce/apex/HelpMessageController.generateViewEntry';
import submitLike from '@salesforce/apex/HelpMessageController.submitLike';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { reduceErrors } from 'c/helpMessageUtils';
import labels from 'c/helpMessageLabels';

export default class HelpMessageRecord extends NavigationMixin(LightningElement) {
    @api helpMessage;
    @api displayViewCount = false;
    @api displayLikeCount = false;
    @api displayActions = false;
    label = labels;


    get likeCountText(){
        if(this.helpMessage.likeCount == 1){
            return labels.HelpMessageLike;
        } else {
            return labels.HelpMessageLikes;
        }
    }

    get viewCountText(){
        if(this.helpMessage.viewCount == 1){
            return labels.HelpMessageView;
        } else {
            return labels.HelpMessageViews;
        }
    }


    // function that supports with the onclick on an accordion section
    handleAccordSectionClick(){
        this.handleGenerateViewRecord();
    }

    // apex method to log a view of a help message
    handleGenerateViewRecord() {
        generateViewRecord({
            helpMessageId: this.helpMessage.id
        })
        .then((results) => {
            this.dispatchEventFunction('refresh');
        })
        .catch((error) => {});
    }

    // on click action to trigger submitting a like
    likeHelpMessage(){
        this.handleSubmitLike();
    }

    // apex function to handle submitting and unsubbmitting a like
    handleSubmitLike() {
        submitLike({
           helpMessageId: this.helpMessage.id
        })
        .then((results) => {
            this.dispatchEventFunction('refresh');
        })
        .catch((error) => {});
    }

    // handle the edit message button
    editMessage(){
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.helpMessage.id,
                objectApiName: 'Help_Message__c', 
                actionName: 'edit'
            }
        });
    }

    // handle the view message button
    viewMessage(){
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.helpMessage.id,
                objectApiName: 'Help_Message__c', 
                actionName: 'view'
            }
        });
    }

    // handle publish action
    publishMessage(){
        changeMessageStatus({
            recordId: this.helpMessage.id,
            status: 'Published'
        })
        .then((results) => {
            let resultJSON = JSON.parse(results);
            if(resultJSON.message == 'You have successfully changed the status'){
                this.showToast('Success', resultJSON.message, 'success');
            } else {
                this.showToast('Error', resultJSON.message, 'error');
            }
            this.dispatchEventFunction('refresh');
        })
        .catch((error) => {
            this.showToast('Error publishing messages', reduceErrors(error).toString(), 'error');
            this.errors = JSON.stringify(error);
        });
    }

    // handle unpublish action
    unpublishMessage(event){
        changeMessageStatus({
            recordId: this.helpMessage.id,
            status: 'Unpublished'
        })
        .then((results) => {
            let resultJSON = JSON.parse(results);
            if(resultJSON.message == 'You have successfully changed the status'){
                this.showToast('Success', resultJSON.message, 'success');
            } else {
                this.showToast('Error', resultJSON.message, 'error');
            }
            this.dispatchEventFunction('refresh');
        })
        .catch((error) => {
            this.showToast('Error unpublishing messages', reduceErrors(error).toString(), 'error');
            this.errors = JSON.stringify(error);
        });
    }

    // generic dispatch event function
    dispatchEventFunction(eventName, eventDetail) {
       this.dispatchEvent(new CustomEvent(eventName, { eventDetail }));
    }

    // generic dispatch toast event
    showToast(toastTitle, toastMessage, toastVariant){
       this.dispatchEvent(new ShowToastEvent({title: toastTitle, message: toastMessage, variant: toastVariant}));
    }
}