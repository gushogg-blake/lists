using Gtk;

public class ListEditor : Widget {
	public Box rootWidget;
	public List list { get; construct; }
	
	private Entry nameEntry;
	private Entry notesEntry;
	
	public ListEditor(List list) {
		Object(
			list: list
		);
		
		buildUi();
	}
	
	void buildUi() {
		rootWidget = new Box(Orientation.VERTICAL, 0);
		
		nameEntry = new Entry();
		notesEntry = new Entry();
		
		rootWidget.append(nameEntry);
		rootWidget.append(notesEntry);
		
		
		
		foreach (var listItem in list.items) {
			var listItemWidget = new ListItemWidget(listItem);
			
			print("??");
			rootWidget.append(listItemWidget.rootWidget);
		}
	}
}
