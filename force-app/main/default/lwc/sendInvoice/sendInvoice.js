import { LightningElement, api, wire} from 'lwc';
import LightningModal from "lightning/modal";
import { getRecord, getFieldValue } from "lightning/uiRecordApi";

import ACCOUNT_ID_FIELD from "@salesforce/schema/Invoice__c.Billing_Account__c";

export default class SendInvoice extends LightningElement {
	@api recordId;
	modalHeaderLabel = 'Send Invoice';
	searchContactFilter = {};
	contactDisplayInfo = {
		primaryField: 'Name',
		additionalFields: ['Title'],
	};

	@wire(getRecord, {
		recordId: '$recordId',
		fields: [ACCOUNT_ID_FIELD]
	})
	invoice({ error, data }) {
		if (data) {
			console.log("Invoice: ", data);
			let accountId = getFieldValue(data, ACCOUNT_ID_FIELD);
			console.log("accountId: ", accountId);
			this.searchContactFilter = {
				criteria: [
					{
						fieldPath: 'AccountId',
						operator: 'eq',
						value: accountId,
					}
				]
			};
		} else if (error) {
		  console.error("Error fetching invoice data: ", error);
		}
	}

	handleContactChange(event) {
		console.log(' KM ====>  handleContactChange ', event.detail);
	}

	handleSend(event) {
		console.log(' KM ====>  send Invoice ');
	}
}