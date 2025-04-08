public interface ITemplateParser {

	String extractTextContent(ContentVersion template, String documentEntryName);
	Map<String, Compression.ZipEntry> getEntries();
}