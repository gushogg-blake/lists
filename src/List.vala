using Gee;

public class List : Object {
	public string name;
	public string notes;
	public ArrayList<ListItem> items;
	
	public List() {
		items = new ArrayList<ListItem>();
	}
	
	public static List fromStream(DataInputStream stream) throws Error {
		return listFromStream(stream);
	}
}
