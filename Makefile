DOCKER ?= docker.educg.net/cg/os-contest:20250226

BUILD_DIR = build

all: sdcard

build-all: build-rv build-la

${BUILD_DIR}:
	mkdir -p ${BUILD_DIR}

BUILD_RV_MUSL = riscv-rv-musl.stamp
BUILD_RV_GLIBC = riscv-rv-glibc.stamp
BUILD_LA_MUSL = loongarch-la-musl.stamp
BUILD_LA_GLIBC = loongarch-la-glibc.stamp
SDCARD_RV_IMG_GZ = sdcard-rv.img.gz
SDCARD_LA_IMG_GZ = sdcard-la.img.gz

$(BUILD_DIR)/riscv-musl:
	mkdir -p $(BUILD_DIR)/riscv-musl

$(BUILD_DIR)/riscv-glibc:
	mkdir -p $(BUILD_DIR)/riscv-glibc

$(BUILD_DIR)/loongarch-musl:
	mkdir -p $(BUILD_DIR)/loongarch-musl

$(BUILD_DIR)/loongarch-glibc:
	mkdir -p $(BUILD_DIR)/loongarch-glibc

build-rv-musl-sub: $(BUILD_DIR)/riscv-musl
	@echo "Building riscv-musl..."
	make -f Makefile.sub clean
	mkdir -p sdcard/riscv/musl
	make -f Makefile.sub all PREFIX=riscv64-buildroot-linux-musl- DESTDIR=$(CURDIR)/sdcard/riscv/musl STAMPDIR=$(BUILD_DIR)/riscv-musl

$(BUILD_RV_MUSL): build-rv-musl-sub
	cp /opt/riscv64--musl--bleeding-edge-2020.08-1/riscv64-buildroot-linux-musl/sysroot/lib/libc.so sdcard/riscv/musl/lib
	sed -E -i 's/#### OS COMP TEST GROUP ([^ ]+) ([^ ]+) ####/#### OS COMP TEST GROUP \1 \2-musl ####/g' sdcard/riscv/musl/*_testcode.sh
	touch $(BUILD_RV_MUSL)

build-rv-glic-sub: $(BUILD_DIR)/riscv-glibc
	@echo "Building riscv-glibc..."
	make -f Makefile.sub clean
	mkdir -p sdcard/riscv/glibc
	make -f Makefile.sub all PREFIX=riscv64-linux-gnu- DESTDIR=$(CURDIR)/sdcard/riscv/glibc STAMPDIR=$(BUILD_DIR)/riscv-glibc

$(BUILD_RV_GLIBC): build-rv-glic-sub
	cp /usr/riscv64-linux-gnu/lib/libc.so sdcard/riscv/glibc/lib
	sed -E -i 's/#### OS COMP TEST GROUP ([^ ]+) ([^ ]+) ####/#### OS COMP TEST GROUP \1 \2-glibc ####/g' sdcard/riscv/glibc/*_testcode.sh
	touch $(BUILD_RV_GLIBC)

build-rv: $(BUILD_DIR) $(BUILD_RV_MUSL) $(BUILD_RV_GLIBC)


build-la-musl-sub: $(BUILD_DIR)/loongarch-musl
	@echo "Building loongarch-musl..."
	make -f Makefile.sub clean
	mkdir -p sdcard/loongarch/musl
	make -f Makefile.sub all PREFIX=loongarch64-linux-musl- DESTDIR=$(CURDIR)/sdcard/loongarch/musl STAMPDIR=$(BUILD_DIR)/loongarch-musl

$(BUILD_LA_MUSL): build-la-musl-sub
	cp /opt/loongarch64-linux-musl-cross/loongarch64-linux-musl/lib/libc.so sdcard/loongarch/musl/lib
	sed -E -i 's/#### OS COMP TEST GROUP ([^ ]+) ([^ ]+) ####/#### OS COMP TEST GROUP \1 \2-musl ####/g' sdcard/loongarch/musl/*_testcode.sh
	touch $(BUILD_LA_MUSL)

build-la-glibc-sub: $(BUILD_DIR)/loongarch-glibc
	@echo "Building loongarch-glibc..."
	make -f Makefile.sub clean
	mkdir -p sdcard/loongarch/glibc
	make -f Makefile.sub all PREFIX=loongarch64-linux-gnu- DESTDIR=$(CURDIR)/sdcard/loongarch/glibc STAMPDIR=$(BUILD_DIR)/loongarch-glibc

$(BUILD_LA_GLIBC): build-la-glibc-sub
	cp /opt/gcc-13.2.0-loongarch64-linux-gnu/sysroot/usr/lib64/libc.so sdcard/loongarch/glibc/lib
	sed -E -i 's/#### OS COMP TEST GROUP ([^ ]+) ([^ ]+) ####/#### OS COMP TEST GROUP \1 \2-glibc ####/g' sdcard/loongarch/glibc/*_testcode.sh
	touch $(BUILD_LA_GLIBC)

build-la: ${BUILD_DIR} $(BUILD_LA_MUSL) $(BUILD_LA_MUSL)

$(SDCARD_RV_IMG_GZ): $(BUILD_DIR) $(BUILD_DIR)/riscv-musl $(BUILD_DIR)/riscv-glibc
	dd if=/dev/zero of=sdcard-rv.img count=4096 bs=1M
	mkfs.ext4 sdcard-rv.img
	mkdir -p mnt
	guestmount -a sdcard-rv.img -m /dev/sda mnt
	cp -rL sdcard/riscv/* mnt
	guestunmount mnt
	rm -f sdcard-rv.img.gz
	gzip sdcard-rv.img

$(SDCARD_LA_IMG_GZ): $(BUILD_DIR) $(BUILD_DIR)/loongarch-musl $(BUILD_DIR)/loongarch-glibc
	dd if=/dev/zero of=sdcard-la.img count=4096 bs=1M
	mkfs.ext4 sdcard-la.img
	mkdir -p mnt
	guestmount -a sdcard-la.img -m /dev/sda mnt
	cp -rL sdcard/loongarch/* mnt
	guestunmount mnt
	rm -f sdcard-la.img.gz
	gzip sdcard-la.img

sdcard: $(BUILD_RV_MUSL) $(BUILD_RV_GLIBC) $(BUILD_LA_MUSL) $(BUILD_LA_GLIBC) $(SDCARD_RV_IMG_GZ) $(SDCARD_LA_IMG_GZ)

clean:
	make -f Makefile.sub clean
	rm -rf sdcard/riscv/*
	rm -rf sdcard/loongarch/*
	rm -f sdcard-la.img.gz
	rm -f sdcard-rv.img.gz
	rm -rf build
	rm -f $(BUILD_RV_MUSL)
	rm -f $(BUILD_RV_GLIBC)
	rm -f $(BUILD_LA_MUSL)
	rm -f $(BUILD_LA_GLIBC)
	rm -rf mnt

# docker:
# 	docker run --rm -it -v .:/code --entrypoint bash -w /code --privileged $(DOCKER)


.PHONY: