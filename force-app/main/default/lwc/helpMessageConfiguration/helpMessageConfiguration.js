/**
 * @description       : javascript to support with the configuration of a help message and associated filters
 * @author            : daniel@hyphen8.com
 * @last modified on  : 15-02-2024
 * @last modified by  : daniel@hyphen8.com
**/
import { LightningElement, api, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getRecord } from 'lightning/uiRecordApi';
import { reduceErrors } from 'c/helpMessageUtils';
import labels from 'c/helpMessageLabels';
import getSalesforceObject from '@salesforce/apex/HelpMessageConfigurationHelper.getListOfSalesforceObjects';
import getFieldList from '@salesforce/apex/HelpMessageConfigurationHelper.getSelectedObjectFields';
import saveConfigurationFields from '@salesforce/apex/HelpMessageConfigurationHelper.saveConfigurationFields';
import getHelpFilters from '@salesforce/apex/HelpMessageConfigurationHelper.getHelpFilters';
import addNewFilterCondition from '@salesforce/apex/HelpMessageConfigurationHelper.addNewFilterCondition';

const FIELDS = ['Help_Message__c.Record_SObjectType__c','Help_Message__c.Records_Valid_For__c','Help_Message__c.Filter_Type__c'];

export default class HelpMessageConfiguration extends LightningElement {
    @api recordId;
    isLoading = true;
    label = labels;
    currentObject;
    objectFieldList;
    currentObjectAPIName;
    currentObjectLabel;
    salesforceObjects;
    recordsValidFor;
    filterType;
    filters;
    objectSearchResults;
    allRecordsBrand = '';
    byFiltersBrand = '';

    get filterConditions() {
        return [
            { label: 'All conditions are met', value: 'AND' },
            { label: 'Any condition is met', value: 'OR' },
            { label: 'Custom logic is met', value: 'CUSTOM' },
        ];
    }

    get disableFilterConditions(){
        if(this.filters.length > 1){
            return false;
        } else {
            return true;
        }
    }

    get filterCount(){
        if(null != this.filters){
            return this.filters.length;
        } else {
            return 0;
        }
    }

    // getter to return the selected object value
    get selectedObjectValue() {
        return this.currentObjectLabel ? this.currentObjectLabel : null;
    }

    get disableRecordsValidFor(){
        if(this.currentObjectAPIName){
            return false;
        } else {
            return true;
        }
    }

    get showConditionManagement(){
        if(this.recordsValidFor === 'By Filter'){
            return true;
        } else {
            return false;
        }
    }

    get displayFilterType(){
        if(this.recordsValidFor === 'By Filter'){
            return false;
        } else {
            return true;
        }
    }

    // wire function to pull back the current record
    @wire(getRecord, { recordId: '$recordId', fields: FIELDS })
    wiredHelpMessage({ error, data }) {
        if (error) {
            this.showToast('Error getting record', reduceErrors(error).toString(), 'error');
        } else if (data) {
            this.currentObject = data.fields.Record_SObjectType__c.value;
            this.recordsValidFor = data.fields.Records_Valid_For__c.value;
            this.filterType = data.fields.Filter_Type__c.value;
            if(this.recordsValidFor){
                this.allRecordsBrand = this.recordsValidFor === 'All' ? 'success' : '';
                this.byFiltersBrand = this.recordsValidFor === 'By Filter' ? 'success' : '';
            }
            if(this.recordsValidFor == 'By Filter'){
                this.handleGetHelpFilters();
            }
            this.handleGetSalesforceObject();
        }
    }

    // apex method to query and return a list of salesforce objects available to the current user
    handleGetSalesforceObject () {
        getSalesforceObject({})
        .then((results) => {
            let jsonParsedResults = JSON.parse(results);
            this.salesforceObjects = jsonParsedResults.objects;
            this.salesforceObjects.sort((a, b) => {
                    if (a.label < b.label)
                        return -1;
                    if (a.label > b.label)
                        return 1;
                    return 0;
                }
            );
            if(this.currentObject){
                let objectDetails = this.salesforceObjects.find(
                    (objectOption) => objectOption.value === this.currentObject
                );
                this.currentObjectAPIName = objectDetails.value;
                this.currentObjectLabel = objectDetails.label; 
                this.handleGetFieldList();
            } else {
                this.isLoading = false;
            }
            
        })
        .catch((error) => {
            this.showToast('Error getting salesforce object list', reduceErrors(error).toString(), 'error');
        });
    }

    handleGetFieldList() {
        getFieldList({
            objectAPIName: this.currentObjectAPIName
        })
        .then((results) => {
            let parsedResults = JSON.parse(results);
            this.objectFieldList = parsedResults.fields;
            this.objectFieldList.sort((a, b) => {
                if (a.label < b.label)
                    return -1;
                if (a.label > b.label)
                    return 1;
                return 0;
            }
        );
            this.isLoading = false;
        })
        .catch((error) => {
            this.showToast('Error getting fields', reduceErrors(error).toString(), 'error');
        });
    }

    // function to search for object
    searchObjects(event) {
        const input = event.detail.value.toLowerCase();
        const result = this.salesforceObjects.filter((objectOption) =>
            objectOption.label.toLowerCase().includes(input)
        );
        this.objectSearchResults = result;
    }

    // function to find the selected value when one is selected
    selectObjectFromResultsResult(event) {
        const selectedObject = event.currentTarget.dataset.value;
        let objectDetails = this.salesforceObjects.find(
            (objectOption) => objectOption.value === selectedObject
        );
        this.currentObjectAPIName = objectDetails.value;
        this.currentObjectLabel = objectDetails.label;
        this.handleSaveConfigurationFields('Record_SObjectType__c', this.currentObjectAPIName);
        this.clearObjectSearchResults();
    }

    // function to clear object results
    clearObjectSearchResults() {
        this.objectSearchResults = null;
    }

    // onfocus on the object search combobox
    showListOfObjects(){
        if (!this.objectSearchResults) {
            this.objectSearchResults = this.salesforceObjects;
        }
    }

    allRecordsSelected(){
        this.allRecordsBrand = 'success';
        this.byFiltersBrand = '';
        this.recordsValidFor = 'All';
        this.handleSaveConfigurationFields('Records_Valid_For__c', 'All');
    }

    byFilterSelected(){
        this.byFiltersBrand = 'success';
        this.allRecordsBrand = '';
        this.recordsValidFor = 'By Filter';
        this.handleSaveConfigurationFields('Records_Valid_For__c', 'By Filter');
    }

    handleFilterSelection(event){
        this.filterType = event.target.value;
        this.handleSaveConfigurationFields('Filter_Type__c', this.filterType);
    }

    handleSaveConfigurationFields(fieldAPIName, inputValue) {
        saveConfigurationFields({
           helpMessageId : this.recordId,
           fieldAPIName : fieldAPIName,
           inputValue : inputValue
        })
        .then((results) => {
            if(this.recordsValidFor == 'By Filter'){
                this.handleGetHelpFilters();
            }
        })
        .catch((error) => {
            this.showToast('Error saving configuration', reduceErrors(error).toString(), 'error');
        });
    }

    // apex function to pull in help message filters
    handleGetHelpFilters() {
        getHelpFilters({
           helpMessageId: this.recordId
        })
        .then((results) => {
            let parsedResults = JSON.parse(results);
            this.filters = parsedResults.filters;
        })
        .catch((error) => {
            this.showToast('Error getting filters', reduceErrors(error).toString(), 'error');
        });
    }

    handleAddNewFilterCondition() {
        addNewFilterCondition({
           helpMessageId: this.recordId,
           filterCount: this.filters.length
        })
        .then((results) => {
            this.handleGetHelpFilters();
        })
        .catch((error) => {
            this.showToast('Error adding new filter', reduceErrors(error).toString(), 'error');
        });
    }

    // generic dispatch toast event
    showToast(toastTitle, toastMessage, toastVariant){
       this.dispatchEvent(new ShowToastEvent({title: toastTitle, message: toastMessage, variant: toastVariant}));
    }
}