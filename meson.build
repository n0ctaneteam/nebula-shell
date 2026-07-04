project(
    'nebula-shell',
    'vala',
    version: '1.0.0',
    license: 'Apache-2.0',
    default_options: [
        'warning_level=3',
        'buildtype=debugoptimized',
        'cpp_std=none',
    ],
)

gnome = import('gnome')

subdir('core')
subdir('tests')

# Default shell configuration
install_data(
    'data/shell.py',
    install_dir: get_option('sysconfdir') / 'nebula-shell',
)

# XDG autostart
install_data(
    'data/nebula-shell.desktop',
    install_dir: get_option('datadir') / 'xdg' / 'autostart',
)