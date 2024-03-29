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
    'Startup/Widgets/AppRow.vala',
    'Startup/Widgets/AppChooserRow.vala',
    'Startup/Widgets/AppChooser.vala',
    'Defaults/DefaultPlug.vala',
    'Permissions/Backend/App.vala',
    'Permissions/Backend/AppManager.vala',
    'Permissions/Backend/FlatpakManager.vala',
    'Permissions/Backend/PermissionSettings.vala',
    'Permissions/Widgets/AppSettingsView.vala',
    'Permissions/Widgets/PermissionSettingsWidget.vala',
    'Permissions/Widgets/SidebarRow.vala',
    'Permissions/PermissionsPlug.vala'
)

switchboard_dep = dependency('switchboard-3')
switchboard_plugsdir = switchboard_dep.get_pkgconfig_variable('plugsdir', define_variable: ['libdir', libdir])

shared_module(
    meson.project_name(),
    plug_files,
    conf_file,
    dependencies: [
        dependency('flatpak', version: '>=1.1.2'),
        dependency('glib-2.0', version: '>=2.34'),
        dependency('gio-2.0'),
        dependency('gobject-2.0'),
        dependency('granite-7', version: '>=7.4.0'),
        dependency('gtk4'),
        dependency('libadwaita-1', version: '>=1.4'),
        switchboard_dep
    ],
    install: true,
    install_dir : join_paths(switchboard_plugsdir, 'personal')
)
