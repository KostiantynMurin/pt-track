/**
 * @description  : 
 * @author       : Kostiantyn Murin
 * @date         : 02-23-2025
**/
public virtual class ContentDocumentCreatorBase {

	private static final String INVOICE = 'Invoice';
	protected Document document;
	protected Map<String, String> entryNameToExtensionMap;

	public ContentDocumentCreatorBase() {
		this.document = new Document();
		this.entryNameToExtensionMap = new Map<String, String>{
			'.docx' => 'word/document.xml',
			'.odt' => 'content.xml'
		};
	}

	public static ContentDocumentCreatorBase getInstance(Document document) {
		if (document.name.contains(INVOICE)) {
			if (String.isBlank(document.templateId)) {
				return new InvoicePDFCreator().initialize(document);
			} else {
				return new InvoiceDocumentCreator(
					new InvoiceDataProvider(document.linkedEntityId),
					new InvoiceTemplateParser(),
					new InvoiceTemplateRenderer(),
					new InvoiceTemplateExporter()
				).initialize(document);
			}
		}
		return new ContentDocumentCreatorBase().initialize(document);
	}

	//public static ContentDocumentCreatorBase getInstance(Document.DocumentParams params) {
	//	System.debug(' KM ====>   getInstance ' + params);
	//	if (params?.fileName.contains(INVOICE)) {
	//		return new InvoicePDFCreator().initialize(params);
	//	}
	//	return new ContentDocumentCreatorBase().initialize(params);
	//}

	//public virtual ContentDocumentCreatorBase initialize(Document.DocumentParams params) {
	//	this.document.linkedEntityId = params.linkedEntityId;
	//	this.document.templateId = params.templateId;
	//	this.document.extension = params.fileExtension;
	//	this.document.name = generateFileName(params);
	//	return this;
	//}

	public virtual ContentDocumentCreatorBase initialize(Document document) {
		document.setFileName(generateFileName(document.linkedEntityId, document.name));
		this.document = document;
		return this;
	}

	public virtual void saveDocument() {
		ContentVersion contentVersion = new ContentVersion();
		contentVersion.Title = document.name;
		contentVersion.PathOnClient = document.name + document.extension;
		contentVersion.VersionData = document.body;
		insert contentVersion;

		ContentVersion insertedVersion = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id = :contentVersion.Id LIMIT 1];
		if (insertedVersion != null) {
			ContentDocumentLink docLink = new ContentDocumentLink();
			docLink.LinkedEntityId = document.linkedEntityId;
			docLink.ContentDocumentId = insertedVersion.ContentDocumentId;
			insert docLink;
		} else {
			System.debug('### Error: No ContentDocumentId found for ContentVersion.');
		}
	}

	public virtual void createDocument() {
		System.debug(' KM ====> createDocument Base class  ');
		this.document.body = Blob.valueOf('Mock Content');
	}


	protected virtual String generateFileName(String linkedEntityId, String fileName) {
		List<ContentDocumentLink> existingFiles = [
			SELECT ContentDocumentId
				, ContentDocument.Title
			FROM ContentDocumentLink
			WHERE LinkedEntityId = :linkedEntityId
		];

		if (existingFiles.isEmpty()) {
			return fileName;
		}
		Integer fileNumber = 0;
		for (ContentDocumentLink docLink : existingFiles) {
			if (docLink.ContentDocument.Title.startsWith(fileName)) {
				fileNumber++;
			}
		}
		return fileName + ' (' + fileNumber + ')';
	}

	public class ContentDocumentCreatorBaseException extends Exception {}
}