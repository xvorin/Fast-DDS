#!/bin/bash
# 检查是否提供了安装路径参数
if [ -z "$1" ]; then
    echo "错误：请提供安装路径作为第一个参数"
    echo "用法: $0 <install_prefix>"
    exit 1
fi

git submodule init
git submodule update

CURDIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"

mkdir -p $CURDIR/build $CURDIR/install

bash $CURDIR/thirdparty/build.sh

cmake -S . -B build \
    -DCMAKE_INSTALL_PREFIX=$1 \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_PREFIX_PATH="$CURDIR/thirdparty/install/lib/foonathan_memory/cmake" \
    -DTHIRDPARTY=FORCE \
    -DCMAKE_CXX_FLAGS="-Wno-error=conversion"

cmake --build build --target install --parallel $(( ($(nproc) + 3) / 4 ))

rm -fr $CURDIR/thirdparty/install