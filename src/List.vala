using Gee;

public class List : Object {
	public string name;
	public string notes;
	public ListItem[] items;
	
	public static List fromStream(DataInputStream stream) throws Error {
		return listFromStream(stream);
	}
}
