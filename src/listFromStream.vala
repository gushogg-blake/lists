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

using Gee;

/*
multi-stage parse - first split into general sections, then parse each section
if needed

- start on INIT to get the header
- then parse the marked sections in GENERAL
*/

enum State {
	INIT,
	GENERAL
}

private string listToString(GLib.List<string> list, string separator) {
	var res = "";
	var length = list.length();
	
	for (int i = 0; i < length; i++) {
		res += list.nth_data(i);
		
		if (i <= length - 2) {
			res += separator;
		}
	}
	
	return res;
}

private GLib.List<string> trimLines(GLib.List<string> lines) {
	var firstNonEmptyLineIndex = -1;
	var lastNonEmptyLineIndex = -1;
	var res = new GLib.List<string>();
	
	for (int i = 0; i < lines.length(); i++) {
		if (lines.nth_data(i) != "") {
			if (firstNonEmptyLineIndex == -1) {
				firstNonEmptyLineIndex = i;
			}
			
			lastNonEmptyLineIndex = i;
		}
	}
	
	if (firstNonEmptyLineIndex != -1) {
		for (int i = 0; i < lines.length(); i++) {
			if (i >= firstNonEmptyLineIndex && i <= lastNonEmptyLineIndex) {
				res.append(lines.nth_data(i));
			}
		}
	}
	
	return res;
}

private GLib.List<string> trimLinesInner(GLib.List<string> lines) {
	var res = new GLib.List<string>();
	
	for (int i = 0; i < lines.length(); i++) {
		var line = lines.nth_data(i);
		
		if (line != "") {
			res.append(line);
		}
	}
	
	return res;
}

public List listFromStream(DataInputStream stream) throws Error {
	var list = new List();
	
	var state = State.INIT;
	
	bool inCodeBlock = false;
	string name = "";
	
	var descriptionLines = new GLib.List<string>();
	var fieldLines = new GLib.List<string>();
	var longFieldLines = new GLib.List<string>();
	var metaLines = new GLib.List<string>();
	
	// HACK for some reason we need to append something first
	// otherwise appending to the unowned container var won't
	// affect the original
	descriptionLines.append("");
	fieldLines.append("");
	longFieldLines.append("");
	metaLines.append("");
	
	var fields = new HashMap<string, string>(); // TODO doesn't support types yet - need a Field object
	
	unowned GLib.List<string>? container = null;
	
	string line;
	
	while ((line = stream.read_line()) != null) {
		line = line.strip();
		
		if (state == State.INIT) {
			if (line == "") {
				continue;
			}
			
			if (line.has_prefix("# ")) {
				name = line.slice("# ".length, line.length);
				
				state = State.GENERAL;
				
				container = descriptionLines;
				
				continue;
			}
		}
		
		if (state == State.GENERAL) {
			if (!inCodeBlock && line.has_prefix("# @")) {
				var sectionName = line.slice("# @".length, line.length);
				
				if (sectionName == "fields") {
					container = fieldLines;
				} else if (sectionName == "longFields") {
					container = longFieldLines;
				} else if (sectionName == "meta") {
					container = metaLines;
				}
			} else {
				container.append(line);
			}
			
			if (!inCodeBlock && line.has_prefix("```")) {
				inCodeBlock = true;
			} else if (inCodeBlock && line == "```") {
				inCodeBlock = false;
			}
		}
	}
	
	descriptionLines = trimLines(descriptionLines);
	fieldLines = trimLinesInner(fieldLines);
	metaLines = trimLinesInner(metaLines);
	
	string description = listToString(descriptionLines, "\n");
	
	print(@"name: $name\n\n");
	
	print(@"description:\n\n");
	
	print(description + "\n\n");
	
	print("fields:\n\n");
	
	for (int i = 0; i < fieldLines.length(); i++) {
		var item = fieldLines.nth_data(i);
		
		print(@"$item\n");
	}
	
	return list;
}
