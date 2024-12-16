using Gtk;

public class ListItemWidget : Widget {
	public Box rootWidget;
	public ListItem listItem { get; construct; }
	
	private Label label;
	
	public ListItemWidget(ListItem listItem) {
		Object(
			listItem: listItem
		);
		
		buildUi();
	}
	
	private void buildUi() {
		rootWidget = new Box(Orientation.VERTICAL, 0);
		
		label = new Label("");
		
		label.set_text(listItem.name);
		
		rootWidget.append(label);
	}
}
