project(
    'applications',
    'vala', 'c',
    version: '2.1.7'
)

gettext_name = meson.project_name() + '-plug'
gnome = import('gnome')
i18n = import('i18n')

prefix = get_option('prefix')
datadir = join_paths(prefix, get_option('datadir'))
libdir = join_paths(prefix, get_option('libdir'))

vapi_dir = join_paths(meson.current_source_dir(), 'vapi')
add_project_arguments(
    ['--vapidir', vapi_dir],
    language: 'vala'
)

add_project_arguments(
    '-DGETTEXT_PACKAGE="@0@"'.format(gettext_name),
    language:'c'
)

subdir('data')
subdir('src')
subdir('po')
