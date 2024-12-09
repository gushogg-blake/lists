
public class Document : Object {
	public File? file { get; construct; }
	
	public Document(File? file) {
		Object(
			file: file
		);
		
		if (file != null) {
			this.readFile();
		}
	}
	
	private async void readFile() {
		file.read_async.begin(Priority.DEFAULT, null, (obj, res) => {
			try {
				var fileInputStream = file.read_async.end(res);
				var dataInputStream = new DataInputStream(fileInputStream);
				
				string line;
				
				while ((line = dataInputStream.read_line()) != null) {
					print("%s\n", line);
				}
				
				
			} catch (Error e) {
				
			}
		});
		try {
			var stream = file.read();
			
			parseStream(stream);
		} catch (Error e) {
			
		}
	}
	
	private async void parseStream(InputStream stream) {
		
	}
	
	public bool isNew {
		get { return file == null; }
	}
	
	public static Document _new() {
		return new Document(null);
	}
	
	public static Document fromFile(File file) {
		stdout.printf("%s\n", file.get_uri());
		
		return new Document(null);
	}
}
