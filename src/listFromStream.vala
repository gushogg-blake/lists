/*
mdlist documents are markdown files describing a list

a few special syntaxes:

- the whole file is split into "pages" by <hr class="mdlist-separator"/>
- the first page contains info about the list itself; the rest of the pages
  are the items
- each page follows a format where the first h1 is the name and the following
  markdown is the description - until we get to special sections (see below)
- after the name and description we have special sections which are marked with
  an h2 and an @, like ## @fields
- within the ## @longFields section, fields are marked with h3s and a colon:
  ### :fieldName

see /test.mdlist for example

this syntax means we don't have to do a full parse of the markdown, we can
just go line by line (until we actually want to parse the markdown, of course)
*/

using Gee;

/*
parsing a page is done in multiple stages to make it simpler - we first split
it up into sections, then do any necessary parsing of the sections in separate
functions

- start on INIT to get the name and description
- then parse the marked sections in GENERAL
*/

enum ParseState {
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

private GLib.List<GLib.List<string>> splitStreamIntoSections(DataInputStream stream) {
	var sections = new GLib.List<GLib.List<string>>();
	
	
	
	return sections;
}

private ListItem listItemFromLines(GLib.List<string> lines) {
	var listItem = new ListItem();
	
	var state = ParseState.INIT;
	bool inCodeBlock = false;
	
	string name = "";
	var descriptionLines = new GLib.List<string>();
	var shortFieldLines = new GLib.List<string>();
	var longFieldLines = new GLib.List<string>();
	var metaLines = new GLib.List<string>();
	
	// HACK for some reason we need to append something first
	// otherwise appending to the unowned container var won't
	// affect the original
	descriptionLines.append("");
	shortFieldLines.append("");
	longFieldLines.append("");
	metaLines.append("");
	
	unowned GLib.List<string>? container = null;
	
	for (int i = 0; i < lines.length(); i++) {
		var line = lines.nth_data(i);
		
		line = line.strip();
		
		if (state == ParseState.INIT) {
			if (line == "") {
				continue;
			}
			
			if (line.has_prefix("# ")) {
				name = line.slice("# ".length, line.length);
				
				state = ParseState.GENERAL;
				
				container = descriptionLines;
				
				continue;
			}
		}
		
		if (state == ParseState.GENERAL) {
			if (!inCodeBlock && line.has_prefix("# @")) {
				var sectionName = line.slice("# @".length, line.length);
				
				if (sectionName == "fields") {
					container = shortFieldLines;
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
	shortFieldLines = trimLinesInner(shortFieldLines);
	longFieldLines = trimLines(longFieldLines);
	metaLines = trimLinesInner(metaLines);
	
	string description = listToString(descriptionLines, "\n");
	
	// parse short and long fields and merge them into one HashMap
	
	var shortFields = parseFields(longFieldLines);
	var longFields = parseLongFields(longFieldLines);
	var fields = mergeFields(shortFields, longFields);
	var meta = parseFields(metaLines);
	
	listItem.name = name;
	listItem.description = description;
	listItem.fields = fields;
	listItem.meta = meta;
	
	return listItem;
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
	longFieldLines = trimLines(longFieldLines);
	metaLines = trimLinesInner(metaLines);
	
	string description = listToString(descriptionLines, "\n");
	
	// parse short and long fields and merge them into one HashMap
	
	var shortFields = parseFields(fieldLines);
	var longFields = parseLongFields(longFieldLines);
	var fields = mergeFields(shortFields, longFields);
	
	list.name = name;
	list.description = description;
	list.fields = fields;
	
	print(@"name: $name\n\n");
	print(@"description:\n\n");
	print(description + "\n\n");
	print("fields:\n\n");
	fields.map_iterator().foreach((k, v) => {
		print(@"$k: $v\n");
		
		return true;
	});
	//print("fields:\n\n");
	//longFields.map_iterator().foreach((k, v) => {
	//	print(@"$k: $v\n");
	//	
	//	return true;
	//});
	
	return list;
}

private HashMap<string, string> parseFields(GLib.List<string> fieldLines) {
	var res = new HashMap<string, string>();
	
	for (int i = 0; i < fieldLines.length(); i++) {
		var line = fieldLines.nth_data(i);
		
		if (!line.has_prefix("- ")) {
			continue;
		}
		
		line = line.slice("- ".length, line.length);
		
		string[] parts = line.split(": ", 2);
		
		if (parts.length != 2) {
			continue;
		}
		
		res.set(parts[0], parts[1]);
	}
	
	return res;
}

private HashMap<string, string> parseLongFields(GLib.List<string> longFieldLines) {
	var untrimmed = new HashMap<string, string>();
	string? field = null;
	string lines = "";
	
	for (int i = 0; i < longFieldLines.length(); i++) {
		var line = longFieldLines.nth_data(i);
		
		if (line.has_prefix("# :")) {
			if (field != null) {
				untrimmed.set(field, lines);
			}
			
			field = line.slice("# :".length, line.length);
			lines = "";
		} else {
			if (field == null) {
				continue;
			}
			
			lines += @"\n$line";
		}
	}
	
	if (field != null) {
		untrimmed.set(field, lines);
	}
	
	var res = new HashMap<string, string>();
	
	untrimmed.map_iterator().foreach((k, v) => {
		res.set(k, v.strip());
		
		return true;
	});
	
	return res;
}

private HashMap<string, string> mergeFields(
	HashMap<string, string> shortFields,
	HashMap<string, string> longFields
) {
	var res = new HashMap<string, string>();
	
	shortFields.map_iterator().foreach((k, v) => {
		res.set(k, v);
		
		return true;
	});
	
	longFields.map_iterator().foreach((k, v) => {
		res.set(k, v);
		
		return true;
	});
	
	return res;
}
