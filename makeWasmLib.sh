#!/usr/bin/bash
# usage: makeWasmLib.sh [CFILE]

# for absolute pathing
ROOT=$(cd $(dirname $0) && pwd)
cd $ROOT
# name wasm files according to the .c file's name
CFILENAME=$(basename $1 .c)

# steps followed from https://github.com/PLSysSec/rlbox_wasm2c_sandbox/blob/master/LibrarySandbox.md

# Use wasi-clang to combine library sources and wasm2c_sandbox_wrapper.c
# into a wasm module
#SB_WRAPPER=c_src/wasm2c_sandbox_wrapper.c
WASI_SYSROOT=build/_deps/wasiclang-src/share/wasi-sysroot
LDFLAGS="-Wl,--export-all -Wl,--growable-table"
WASI_CLANG=build/_deps/wasiclang-src/bin/clang
$WASI_CLANG --sysroot $WASI_SYSROOT $LDFLAGS $1 -o $ROOT/test/lib$CFILENAME.wasm

# use modified wasm2c to turn the generated .wasm file into a .c and .h
build/_deps/mod_wasm2c-src/bin/wasm2c -o $ROOT/test/libWasm$CFILENAME.c $ROOT/test/lib$CFILENAME.wasm

# finally, compile the .c and .h along with the wasm runtime into a shared library
gcc -shared -fPIC -O3 -o $ROOT/test/libWasm$CFILENAME.so $ROOT/test/libWasm$CFILENAME.c build/_deps/mod_wasm2c-src/wasm2c/wasm-rt-os-unix.c build/_deps/mod_wasm2c-src/wasm2c/wasm-rt-os-win.c build/_deps/mod_wasm2c-src/wasm2c/wasm-rt-wasi.c build/_deps/mod_wasm2c-src/wasm2c/wasm-rt-impl.c build/_deps/mod_wasm2c-src/wasm2c/wasm-rt.h -I build/_deps/mod_wasm2c-src/wasm2c

cd -
