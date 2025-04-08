public interface ITemplateExporter {

	Blob export(String templateContent, String contentEntryName, Map<String, Compression.ZipEntry> entriesMap);
}