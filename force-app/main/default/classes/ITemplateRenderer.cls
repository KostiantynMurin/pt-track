public interface ITemplateRenderer {
	String render(String templateContent, IInvoiceDataProvider dataProvider);
}