public with sharing class InvoiceDataProvider implements IInvoiceDataProvider {

	private Invoice__c invoice;
	private Map<String, Object> templatePlaceholderToValueMap;
	private static final String INVOICE_OBJ = 'Invoice__c';
	private static final String INVOICE_LINE = 'Invoice_Line__c';
	private static final String USER = 'User';
	private static final String ACCOUNT = 'Account';
	private static final String ADDRESS = 'Address';
	private static final String BILLING_ADDRESS = 'BillingAddress';
	private static final String PAYMENT_INSTRUCTION = 'Payment_Instruction__c';
	private static final String INVOICE_LINES_DATA = 'InvoiceLinesData';


	public InvoiceDataProvider(String invoiceId) {
		this.invoice = obtainInvoice(invoiceId);
		this.templatePlaceholderToValueMap = createMapping();
	}

	public Invoice__c getInvoiceObject() {
		return this.invoice;
	}

	public Object getFieldValue(String placeholder) {
		return this.templatePlaceholderToValueMap.containsKey(placeholder) ? this.templatePlaceholderToValueMap.get(placeholder) : '';
	}

	public Map<String, Object> getPlaceholderToValueMap() {
		return this.templatePlaceholderToValueMap;
	}

	private Map<String, Object> createMapping() {
		Map<String, Object> templatePlaceholderToValueMap = new Map<String, Object>();
		List<Invoice_Template_Mapping__mdt	> mappingList = Invoice_Template_Mapping__mdt.getAll().values();
		List<Invoice_Template_Mapping__mdt> invoiceLineMappingList = new List<Invoice_Template_Mapping__mdt>();

		User owner = UserService.getUserById(this.invoice.OwnerId);
		Account billingAccount = this.invoice.Billing_Account__r;
		Payment_Instruction__c payment = this.invoice.Payment_Instruction__r;

		for (Invoice_Template_Mapping__mdt	 mapping : mappingList) {
			if (mapping.Field__c == null || mapping.Template_Placeholder__c == null) {
				continue;
			}
			String objectType = mapping.Object__c;
			String field = mapping.Field__c;
			String placeholder = mapping.Template_Placeholder__c;

			Object value;

			if (objectType == INVOICE_OBJ) {
				value = this.invoice.get(field);
			}
			else if (objectType == USER) {
				value = (field == ADDRESS) ? formatAddress(owner.Address) : owner.get(field);
			}
			else if (objectType == ACCOUNT) {
				value = (field == 'BillingAddress') ? formatAddress(billingAccount.BillingAddress) : billingAccount.get(field);
			}
			else if (objectType == PAYMENT_INSTRUCTION) {
				value = payment.get(field);
			}
			else if (objectType == INVOICE_LINE) {
				invoiceLineMappingList.add(mapping);
				continue;
			}
			else {
				throw new InvoiceDataProviderException('Unknown object type: ' + objectType);
			}
			templatePlaceholderToValueMap.put(placeholder, value);
		}

		List<Map<String, Object>> invoiceLineValuesList = new List<Map<String, Object>>();
		for (Invoice_Line__c invoiceLine : this.invoice.Invoice_Lines__r) {
			Map<String, Object> invoiceLinePlaceholderToValueMap = new Map<String, Object>();
			for (Invoice_Template_Mapping__mdt invoiceLineMapping : invoiceLineMappingList) {
				invoiceLinePlaceholderToValueMap.put(invoiceLineMapping.Template_Placeholder__c, invoiceLine.get(invoiceLineMapping.Field__c));
			}
			invoiceLineValuesList.add(invoiceLinePlaceholderToValueMap);
		}
		templatePlaceholderToValueMap.put(INVOICE_LINES_DATA, invoiceLineValuesList);
		return templatePlaceholderToValueMap;
	}

	private String formatAddress(System.Address address) {
		return address.getStreet() + ', ' + 
			   address.getCity() + ', ' + 
			   address.getPostalCode() + ', ' + 
			   address.getCountry();
	}

	private Invoice__c obtainInvoice(String invoiceId) {
		return [SELECT Id
					, Name
					, Invoice_Number__c
					, Invoice_Date__c
					, Due_Date__c
					, Total_Amount__c
					, Currency__c
					, Payment_Instruction__c
					, Payment_Status__c
					, Payment_Date__c
					, OwnerId
					, Billing_Account__r.Name
					, Billing_Account__r.Company_Id__c
					, Billing_Account__r.BillingAddress
					, Payment_Instruction__r.Name
					, Payment_Instruction__r.Payment_Form__c
					, Payment_Instruction__r.Bank_Name__c
					, Payment_Instruction__r.IBAN_Number__c
					, Payment_Instruction__r.Swift_Code__c
					, Payment_Instruction__r.Intermediary_Bank_Name__c
					, Payment_Instruction__r.Intermediary_Bank_Swift_Code__c
					, Payment_Instruction__r.Remarks__c
					, (SELECT Id
							, Name
							, Description__c
							, Unit_Cost__c
							, Quantity__c
							, Amount__c
						FROM Invoice_Lines__r)
				FROM Invoice__c 
				WHERE Id = :invoiceId
				WITH SECURITY_ENFORCED];
	}

	public class InvoiceDataProviderException extends Exception {}
}