project(
    'applications',
    'vala', 'c',
    version: '0.1.3.1'
)

gettext_name = meson.project_name() + '-plug'
gnome = import('gnome')
i18n = import('i18n')

add_project_arguments(
    '-DGETTEXT_PACKAGE="@0@"'.format(gettext_name),
    language:'c'
)

test (
    'Vala lint',
    find_program('io.elementary.vala-lint'),
    args: ['-d', join_paths(meson.source_root(), 'src')]
)

subdir('data')
subdir('src')
subdir('po')
