public class Window : Gtk.Window {
	public Document? document;
	
	public Window(Lists app) {
		Object(
			application: app
		);
		
		//buildUi();
	}
	
	public async void openFile(File file) throws Error {
		document = yield Document.fromFile(file);
		
		buildUi();
	}
	
	private void buildUi() {
		var editor = new ListEditor(document.list);
		
		child = editor.rootWidget;
	}
}
