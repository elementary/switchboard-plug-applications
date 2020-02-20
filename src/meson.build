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
    'Permissions/Widgets/AppEntry.vala',
    'Permissions/Widgets/AppSettingsView.vala',
    'Permissions/Widgets/BooleanSetting.vala',
    'Permissions/Widgets/Sidebar.vala',
    'Permissions/Application.vala',
    'Permissions/AppManager.vala',
    'Permissions/FlatpakApplication.vala',
    'Permissions/FlatpakManager.vala',
    'Permissions/PermissionsPlug.vala'
)

switchboard_dep = dependency('switchboard-2.0')
switchboard_plugsdir = switchboard_dep.get_pkgconfig_variable('plugsdir', define_variable: ['libdir', libdir])

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
    install_dir : join_paths(switchboard_plugsdir, 'personal')
)
