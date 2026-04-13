import { createElement } from 'lwc';
import HelpMessage from 'c/helpMessage';
import { registerLdsTestWireAdapter } from '@salesforce/sfdx-lwc-jest';
import { getRecord } from 'lightning/uiRecordApi';

import getHelpMessages from '@salesforce/apex/HelpMessageController.getHelpMessages';
import canViewRecordActions from '@salesforce/apex/HelpMessageController.canViewRecordActions';

jest.mock(
    '@salesforce/apex/HelpMessageController.getHelpMessages',
    () => ({ default: jest.fn() }),
    { virtual: true }
);

jest.mock(
    '@salesforce/apex/HelpMessageController.canViewRecordActions',
    () => ({ default: jest.fn() }),
    { virtual: true }
);

jest.mock(
    '@salesforce/apex/HelpMessageController.changeMessageStatus',
    () => ({ default: jest.fn() }),
    { virtual: true }
);

const getRecordAdapter = registerLdsTestWireAdapter(getRecord);

const flushPromises = () => new Promise((resolve) => setImmediate(resolve));

describe('c-help-message ordering', () => {
    afterEach(() => {
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }
        jest.clearAllMocks();
    });

    it('sorts messages by the `order` field', async () => {
        const apexPayload = {
            fieldArray: [{ fieldAPIName: 'Account.Id' }],
            messages: [
                { id: 'a', title: 'Second', message: '2', isDraft: false, order: 2 },
                { id: 'b', title: 'First', message: '1', isDraft: false, order: 1 },
                { id: 'c', title: 'Third', message: '3', isDraft: false, order: 3 }
            ]
        };

        getHelpMessages.mockResolvedValue(JSON.stringify(apexPayload));
        canViewRecordActions.mockResolvedValue(JSON.stringify({ success: false, message: '' }));

        const element = createElement('c-help-message', { is: HelpMessage });
        element.recordId = '001000000000001AAA';
        element.objectApiName = 'Account';
        document.body.appendChild(element);

        getRecordAdapter.emit({ fields: { Id: { value: element.recordId } } });
        await flushPromises();

        const sections = Array.from(
            element.shadowRoot.querySelectorAll('lightning-accordion-section')
        ).map((section) => section.label || section.getAttribute('label'));

        expect(sections).toEqual(['First', 'Second', 'Third']);
    });
});
