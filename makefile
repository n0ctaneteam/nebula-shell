.PHONY: build install clean run dev

build:
	meson setup build --prefix=/usr
	meson compile -C build

install:
	sudo meson install -C build

clean:
	rm -rf build/

run:
	./build/src/nebula-shell run

dev:
	GTK_DEBUG=interactive ./build/src/nebula-shell run

rebuild:
	rm -rf build/
	meson setup build --prefix=/usr
	meson compile -C build
