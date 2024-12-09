public class Item : GLib.Object {
	public string label { get; set; }
	
	public Item(string label) {
		Object(
			label: label
		);
	}
}
