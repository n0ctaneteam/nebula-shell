test_deps = [
    glib_dep,
    gio_dep,
    gtk_dep,
    layer_shell_dep,
    gee_dep,
    gmodule_dep,
    json_dep,
    math_dep,
]

test_names = [
    'test_object',
    'test_observable',
    'test_property',
    'test_binding',
    'test_registry',
    'test_logger',
    'test_service',
    'test_kernel',
    'test_config',
    'test_ipc',
    'test_window',
]

test_inc = include_directories(
    '../core/nebula-shell',
)

foreach test_name : test_names
    exe = executable(
        test_name,
        '@0@.vala'.format(test_name),
        dependencies: test_deps,
        link_with: nebula,
        include_directories: test_inc,
        vala_args: ['--pkg', 'gio-unix-2.0', '--pkg', 'posix'],
        install: false,
    )
    test(test_name, exe)
endforeach