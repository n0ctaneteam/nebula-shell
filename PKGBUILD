# Maintainer: n0ctanete <n0ctanete@proton.me>
pkgname=nebula-shell
pkgver=1.0.0
pkgrel=1
pkgdesc="Fast, lightweight desktop widgets and shell framework for Wayland"
arch=('x86_64' 'aarch64')
url="https://github.com/n0ctaneteam/nebula-shell"
license=('Apache-2.0')
depends=(
    'gtk4'
    'gtk4-layer-shell'
    'libgee'
    'json-glib'
    'python'
    'gobject-introspection'
)
makedepends=(
    'meson'
    'ninja'
    'vala'
    'gcc'
    'git'
    'python'
    'gobject-introspection'
)
optdepends=()
provides=('nebula-shell')
conflicts=('nebula-shell-git')
source=("$pkgname::git+https://github.com/n0ctaneteam/nebula-shell.git#tag=v$pkgver")
sha256sums=('SKIP')

pkgver() {
    cd "$pkgname"
    local version=$(git describe --tags --abbrev=0 2>/dev/null | sed 's/^v//')
    if [ -n "$version" ]; then
        echo "$version"
    else
        echo "1.0.0"
    fi
}

build() {
    cd "$pkgname"
    rm -rf builddir
    meson setup builddir \
        --prefix=/usr \
        --buildtype=plain \
        -Dwerror=false
    ninja -C builddir
}

check() {
    cd "$pkgname"
    meson test -C builddir --print-errorlogs
}

package() {
    cd "$pkgname"
    DESTDIR="$pkgdir" ninja -C builddir install

    # Install Python bindings
    local site_packages=$(python3 -c "import site; print(site.getsitepackages()[0])")
    install -dm755 "$pkgdir$site_packages"
    find bindings/nebula_shell -name '__pycache__' -exec rm -rf {} + 2>/dev/null || true
    cp -r bindings/nebula_shell "$pkgdir$site_packages/"

    # Ensure config directory exists
    install -dm755 "$pkgdir/etc/nebula-shell"

    # Install default shell.py if not already present
    if [ ! -f "$pkgdir/etc/nebula-shell/shell.py" ]; then
        install -Dm644 data/shell.py "$pkgdir/etc/nebula-shell/shell.py"
    fi

    # Install XDG autostart
    install -Dm644 data/nebula-shell.desktop \
        "$pkgdir/usr/share/xdg/autostart/nebula-shell.desktop"
}

pre_install() {
    # Migrate from config.py to shell.py
    if [ -f "/etc/nebula-shell/config.py" ] && [ ! -f "/etc/nebula-shell/shell.py" ]; then
        echo "Migrating config.py -> shell.py..."
        mv "/etc/nebula-shell/config.py" "/etc/nebula-shell/shell.py"
    fi
}

post_remove() {
    # Clean up old config.py if shell.py exists
    if [ -f "/etc/nebula-shell/config.py" ] && [ -f "/etc/nebula-shell/shell.py" ]; then
        rm -f "/etc/nebula-shell/config.py"
    fi
}
