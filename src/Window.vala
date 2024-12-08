public class Window : Gtk.Window {
	public Window(Lists app) {
		Object(
			application: app
		);
		
		buildUi();
	}
	
	private void buildUi() {
		var mainBox = new Gtk.Box(Gtk.Orientation.VERTICAL, 3);
		
		// table
		
		var items = new GLib.ListStore(typeof(Item));
		var selection_model = new Gtk.SingleSelection(items) {
			//autoselect = true
		};
		
		items.append(new Item("Visa"));
		items.append(new Item("Mastercard"));
		
		var label_column_factory = new Gtk.SignalListItemFactory();
		label_column_factory.setup.connect(on_label_column_setup);
		label_column_factory.bind.connect(on_label_column_bind);
		
		var label_column = new Gtk.ColumnViewColumn("Label", label_column_factory);
		label_column.expand = true;
		
		var column_view = new Gtk.ColumnView(selection_model);
		column_view.append_column(label_column);
		
		mainBox.append(column_view);
		
		// button
		
		var button = new Gtk.Button();
		
		button.label = "Create new";
		
		button.clicked.connect(() => {
			test();
		});
		
		mainBox.append(button);
		
		child = mainBox;
	}
	
	private void on_label_column_setup(Gtk.SignalListItemFactory factory, GLib.Object list_item_obj) {
		var label = new Gtk.Label("");
		label.halign = Gtk.Align.START;
		((Gtk.ListItem) list_item_obj).child = label;
	}
	
	private void on_label_column_bind(Gtk.SignalListItemFactory factory, GLib.Object list_item_obj) {
		var list_item = (Gtk.ListItem) list_item_obj;
		var item_data = (Item) list_item.item;
		var label = (Gtk.Label) list_item.child;
		label.label = item_data.label;
	}
	
	private void test() {
		stdout.printf("test\n");
	}
}
