project('lists', 'vala', 'c')

gnome = import('gnome')

dependencies = [
	dependency('glib-2.0'),
	dependency('gobject-2.0'),
	dependency('gee-0.8'),
	dependency('gtk4'),
]

sources = files(
	'src/main.vala',
	
	'src/Application.vala',
	'src/ListItem.vala',
	'src/Document.vala',
	'src/List.vala',
	
	'src/widgets/Window.vala',
	'src/widgets/ListEditor.vala',
	'src/widgets/ListItemWidget.vala',
	
	'src/listFromStream.vala',
)

#sources += gnome.compile_resources(
#	'resources',
#	'src/ui/lists.gresource.xml',
#	source_dir: 'src/ui'
#)

executable(
	'lists',
	sources,
	dependencies: dependencies,
)
