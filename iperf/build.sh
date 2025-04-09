#!/bin/bash

if [ -n "${BASH_SOURCE[0]}" ]; then
    script_path="${BASH_SOURCE[0]}"
else
    script_path="$0"
fi

script_dir=$(dirname "$script_path")

if [[ -f "${script_dir}/Makefile" ]]; then
    make clean
fi

./configure --prefix=$1 --host=$2 CC=$3

# if [[ "$1" == *"riscv"* ]]; then
#     if [[ "$1" == *"musl"* ]]; then
#         ./configure --prefix=$1 --host=riscv64-linux-musl CC=riscv64-buildroot-linux-musl-gcc
#     else
#         ./configure --prefix=$1 --host=riscv64-linux-gnu CC=riscv64-linux-gnu-gcc
#     fi
# else
#     if [[ "$1" == *"musl"* ]]; then
#         ./configure --prefix=$1 --host=loongarch64-linux-musl CC=loongarch64-linux-musl-gcc
#     else
#         ./configure --prefix=$1 --host=loongarch64-linux-gnu CC=loongarch64-linux-gnu-gcc
#     fi
# fi

make V=1 -j
cp src/iperf3 $1
cp src/.libs/libiperf.so $1
