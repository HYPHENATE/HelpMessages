/**
 * @description       : javascript file for controlling and setting up help message filters
 * @author            : daniel@hyphen8.com
 * @last modified on  : 13-02-2024
 * @last modified by  : daniel@hyphen8.com
**/
import { LightningElement, api } from 'lwc';

export default class HelpMessageFilters extends LightningElement {
    @api recordId;
    isLoading = true;
}