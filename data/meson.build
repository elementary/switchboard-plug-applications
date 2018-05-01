i18n.merge_file(
    input: 'io.elementary.switchboard-plug-applications.appdata.xml.in',
    output: 'io.elementary.switchboard-plug-applications.appdata.xml',
    po_dir: join_paths(meson.source_root (), 'po', 'extra'),
    install_dir: join_paths(get_option('datadir'), 'metainfo'),
    install: true
)

desktop_file = i18n.merge_file(
    input: 'io.elementary.switchboard-plug-applications.desktop.in',
    output: 'io.elementary.switchboard-plug-applications.desktop',
    po_dir: join_paths(meson.source_root(), 'po', 'extra'),
    type: 'desktop',
    install_dir: join_paths(get_option('datadir'), 'applications'),
    install: true
)
