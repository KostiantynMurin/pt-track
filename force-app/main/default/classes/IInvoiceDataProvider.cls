public interface IInvoiceDataProvider {

	Invoice__c getInvoiceObject();
	Object getFieldValue(String placeholder);
	Map<String, Object> getPlaceholderToValueMap(); // {!Invoice.Name} -> 'Test Invoice'

}