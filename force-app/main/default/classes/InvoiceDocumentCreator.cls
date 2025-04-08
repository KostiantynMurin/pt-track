public with sharing class InvoiceDocumentCreator extends ContentDocumentCreatorBase {

	private IInvoiceDataProvider dataProvider;
	private ITemplateParser parser;
	private ITemplateRenderer renderer;
	private ITemplateExporter exporter;

	public InvoiceDocumentCreator(IInvoiceDataProvider dataProvider, ITemplateParser parser, ITemplateRenderer renderer, ITemplateExporter exporter) {
		super();
		this.dataProvider = dataProvider;
		this.parser = parser;
		this.renderer = renderer;
		this.exporter = exporter;
	}

	public override void createDocument() {
		System.debug(' KM ====>  document ' + this.document);
		//Invoice__c invoice = dataProvider.getInvoiceObject();
		//Map<String, Object> placeholderToValueMap =  dataProvider.getPlaceholderToValueMap();
		
		ContentVersion template = [SELECT Title
										, VersionData
										, FileExtension
										, PathOnClient
								   FROM ContentVersion
								   WHERE Id = :this.document.templateId
								   WITH SECURITY_ENFORCED
								   LIMIT 1];
		System.debug(' KM ====>  FileExtension ' + template.FileExtension);
		System.debug(' KM ====>  PathOnClient ' + template.PathOnClient);
		
		String contentEntryName = this.entryNameToExtensionMap.get(this.document.extension);
		String templateContent = parser.extractTextContent(template, contentEntryName);
		templateContent = renderer.render(templateContent, this.dataProvider);
		Blob finalContent = exporter.export(templateContent, contentEntryName, parser.getEntries());

		this.document.setFileExtension('.' + template.FileExtension);
		this.document.body = finalContent;
	}
}