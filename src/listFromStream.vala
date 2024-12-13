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

private string listToString(ArrayList<string> list, string separator) {
	var res = "";
	var length = list.size;
	
	for (int i = 0; i < length; i++) {
		res += list.get(i);
		
		if (i <= length - 2) {
			res += separator;
		}
	}
	
	return res;
}

/*
NOTE we can probably do these more efficiently with remove_at -
converted from GLib.List which is a bit weird
*/

private ArrayList<string> trimLines(ArrayList<string> lines) {
	var firstNonEmptyLineIndex = -1;
	var lastNonEmptyLineIndex = -1;
	var res = new ArrayList<string>();
	
	for (int i = 0; i < lines.size; i++) {
		if (lines.get(i) != "") {
			if (firstNonEmptyLineIndex == -1) {
				firstNonEmptyLineIndex = i;
			}
			
			lastNonEmptyLineIndex = i;
		}
	}
	
	if (firstNonEmptyLineIndex != -1) {
		for (int i = 0; i < lines.size; i++) {
			if (i >= firstNonEmptyLineIndex && i <= lastNonEmptyLineIndex) {
				res.add(lines.get(i));
			}
		}
	}
	
	return res;
}

private ArrayList<string> trimLinesInner(ArrayList<string> lines) {
	var res = new ArrayList<string>();
	
	for (int i = 0; i < lines.size; i++) {
		var line = lines.get(i);
		
		if (line != "") {
			res.add(line);
		}
	}
	
	return res;
}

//private ArrayList<ArrayList<string>> splitStreamIntoSections(DataInputStream stream) {
//	var sections = new ArrayList<ArrayList<string>>();
//	
//	
//	
//	return sections;
//}

private ListItem listItemFromLines(ArrayList<string> lines) {
	var listItem = new ListItem();
	
	var state = ParseState.INIT;
	bool inCodeBlock = false;
	
	string name = "";
	var descriptionLines = new ArrayList<string>();
	var shortFieldLines = new ArrayList<string>();
	var longFieldLines = new ArrayList<string>();
	var metaLines = new ArrayList<string>();
	
	unowned ArrayList<string>? container = null;
	
	for (int i = 0; i < lines.size; i++) {
		var line = lines.get(i);
		
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
			if (!inCodeBlock && line.has_prefix("## @")) {
				var sectionName = line.slice("## @".length, line.length);
				
				if (sectionName == "fields") {
					container = shortFieldLines;
				} else if (sectionName == "longFields") {
					container = longFieldLines;
				} else if (sectionName == "meta") {
					container = metaLines;
				}
			} else {
				container.add(line);
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
	
	var pages = new ArrayList<ArrayList<string>>();
	var lines = new ArrayList<string>();
	
	string line;
	
	while ((line = stream.read_line()) != null) {
		line = line.strip();
		
		if (line == "<hr class=\"mdlist-separator\"/>") {
			pages.add(lines);
			
			lines = new ArrayList<string>();
		} else {
			lines.add(line);
		}
	}
	
	if (lines.size > 0) {
		pages.add(lines);
	}
	
	if (pages.size == 0) {
		return list;
	}
	
	var listPage = pages.get(0);
	var listListItem = listItemFromLines(listPage);
	
	list.name = listListItem.name;
	list.notes = listListItem.description;
	
	for (int i = 1; i < pages.size; i++) {
		var listItem = listItemFromLines(pages.get(i));
		
		list.items.add(listItem);
	}
	
	return list;
}

private HashMap<string, string> parseFields(ArrayList<string> fieldLines) {
	var res = new HashMap<string, string>();
	
	for (int i = 0; i < fieldLines.size; i++) {
		var line = fieldLines.get(i);
		
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

private HashMap<string, string> parseLongFields(ArrayList<string> longFieldLines) {
	var untrimmed = new HashMap<string, string>();
	string? field = null;
	string lines = "";
	
	for (int i = 0; i < longFieldLines.size; i++) {
		var line = longFieldLines.get(i);
		
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
