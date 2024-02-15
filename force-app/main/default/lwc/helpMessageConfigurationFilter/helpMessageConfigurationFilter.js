/**
 * @description       : javascript file for support with management of the help message configuration filters
 * @author            : daniel@hyphen8.com
 * @last modified on  : 15-02-2024
 * @last modified by  : daniel@hyphen8.com
**/
import { LightningElement, api } from 'lwc';

export default class HelpMessageConfigurationFilter extends LightningElement {
    @api condition;
    @api fieldList;
    @api filterType;
    @api conditionCount;
    selectededOperator;
    selectedFieldAPIName;
    selectedFieldLabel;
    selectedFieldDataType;
    fieldSearchResults;
    
    get operatorDisabled(){
        if(this.selectedFieldAPIName){
            return false;
        } else {
            return true;
        }
    }

    get operatorOptions() {
        if(this.selectedFieldDataType == 'STRING' || this.selectedFieldDataType == 'ID'){
            return [
                { label: 'Equals', value: 'EQUALS' },
                { label: 'Not Equals', value: 'NOTEQUALS' },
            ];
        } else {
            return [
                { label: 'Equals', value: 'EQUALS' },
                { label: 'Not Equals', value: 'NOTEQUALS' },
                { label: 'Great than', value: 'GREATERTHAN' },
                { label: 'Greater than and equals', value: 'GREATERTHANANDEQUALS' },
                { label: 'Less than', value: 'LESSTHAN' },
                { label: 'Less than and equals', value: 'LESSTHANANDEQUALS' },
            ];
        }
    }

    get displayConditionCount(){
        if(this.filterType == 'CUSTOM' || (null != this.condition && this.condition.order != 1)){
            return true;
        } else {
            return false;
        }
    }

    get conditionValue(){
        if(this.filterType == 'CUSTOM'){
            return this.condition.order;
        } else {
            return this.filterType;
        }
    }

    get disableDelete(){
        if(this.condition.order == 1 && this.conditionCount == 1){
            return true;
        } else {
            return false;
        }
    }

    handleOperatorSelection(event){
        this.selectededOperator = event.target.value;
    }

    selectFieldFromResultsResult(event){
        const selectedField = event.currentTarget.dataset.value;
        let fieldDetails = this.fieldList.find(
            (fieldOption) => fieldOption.value === selectedField
        );
        this.selectedFieldAPIName = fieldDetails.value;
        this.selectedFieldLabel = fieldDetails.label;
        this.selectedFieldDataType = fieldDetails.fieldType;
        this.clearFieldSearchResults();
    }

    clearFieldSearchResults() {
        this.fieldSearchResults = null;
    }

    searchFields(event){
        const input = event.detail.value.toLowerCase();
        const result = this.fieldList.filter((fieldOption) =>
            fieldOption.label.toLowerCase().includes(input)
        );
        this.fieldSearchResults = result;
    }

    showListOfField(event){
        if (!this.fieldSearchResults) {
            this.fieldSearchResults = this.fieldList;
        }
    }
}