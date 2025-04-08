import { LightningElement, api, wire} from 'lwc';
import { CloseActionScreenEvent } from "lightning/actions";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { RefreshEvent } from 'lightning/refresh';
import generateInvoice from '@salesforce/apex/GenerateInvoiceController.generateInvoice';
import obtainTemplates from '@salesforce/apex/GenerateInvoiceController.obtainTemplates';

export default class GenerateInvoice extends LightningElement {

	@api recordId;
	templates;
	options;
	selectedTemplate;

	get selectedTemplateId() {
		return this.selectedTemplate ? this.selectedTemplate.Id : '';
	}

	get selectedTemplateExtension() {
		return this.selectedTemplate ? this.selectedTemplate.FileExtension : '';
	}

	@wire(obtainTemplates, {})
	obtainTemplates(result, error) {
		if (result?.data?.isSuccess) {
			console.log(' KM ====>  result ', result.data);
			this.templates = result.data.responseObj;
			this.options = this.templates.map(template => {
				return {
					label: template.Title,
					value: template.Id
				}
			});
		} else if (error) {
			console.error('Obtain templates Error', error);
		}
	}

	connectedCallback() {
		//obtainTemplates().then(result => {
		//	console.log(' KM ====>  result ', result);
		//	this.templates = result;
		//	if (result.isSuccess) {
		//		this.templates = result.responseObj;
		//		this.options = this.templates.map(template => {
		//			return {
		//				label: template.Title,
		//				value: template.Id
		//			}
		//		});
		//	}
		//}).catch(error => {
		//	console.error('Invoice generating Error', error);
		//});
	}

	handleTemplateChange(event) {
		//this.selectedTemplate = {
		//	Id: event.detail.value,
		//	Title: event.detail.label
		//};
		this.selectedTemplate = this.templates.find(template => {
			return template.Id === event.detail.value;
		});
	}
	
	//originalMessage;
	//confirmationMessage = "Are you sure you want to generate invoice?";
	//isLoading = false;

	handleClick(event) {
		//if(event.detail.status === 'confirm') {
			console.log(' KM ====>  confirm ', );
			//generateInvoice({recordId : this.recordId}).then(result => {
			//	this.isLoading = true;
			//	console.log(' KM ====>  result ', result);
			//	setTimeout(() => {
			//		console.log(' KM ====>  setTimeout ' );
			//	}, 2000);
			//	if (result.isSuccess) {
			//		this.dispatchEvent(new RefreshEvent());
			//		this.showToastEvent('Success', result.message, 'success');
			//	} else {
			//		this.showToastEvent('Error', result.message, 'error');
			//	}
			//})
			const params = {
				recordId: this.recordId,
				templateId: this.selectedTemplateId,
				templateExtension: this.selectedTemplateExtension
			};
			console.log(' KM ====>  params ', params);
			generateInvoice(params)
			.then(result => {
				this.isLoading = true;
				console.log(' KM ====>  result ', result);
			})
			.catch(error => {
					console.error('Invoice generating Error', error);
					let errorMessage = error.body?.message ? error.body.message : error.message;
					this.showToastEvent('Error', errorMessage, 'error');
			}).finally(() => {
				this.isLoading = false;
				this.dispatchEvent(new CloseActionScreenEvent());
			});
		//} else if(event.detail.status === 'cancel'){
		//	console.log(' KM ====>  cancel ', );
		//	this.dispatchEvent(new CloseActionScreenEvent());
		//}
		//this.dispatchEvent(new CloseActionScreenEvent());
	}

	showToastEvent(title, message, type) {
		this.dispatchEvent(
			new ShowToastEvent({
				title: title,
				message: message,
				variant: type,
			}),
		);
	}
}