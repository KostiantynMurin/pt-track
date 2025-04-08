public with sharing class InvoiceTemplateExporter implements ITemplateExporter {

	public Blob export(String templateContent, String contentEntryName, Map<String, Compression.ZipEntry> entriesMap) {
		Compression.ZipWriter writer = new Compression.ZipWriter();
		for (String entryName : entriesMap.keySet()) {
			if (entryName != contentEntryName) {
				writer.addEntry(entriesMap.get(entryName));
				continue;
			}
			Blob templateContentBlob = Blob.valueOf(templateContent);
			writer.addEntry(contentEntryName, templateContentBlob);
		}
		return writer.getArchive();
	}
}