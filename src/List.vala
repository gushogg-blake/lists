using Gee;

public class List : Object {
	public string name;
	public string description;
	public HashMap<string, string> meta;
	public HashMap<string, string> fields;
	public ListItem[] items;
	
	public static List fromStream(DataInputStream stream) throws Error {
		return listFromStream(stream);
	}
}
