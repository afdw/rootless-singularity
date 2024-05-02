all: rootless-singularity-install.tar.gz

busybox:
	wget -O busybox https://www.busybox.net/downloads/binaries/1.35.0-x86_64-linux-musl/busybox
	chmod +x busybox

rootless.sif: rootless.def busybox preconfigure.sh
	sudo singularity build -F rootless.sif rootless.def

archlinux-bootstrap-x86_64.tar.zst:
	wget -O archlinux-bootstrap-x86_64.tar.zst https://geo.mirror.pkgbuild.com/iso/latest/archlinux-bootstrap-x86_64.tar.zst

fakeroot-x86_64.pkg.tar.zst:
	wget -O fakeroot-x86_64.pkg.tar.zst https://archlinux.org/packages/core/x86_64/fakeroot/download/

root.x86_64: archlinux-bootstrap-x86_64.tar.zst fakeroot-x86_64.pkg.tar.zst
	tar -xvf archlinux-bootstrap-x86_64.tar.zst
	touch root.x86_64
	mkdir -p fakeroot-x86_64
	tar -xvf fakeroot-x86_64.pkg.tar.zst -C fakeroot-x86_64
	cp -R fakeroot-x86_64/usr root.x86_64

root.x86_64/var/preconfigured: rootless.sif root.x86_64
	./run.sh --no-import /preconfigure.sh

rootless-singularity-install: rootless.sif root.x86_64/var/preconfigured run.sh
	mkdir rootless-singularity-install
	cp -R rootless.sif root.x86_64 run.sh rootless-singularity-install

rootless-singularity-install.tar.gz: rootless-singularity-install
	tar -zcvf rootless-singularity-install.tar.gz rootless-singularity-install

clean:
	chmod -Rf 777 root.x86_64 rootless-singularity-install || true
	rm -rf busybox rootless.sif archlinux-bootstrap-x86_64.tar.zst fakeroot-x86_64.pkg.tar.zst root.x86_64 fakeroot-x86_64 rootless-singularity-install

.PHONY: all clean

.NOTPARALLEL:
