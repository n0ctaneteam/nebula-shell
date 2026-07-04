glib_dep = dependency('glib-2.0')
gio_dep = dependency('gio-2.0')
gtk_dep = dependency('gtk4')
layer_shell_dep = dependency('gtk4-layer-shell-0')
gee_dep = dependency('gee-0.8')
gmodule_dep = dependency('gmodule-2.0')
json_dep = dependency('json-glib-1.0')
math_dep = meson.get_compiler('c').find_library('m', required: false)

nebula_sources = files(
    'application.vala',
    'object.vala',
    'manager.vala',
    'registry.vala',
    'singleton_registry.vala',
    'service.vala',
    'service_registry.vala',
    'kernel.vala',
    'runtime.vala',
    'logger.vala',
    'version.vala',
    'config.vala',
    'config_manager.vala',
    'plugin.vala',
    'plugin_manager.vala',
    'ipc.vala',
    'ipc_message.vala',
    'ipc_server.vala',
    'ipc_client.vala',
    'theme.vala',
    'theme_manager.vala',
    'style_context.vala',
    'css_helper.vala',
    'observable.vala',
    'property.vala',
    'binding.vala',
    'computed.vala',
    'animation.vala',
    'animation_scheduler.vala',
    'easing.vala',
    'timeline.vala',
    'fade_animation.vala',
    'slide_animation.vala',
    'scale_animation.vala',
    'anchor.vala',
    'layer.vala',
    'keyboard_mode.vala',
    'monitor.vala',
    'layer_shell.vala',
    'window.vala',
    'workspace.vala',
    'window_info.vala',
    'monitor_info.vala',
    'compositor.vala',
    'hyprland_backend.vala',
    'event.vala',
    'event_handler.vala',
    'click_event.vala',
    'hover_event.vala',
    'keyboard_event.vala',
    'scroll_event.vala',
    'drag_event.vala',
    'focus_event.vala',
    'widget.vala',
    'container.vala',
    'box.vala',
    'stack.vala',
    'grid.vala',
    'overlay.vala',
    'label.vala',
    'image.vala',
    'icon.vala',
    'button.vala',
    'entry.vala',
    'separator.vala',
    'spacer.vala',
    'cli.vala',
    'cli_init.vala',
    'cli_run.vala',
    'cli_doctor.vala',
    'cli_inspect.vala',
    'cli_dev.vala',
    'cli_format.vala',
    'cli_plugin.vala',
    'cli_version.vala',
    'dev_tools.vala',
    'hot_reload.vala',
    'live_css.vala',
    'config_reload.vala',
    'widget_inspector.vala',
    'performance_overlay.vala',
    'frame_timing.vala',
)

nebula = library(
    'nebula-shell',

    nebula_sources,

    dependencies: [
        glib_dep,
        gio_dep,
        gtk_dep,
        layer_shell_dep,
        gee_dep,
        gmodule_dep,
        json_dep,
        math_dep,
    ],

    vala_args: ['--pkg', 'gio-unix-2.0', '--pkg', 'posix'],
    vala_header: 'nebula-shell.h',
    vala_vapi: 'nebula-shell-1.0.vapi',

    install: true,
)

executable(
    'nebula-shell',
    'main.vala',
    link_with: nebula,
    dependencies: [
        glib_dep,
        gio_dep,
        gtk_dep,
        layer_shell_dep,
        gee_dep,
        gmodule_dep,
        json_dep,
        math_dep,
    ],
    vala_args: ['--pkg', 'gio-unix-2.0', '--pkg', 'posix'],
    install: true,
)

nebula_header = meson.current_build_dir() / 'nebula-shell.h'

gir = gnome.generate_gir(

    nebula,

    sources: [nebula_header],

    namespace: 'NebulaShell',

    nsversion: '1.0',

    identifier_prefix: 'NebulaShell',

    symbol_prefix: 'nebula_shell',

    install: true,
)
