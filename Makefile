DOCKER ?= docker.educg.net/cg/os-contest:20250226

all: sdcard

build-all: build-rv build-la

build-rv:
	make -f Makefile.sub clean
	mkdir -p sdcard/riscv/musl
	make -f Makefile.sub PREFIX=riscv64-buildroot-linux-musl- DESTDIR=$(CURDIR)/sdcard/riscv/musl
	cp /opt/riscv64--musl--bleeding-edge-2020.08-1/riscv64-buildroot-linux-musl/sysroot/lib/libc.so sdcard/riscv/musl/lib
	sed -E -i 's/#### OS COMP TEST GROUP ([^ ]+) ([^ ]+) ####/#### OS COMP TEST GROUP \1 \2-musl ####/g' sdcard/riscv/musl/*_testcode.sh

	make -f Makefile.sub clean
	mkdir -p sdcard/riscv/glibc
	make -f Makefile.sub PREFIX=riscv64-linux-gnu- DESTDIR=$(CURDIR)/sdcard/riscv/glibc
	cp /usr/riscv64-linux-gnu/lib/libc.so sdcard/riscv/glibc/lib
	sed -E -i 's/#### OS COMP TEST GROUP ([^ ]+) ([^ ]+) ####/#### OS COMP TEST GROUP \1 \2-glibc ####/g' sdcard/riscv/glibc/*_testcode.sh

build-la:
	make -f Makefile.sub clean
	mkdir -p sdcard/loongarch/musl
	make -f Makefile.sub PREFIX=loongarch64-linux-musl- DESTDIR=$(CURDIR)/sdcard/loongarch/musl
	cp /opt/loongarch64-linux-musl-cross/loongarch64-linux-musl/lib/libc.so sdcard/loongarch/musl/lib
	sed -E -i 's/#### OS COMP TEST GROUP ([^ ]+) ([^ ]+) ####/#### OS COMP TEST GROUP \1 \2-musl ####/g' sdcard/loongarch/musl/*_testcode.sh

	make -f Makefile.sub clean
	mkdir -p sdcard/loongarch/glibc
	make -f Makefile.sub PREFIX=loongarch64-linux-gnu- DESTDIR=$(CURDIR)/sdcard/loongarch/glibc
	cp /opt/gcc-13.2.0-loongarch64-linux-gnu/sysroot/usr/lib64/libc.so sdcard/loongarch/glibc/lib
	sed -E -i 's/#### OS COMP TEST GROUP ([^ ]+) ([^ ]+) ####/#### OS COMP TEST GROUP \1 \2-glibc ####/g' sdcard/loongarch/glibc/*_testcode.sh

sdcard: build-all .PHONY
	dd if=/dev/zero of=sdcard-rv.img count=4096 bs=1M
	mkfs.ext4 sdcard-rv.img
	mkdir -p mnt
	guestmount -a sdcard-rv.img -m /dev/sda mnt
	cp -rL sdcard/riscv/* mnt
	guestumount mnt
	gzip sdcard-rv.img

	dd if=/dev/zero of=sdcard-la.img count=4096 bs=1M
	mkfs.ext4 sdcard-la.img
	mkdir -p mnt
	guestmount -a sdcard-la.img -m /dev/sda mnt
	cp -rL sdcard/loongarch/* mnt
	guestumount mnt
	gzip sdcard-la.img


clean:
	make -f Makefile.sub clean
	rm -rf sdcard/riscv/*
	rm -rf sdcard/loongarch/*
	rm -f sdcard-la.img.gz
	rm -f sdcard-rv.img.gz

# docker:
# 	docker run --rm -it -v .:/code --entrypoint bash -w /code --privileged $(DOCKER)


.PHONY:
