/**
 * @description  : 
 * @author       : Kostiantyn Murin
 * @date         : 02-23-2025
**/
public with sharing class InvoicePDFController {

	public Invoice__c invoice { get; set; }
	public String invoiceNumber { get; set; }
	public String invoiceDate { get; set; }
	public InvoiceLineTableWrapper invoiceLineTable { get; set; }
	public List<InvoiceInfo> userInfoList { get; set; }
	public List<InvoiceInfo> customerInfoList { get; set; }
	public List<InvoiceInfo> paymentInstructionList { get; set; }

	private static final String ID = 'ID';
	private static final String NAME = 'NAME';
	private static final String ADDRESS = 'Address';
	private static final String EMAIL = 'Email';
	private static final String PHONE = 'Phone';
	private static final String PAYMENT_FORM = 'Payment Form';
	private static final String BANK_NAME = 'Bank Name';
	private static final String IBAN_NUMBER = 'IBAN Number';
	private static final String SWIFT_CODE = 'Swift Code';
	private static final String INTERMEDIARY_BANK_NAME = 'Intermediary Bank Name';
	private static final String INTERMEDIARY_BANK_SWIFT_CODE = 'Intermediary Bank Swift Code';
	private static final String DESCRIPTION = 'DESCRIPTION';
	private static final String UNIT_COST = 'UNIT COST';
	private static final String VAT = 'VAT';
	private static final String QTY = 'QTY';
	private static final String AMOUNT = 'AMOUNT';
	private static final String INVOICE_CURRENCY = 'CURRENCY';

	public InvoicePDFController () {
		String invoiceId = ApexPages.currentPage().getParameters().get('recordId');
		//invoiceId = 'a0BJ7000000R9YWMA0';
		this.userInfoList = new List<InvoiceInfo>();
		this.customerInfoList = new List<InvoiceInfo>();
		this.paymentInstructionList = new List<InvoiceInfo>();
		this.invoice = obtainInvoice(invoiceId);
		this.invoiceDate = this.invoice.Invoice_Date__c.format();
		this.invoiceNumber = this.invoice.Invoice_Number__c;
		this.invoiceLineTable = new InvoiceLineTableWrapper(this.invoice.Invoice_Lines__r);
		fillUserInfo();
		fillCustomerInfo();
		fillPaymentInstruction();
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

	private void fillUserInfo() {
		Map<String, String> labelToApiNameMap = new Map<String, String>{
			NAME => NAME,
			ID => 'Tax_Id__c',
			ADDRESS => ADDRESS,
			EMAIL => EMAIL,
			PHONE => PHONE
		};
		User user = [SELECT Id
						, Name
						, CompanyName
						, Tax_Id__c
						, Address
						, Email
						, Phone
					FROM User 
					WHERE Id = :this.invoice.OwnerId
					WITH SECURITY_ENFORCED];
		for (String label : labelToApiNameMap.keySet()) {
			String displayLabel = label + ':';
			Object displayValue;
			if (label == ADDRESS) {
				displayValue = user.Address.getStreet() + ', ' + 
							   user.Address.getCity() + ', ' + 
							   user.Address.getPostalCode() + ', ' + 
							   user.Address.getCountry();
			} else if (label == NAME) {
				displayLabel = '';
				displayValue = user.CompanyName ?? user.Name;
			} else {
				displayValue = user.get(labelToApiNameMap.get(label));
			}
			this.userInfoList.add(new InvoiceInfo(displayLabel, displayValue));
		}
	}

	private void fillCustomerInfo() {
		Map<String, String> labelToApiNameMap = new Map<String, String> {
			NAME => NAME,
			ID => 'Company_Id__c',
			ADDRESS => ADDRESS
		};
		for (String label : labelToApiNameMap.keySet()) {
			String displayLabel = label + ':';
			Object displayValue;
			if (label == ADDRESS) {
				displayValue = this.invoice.Billing_Account__r.BillingAddress.getStreet() + ', ' +
							   this.invoice.Billing_Account__r.BillingAddress.getCity() + ', ' +
							   this.invoice.Billing_Account__r.BillingAddress.getCountry();
			} else {
				displayValue = this.invoice.Billing_Account__r.get(labelToApiNameMap.get(label));
			}
			this.customerInfoList.add(new InvoiceInfo(displayLabel, displayValue));
		}
	}

	private void fillPaymentInstruction() {
		Map<String, String> labelToApiNameMap = new Map<String, String> {
			PAYMENT_FORM => 'Payment_Form__c',
			BANK_NAME => 'Bank_Name__c',
			IBAN_NUMBER => 'IBAN_Number__c',
			SWIFT_CODE => 'Swift_Code__c',
			INTERMEDIARY_BANK_NAME => 'Intermediary_Bank_Name__c',
			INTERMEDIARY_BANK_SWIFT_CODE => 'Intermediary_Bank_Swift_Code__c'
		};
		for (String label : labelToApiNameMap.keySet()) {
			String displayLabel = label + ':';
			Object displayValue = this.invoice.Payment_Instruction__r.get(labelToApiNameMap.get(label));
			this.paymentInstructionList.add(new InvoiceInfo(displayLabel, displayValue));
		}
	}

	public class InvoiceLineTableWrapper {
		public List<Invoice_Line__c> lineList { get; set; }
		public List<String> columnHeaderList { get; set; }

		public InvoiceLineTableWrapper(List<Invoice_Line__c> lineList) {
			this.columnHeaderList = new List<String>{DESCRIPTION, UNIT_COST, VAT, QTY, AMOUNT, INVOICE_CURRENCY};
			this.lineList = lineList;
		}
	}

	public class InvoiceInfo {
		public String label { get; set; }
		public Object value { get; set; }

		public InvoiceInfo(String label, Object value) {
			this.label = label;
			this.value = value;
		}
	}
}