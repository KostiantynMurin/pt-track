/**
 * @description  : 
 * @author       : Kostiantyn Murin
 * @date         : 02-23-2025
**/
public with sharing class GenerateInvoiceController {

	@AuraEnabled
	public static Response generateInvoice(String recordId, String templateId, String templateExtension) {
		try {
			System.debug(' KM ====>  templateExtension  ' + templateExtension);
			//Document.DocumentParams params = new Document.DocumentParams()
			//.setLinkedEntityId(recordId)
			//.setTemplateId(templateId)
			//.setFileName('Invoice')
			//.setFileExtension('.pdf');
			//ContentDocumentCreatorBase invoiceCreator = new InvoicePDFCreator().initialize(params);
			Document document = new Document()
			.setLinkedEntityId(recordId)
			.setTemplateId(templateId)
			.setFileName('Invoice')
			.setFileExtension('.' + templateExtension);
			ContentDocumentCreatorBase invoiceCreator = ContentDocumentCreatorBase.getInstance(document);
			invoiceCreator.createDocument();
			invoiceCreator.saveDocument();
			return new Response(true, 'Invoice was created successfully');
		} catch (Exception e) {
			System.debug(' KM ====>  e ' + e.getMessage());
			System.debug(' KM ====>  e ' + e.getStackTraceString());
			return new Response(e);
			//throw new AuraHandledException(e.getStackTraceString());
		}
	}

	@AuraEnabled(cacheable=true)
	public static Response obtainTemplates() {
		try {
			ContentFolder folder = [
			SELECT Id
				, Name
				,ParentContentFolderId 
			FROM ContentFolder 
			WHERE Name = 'Invoice Templates' LIMIT 1];
			System.debug(' KM ====>  folder ' + folder);

			List<ContentFolderMember> folderMembers = [
				SELECT Id
				, ChildRecordId 
				FROM ContentFolderMember 
				WHERE ParentContentFolderId = :folder.Id];

			System.debug(' KM ====>  folderMembers ' + folderMembers);
			List<Id> folderContentDocumentIds = new List<Id>();
			for(ContentFolderMember folderMember: folderMembers ) {
				folderContentDocumentIds.add(folderMember.ChildRecordId);
			}

			List<ContentVersion> documents = [
				SELECT Id
					, Title
					, VersionData
					, FileExtension
				FROM ContentVersion
				WHERE isLatest = true AND ContentDocumentId IN :folderContentDocumentIds
			];
			System.debug(' KM ====>  documents ' + documents);
			return new Response(documents);
		} catch (Exception e) {
			System.debug(' KM ====>  e ' + e.getMessage());
			System.debug(' KM ====>  e ' + e.getStackTraceString());
			return new Response(e);
		}

		
	}
}