#!/bin/bash
set -e  # 遇到任何错误立即退出

# 获取脚本所在目录的绝对路径
BUILD_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"

echo "=========================================="
echo "开始编译第三方依赖库"
echo "工作目录: $BUILD_DIR"
echo "=========================================="

# 检查必要的目录和文件
check_prerequisites() {
    echo "检查依赖..."
    
    if ! command -v cmake &> /dev/null; then
        echo "❌ 错误: 找不到 cmake 命令"
        echo "请先安装 CMake"
        exit 1
    fi
    
    if ! command -v make &> /dev/null; then
        echo "❌ 错误: 找不到 make 命令"
        echo "请先安装 build-essential (Linux) 或 Xcode (macOS)"
        exit 1
    fi
    
    echo "✅ 前置检查通过"
}

build_submodule() {
    echo "=========================================="
    echo "编译 $1 库..."
    echo "=========================================="
    
    local build_dir="$BUILD_DIR/$1"
    local install_dir="$BUILD_DIR/install"
    
    cd "$build_dir"
    echo "当前目录: $(pwd)"
    
    if [[ $# -gt 2 && "$2" == "true" ]]; then
        git submodule init
        git submodule update
    fi

    # 清理之前的构建
    if [[ -d "build" && $# -gt 3 && "$3" == "force" ]]; then
        echo "清理之前的构建..."
        rm -rf build
    fi
    
    # 创建安装目录
    mkdir -p "$install_dir"
    
    echo "配置 $1..."
    cmake -S . -B build -DCMAKE_INSTALL_PREFIX="$install_dir" -DCMAKE_BUILD_TYPE=Release
    
    echo "编译并安装 $1..."
    cmake --build build --target install --parallel $(( ($(nproc) + 3) / 4 ))
    
    echo "✅ $1 编译完成"
    echo "安装位置: $install_dir"
    rm -rf build
}

# 主函数
main() {
    check_prerequisites
    # build_submodule Fast-CDR
    build_submodule foonathan_memory_vendor

    echo "=========================================="
    echo "🎉 所有第三方库编译完成!"
    echo "=========================================="
}

# 运行主函数
main "$@"