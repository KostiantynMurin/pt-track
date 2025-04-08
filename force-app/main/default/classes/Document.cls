/**
 * @description  : 
 * @author       : Kostiantyn Murin
 * @date         : 02-22-2025
**/
public class Document {

	public String linkedEntityId;
	public String templateId;
	public String name;
	public String extension;
	public Blob body;

	public Document setLinkedEntityId(String linkedEntityId) {
		this.linkedEntityId = linkedEntityId;
		return this;
	}

	public Document setTemplateId(String templateId) {
		this.templateId = templateId;
		return this;
	}

	public Document setFileName(String fileName) {
		this.name = fileName;
		return this;
	}

	public Document setFileExtension(String fileExtension) {
		this.extension = fileExtension;
		return this;
	}

	//public class DocumentParams {
	//	public String linkedEntityId {get; private set;}
	//	public String templateId {get; private set;}
	//	public String fileName {get; private set;}
	//	public String fileExtension {get; private set;}
	//	public Map<String, Object> fileData {get; private set;}
		
	//	public DocumentParams setLinkedEntityId(String linkedEntityId) {
	//		this.linkedEntityId = linkedEntityId;
	//		return this;
	//	}

	//	public DocumentParams setTemplateId(String templateId) {
	//		this.templateId = templateId;
	//		return this;
	//	}

	//	public DocumentParams setFileName(String fileName) {
	//		this.fileName = fileName;
	//		return this;
	//	}

	//	public DocumentParams setFileExtension(String fileExtension) {
	//		this.fileExtension = fileExtension;
	//		return this;
	//	}

	//	public DocumentParams setFileData(Map<String, Object> fileData) {
	//		this.fileData = fileData;
	//		return this;
	//	}
	//}
}