public with sharing class InvoiceTemplateRenderer implements ITemplateRenderer {

	public String render(String templateContent, IInvoiceDataProvider dataProvider) {
		List<Invoice_Template_Mapping__mdt	> mappingList = Invoice_Template_Mapping__mdt.getAll().values();
		for (Invoice_Template_Mapping__mdt	 mapping : mappingList) {
			Object fieldValue = dataProvider.getFieldValue(mapping.Template_Placeholder__c);
			System.debug(' KM ====>   fieldValue ' + fieldValue);
			templateContent = templateContent.replace(mapping.Template_Placeholder__c,  String.valueOf(fieldValue));
		}
		return templateContent;
	}
}