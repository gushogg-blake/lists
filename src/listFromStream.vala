/*
we don't do a full markdown parse here as we can just read the lines:

- skip anything before the first h1
- first h1 is the name
- one or more lines for the description
- then special h1s marking sections (fields, meta)


within fields, we have two possible syntaxes - lists and subheadings

by default, fields are string type, but we can type them to put different
widgets in the table

# name

description

- can include lists

## and subheadings

# @longfields

# heading per field

field content

# another field

etc

# @fields

- field1:yesno: Y
- field2:date: 2022-02-22
- field3: defaults to string

# @meta

- meta field: defaults to string
- another meta:number: 123


*/

enum State {
	INIT,
	READING_DESCRIPTION,
	READING_LONG_FIELDS,
	READING_FIELDS,
	READING_META
}



public List listFromStream(DataInputStream stream) throws Error {
	var list = new List();
	
	var state = State.INIT;
	
	bool inCodeBlock = false;
	string name;
	var descriptionLines = new GLib.List<string>();
	var fields = new HashMap<string, string> // TODO doesn't support types yet - need a Field object
	
	// string.joinv("\n", descriptionLines.to_array());
	
	string line;
	
	while ((line = stream.read_line()) != null) {
		line = line.strip();
		
		if (!inCodeBlock && line == "```") {
			inCodeBlock = true;
			continue;
		}
		
		if (inCodeBlock && line == "```") {
			inCodeBlock = false;
			continue;
		}
		
		
		if (state == State.INIT) {
			if (line.has_prefix("#")) {
				name = line.slice("# ".length, line.length - "# ".length);
			}
		}
		
		if (state == State.READING_DESCRIPTION) {
		}
	}
	
	return list;
}
