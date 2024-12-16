[GtkTemplate(ui="/ListEditor.ui")]
public class ListEditor : Gtk.Widget {
	//[GtkChild] public unowned Gtk.Entry entry1;
	//[GtkChild] public unowned Gtk.Entry entry2;
	
	[GtkChild]
	private unowned Gtk.Entry entry;
	
	[GtkChild]
	private unowned Gtk.Button button;
}
