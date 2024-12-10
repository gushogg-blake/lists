project('lists', 'vala', 'c')

#gnome = import('gnome')

dependencies = [
	dependency('glib-2.0'),
	dependency('gobject-2.0'),
	dependency('gee-0.8'),
	dependency('gtk4'),
]

sources = files(
	'src/main.vala',
	'src/Lists.vala',
	'src/ListItem.vala',
	'src/Document.vala',
	'src/List.vala',
	'src/Window.vala',
	
	'src/listFromStream.vala',
)

executable(
	'lists',
	sources,
	dependencies: dependencies,
)
