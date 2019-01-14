plug_files = files(
    'Plug.vala',
    'Startup/Utils.vala',
    'Startup/Startup.vala',
    'Startup/Controller.vala',
    'Startup/Backend/Monitor.vala',
    'Startup/Backend/KeyFileFactory.vala',
    'Startup/Backend/KeyFile.vala',
    'Startup/Backend/DesktopFileEnumerator.vala',
    'Startup/Entities/AppInfo.vala',
    'Startup/Widgets/Scrolled.vala',
    'Startup/Widgets/List.vala',
    'Startup/Widgets/AppRow.vala',
    'Startup/Widgets/AppChooserRow.vala',
    'Startup/Widgets/AppChooser.vala',
    'Defaults/Utils.vala',
    'Defaults/DefaultPlug.vala',
    'WebSearch/WebSearch.vala'
)

switchboard_dep = dependency('switchboard-2.0')

shared_module(
    meson.project_name(),
    plug_files,
    dependencies: [
        dependency('glib-2.0'),
        dependency('gio-2.0'),
        dependency('gobject-2.0'),
        dependency('granite'),
        dependency('gtk+-3.0'),
        switchboard_dep
    ],
    install: true,
    install_dir : join_paths(switchboard_dep.get_pkgconfig_variable('plugsdir'), 'personal')
)
