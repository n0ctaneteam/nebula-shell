project('nebula-shell', 'vala', 'c',
    version: '0.1.0',
    license: 'Apache-2.0',
    meson_version: '>=0.62.0'
)

project_owner = 'N0ctaneTeam'
project_url = 'https://github.com/n0ctaneteam/nebula-shell'
project_docs = 'https://n0ctaneteam.github.io/docs/nebula-shell'

gtk4_dep = dependency('gtk4')
gtk4_layer_shell_dep = dependency('gtk4-layer-shell-0')
glib_dep = dependency('glib-2.0')
gobject_dep = dependency('gobject-2.0')
gio_dep = dependency('gio-2.0')
lua_dep = dependency('lua5.4', required: false)
if not lua_dep.found()
    lua_dep = dependency('lua5.3', required: false)
endif
if not lua_dep.found()
    lua_dep = dependency('lua5.2', required: false)
endif

add_project_arguments(['--vapidir', meson.current_source_dir() / 'vapi'], language: 'vala')

src_files = files(
    'src/nebula_shell.vala',
    'src/core/application.vala',
    'src/core/config_loader.vala',
    'src/core/widget_builder.vala',
    'src/core/lua_bridge.vala',
    'src/core/css_manager.vala',
    'src/core/layer_shell.vala',
    'src/core/registry.vala',
    'src/utils/logger.vala',
    'src/utils/file_utils.vala'
)

cli_files = files(
    'src/cli/main.vala',
    'src/cli/commands.vala',
    'src/cli/runner.vala',
    'src/cli/inspector.vala',
    'src/cli/schema_gen.vala'
)

executable('nebula-shell',
    src_files + cli_files,
    dependencies: [gtk4_dep, gtk4_layer_shell_dep, glib_dep, gobject_dep, gio_dep, lua_dep],
    install: true,
    install_dir: get_option('bindir')
)

install_subdir('etc/nebula-shell',
    install_dir: get_option('sysconfdir'),
    strip_directory: false
)

install_data('data/nebula-shell.desktop',
    install_dir: get_option('datadir') / 'applications'
)

install_data('data/nebula-shell.1',
    install_dir: get_option('mandir') / 'man1'
)
