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

public GLib.List<string> trimLines(GLib.List<string> lines) {
	var firstNonEmptyLineIndex = -1;
	var lastNonEmptyLineIndex = -1;
	weak GLib.List<string> res = new GLib.List<string>();
	var index = 0;
	
	lines.foreach((line) => {
		if (line != "") {
			if (firstNonEmptyLineIndex == -1) {
				firstNonEmptyLineIndex = index;
			}
			
			lastNonEmptyLineIndex = index;
		}
		
		index++;
	});
	
	if (firstNonEmptyLineIndex != -1) {
		index = 0;
		
		lines.foreach((line) => {
			if (index >= firstNonEmptyLineIndex && index <= lastNonEmptyLineIndex) {
				res.append(line);
			}
			
			index++;
		});
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
					stdout.printf("container = fields\n");
					container = fieldLines;
				} else if (sectionName == "longFields") {
					stdout.printf("container = longFields\n");
					container = longFieldLines;
				} else if (sectionName == "meta") {
					stdout.printf("container = meta\n");
					container = metaLines;
				}
			} else {
				stdout.printf("appending\n");
				container.append(line);
				stdout.printf("container length: %u\n", container.length());
			}
			
			if (!inCodeBlock && line.has_prefix("```")) {
				inCodeBlock = true;
			} else if (inCodeBlock && line == "```") {
				inCodeBlock = false;
			}
		}
	}
	
	stdout.printf("name: %s\n", name);
	
	stdout.printf("fields\n");
	
	stdout.printf("%u\n", metaLines.length());
	
	fieldLines.foreach((line) => {
		print(@"$line\n");
	});
	
	return list;
}
