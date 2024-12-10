public class Window : Gtk.Window {
	public Document? document;
	
	public Window(Lists app) {
		Object(
			application: app
		);
		
		buildUi();
	}
	
	public async void openFile(File file) throws Error {
		document = yield Document.fromFile(file);
	}
	
	private void buildUi() {
		var mainBox = new Gtk.Box(Gtk.Orientation.VERTICAL, 3);
		
		// button
		
		var button = new Gtk.Button();
		
		button.label = "Create new";
		
		button.clicked.connect(() => {
			test();
		});
		
		mainBox.append(button);
		
		child = mainBox;
	}
	
	private void test() {
		stdout.printf("test\n");
	}
}
