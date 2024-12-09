const int DEFAULT_WINDOW_WIDTH = 800;
const int DEFAULT_WINDOW_HEIGHT = 600;

public class Lists : Gtk.Application {
	public Lists() {
		Object(
			application_id: "com.example.Lists",
			flags: ApplicationFlags.HANDLES_OPEN
		);
	}
	
	public override void activate() {
		var window = createWindow();
		
		window.present();
	}
	
	private Window createWindow() {
		return new Window(this) {
			title = "Lists",
			default_width = DEFAULT_WINDOW_WIDTH,
			default_height = DEFAULT_WINDOW_HEIGHT
		};
	}
	
	public override void open(File[] files, string hint) {
		foreach (File file in files) {
			var window = createWindow();
			
			window.openFile(file);
		}
	}
}
