public with sharing class InvoiceTemplateParser implements ITemplateParser {

	private Map<String, Compression.ZipEntry> entriesMap;

	public String extractTextContent(ContentVersion template, String documentEntryName) {

		String bodyBase64 = EncodingUtil.base64Encode(template.VersionData);
		Blob bodyBlob = EncodingUtil.base64Decode(bodyBase64);

		Compression.ZipReader reader = new Compression.ZipReader(bodyBlob);
		entriesMap = reader.getEntriesMap();

		String templateContent = '';
		for (String entryName : entriesMap.keySet()) {
			if (entryName == documentEntryName) {
				Compression.ZipEntry entry = entriesMap.get(entryName);
				templateContent = reader.extract(entry).toString();
			}
		}
		return templateContent;
	}

	public Map<String, Compression.ZipEntry> getEntries() {
		return this.entriesMap;
	}
}