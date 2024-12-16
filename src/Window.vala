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
		child = new ListEditor();
	}
	
	private void test() {
		stdout.printf("test\n");
	}
}
