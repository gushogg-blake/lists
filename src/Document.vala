/*
There are two levels - Document, which knows about files, and
List, which is the actual domain object - a list of stuff.

The containment hierarchy will probably look like:

Application (manages windows)
	Window (UI for editing a list)
		Document (container for associating a list with the underlying file, if any)
			List (list)

we won't have tabs - one file per window (this makes sense because
it's not like code where we'll have multiple lists per project that
are tightly related, it's more like Word documents)

LIFECYCLE

- every Window has a Document

- the Document instance will be the same for the lifecycle of the Window - if you create
  a new file then save it, we'll call setFile to associate the document with the file.
  renaming will work similarly - it's still the same Document.

PURPOSE

- container. we need somewhere to put the logic of associating files with Lists, and
  for parsing the files and serialising the lists back to files. don't read too much into
  the name.

INVARIANTS

- the document will always have an underlying list - we make sure to either parse one
  from a file, or create a new one, in the constructors

CONSTRUCTION

- static methods
*/

public class Document : Object {
	public List list { get; construct; }
	public File? file { get; construct; }
	
	private Document(List list, File? file) {
		Object(
			list: list,
			file: file
		);
	}
	
	public bool isNew {
		get { return file == null; }
	}
	
	public static Document _new() {
		return new Document(new List(), null);
	}
	
	private static async DataInputStream readFile(File file) throws Error {
		var fileInputStream = yield file.read_async();
		var dataInputStream = new DataInputStream(fileInputStream);
		
		return dataInputStream;
	}
	
	public static async Document fromFile(File file) throws Error {
		var dataInputStream = yield readFile(file);
		var list = List.fromStream(dataInputStream);
		
		print(@"$(list.name)\n");
		print(@"$(list.notes)\n");
		
		return new Document(list, file);
	}
	
	
}
