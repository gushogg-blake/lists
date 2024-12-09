project('lists', 'vala', 'c')

#gnome = import('gnome')

dependencies = [
	dependency('glib-2.0'),
	dependency('gtk4'),
	dependency('gobject-2.0'),
]

sources = files(
	'src/main.vala',
	'src/Lists.vala',
	'src/Item.vala',
	'src/Document.vala',
	'src/Window.vala',
)

executable(
	'lists',
	sources,
	dependencies: dependencies,
)
