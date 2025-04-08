/**
 * @description  : 
 * @author       : Kostiantyn Murin
 * @date         : 02-23-2025
**/
public with sharing class InvoicePDFCreator extends ContentDocumentCreatorBase{
	
	public InvoicePDFCreator() {
		super();
	}

	public override void createDocument(){
		System.debug(' KM ====>  createDocument child class ' );
		PageReference pdfPage = Page.InvoicePDF;
		pdfPage.getParameters().put('recordId', document.linkedEntityId);
		try {
			document.setFileExtension('.pdf');
			document.body = pdfPage.getContentAsPDF();
		} catch (Exception e) {
			System.debug('### Error generating PDF: ' + e.getMessage());
		}
	}
}