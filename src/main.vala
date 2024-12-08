const int DEFAULT_WINDOW_WIDTH = 800;
const int DEFAULT_WINDOW_HEIGHT = 600;

public class Item : GLib.Object {
	public string label { get; set; }
	
	public Item(string label) {
		Object(
			label: label
		);
	}
}

public class Lists : Gtk.Application {
	public Lists() {
		Object(
			application_id: "com.example.Lists",
			flags: ApplicationFlags.HANDLES_OPEN
		);
	}
	
	public override void activate() {
		var window = new Window(this) {
			title = "Lists",
			default_width = DEFAULT_WINDOW_WIDTH,
			default_height = DEFAULT_WINDOW_HEIGHT
		};
		
		window.present();
	}
	
	public override void open(GLib.File[] files, string hint) {
		stdout.printf("%s\n", files[0].get_uri());
	}
	
	public static int main(string[] args) {
		var app = new Lists();
		return app.run(args);
	}
}
