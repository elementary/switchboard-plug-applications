i18n.merge_file(
    input: 'applications.metainfo.xml.in',
    output: 'io.elementary.switchboard.applications.appdata.xml',
    po_dir: join_paths(meson.source_root (), 'po', 'extra'),
    install_dir: join_paths(datadir, 'metainfo'),
    install: true
)

icon_sizes = ['32', '48']

foreach i : icon_sizes
    install_data(
        join_paths('icons', i + '.svg'),
        install_dir: get_option('datadir') / 'icons' / 'hicolor' / i + 'x' + i / 'apps',
        rename: 'io.elementary.settings.applications.svg'
    )
    install_data(
        join_paths('icons', i + '.svg'),
        install_dir: get_option('datadir') / 'icons' / 'hicolor' / i + 'x' + i + '@2' / 'apps',
        rename: 'io.elementary.settings.applications.svg'
    )
endforeach
