project(
    'applications',
    'vala', 'c',
    version: '7.0.1'
)

gettext_name = 'io.elementary.settings.' + meson.project_name()
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

conf_data = configuration_data()
conf_data.set_quoted('LOCALEDIR', join_paths(get_option('prefix'), get_option('localedir')))
conf_data.set_quoted('GETTEXT_PACKAGE', gettext_name)
conf_file = configure_file(
    input: 'src/Config.vala.in',
    output: '@BASENAME@',
    configuration: conf_data
)

subdir('data')
subdir('src')
subdir('po')
