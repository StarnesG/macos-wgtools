#!/bin/bash
set -e

# macOS 上构建 wireguard-tools 的脚本
# 此脚本下载并编译 wireguard-tools

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BUILD_DIR="${SCRIPT_DIR}/build"
TOOLS_VERSION="v1.0.20250521"
TOOLS_URL="https://git.zx2c4.com/wireguard-tools/snapshot/wireguard-tools-1.0.20250521.tar.xz"

echo "==> 正在构建 wireguard-tools ${TOOLS_VERSION}"

# 创建构建目录
mkdir -p "${BUILD_DIR}"
cd "${BUILD_DIR}"

# 下载 wireguard-tools
if [ ! -f "wireguard-tools.tar.xz" ]; then
    echo "==> 正在下载 wireguard-tools..."
    curl -L -o wireguard-tools.tar.xz "${TOOLS_URL}"
fi

# 解压
if [ ! -d "wireguard-tools" ]; then
    echo "==> 正在解压 wireguard-tools..."
    tar -xf wireguard-tools.tar.xz
    mv wireguard-tools-* wireguard-tools
fi

# 进入源代码目录
cd wireguard-tools

echo "==> 正在编译 wireguard-tools..."

# wireguard-tools 的标准构建方式
# 检查是否有 src 目录
if [ -d "src" ]; then
    cd src
    # 尝试构建 wg 工具
    if [ -f "Makefile" ]; then
        make WITH_BASHCOMPLETION=no WITH_WGQUICK=no WITH_SYSTEMDUNITS=no
    else
        echo "错误: 找不到 Makefile"
        echo "当前目录: $(pwd)"
        echo "目录内容:"
        ls -la
        exit 1
    fi
else
    # 如果没有 src 目录，尝试在根目录构建
    if [ -f "Makefile" ]; then
        make WITH_BASHCOMPLETION=no WITH_WGQUICK=no WITH_SYSTEMDUNITS=no
    else
        echo "错误: 找不到 Makefile"
        echo "当前目录: $(pwd)"
        echo "目录内容:"
        ls -la
        exit 1
    fi
fi

echo "==> wireguard-tools 构建完成"

# 查找生成的文件
cd "${BUILD_DIR}/wireguard-tools"
WG_BIN=$(find . -name "wg" -type f -perm +111 | grep -v ".o" | head -1)
if [ -n "$WG_BIN" ]; then
    echo "    wg 二进制文件: ${BUILD_DIR}/wireguard-tools/${WG_BIN}"
fi

WG_QUICK=$(find . -path "*/wg-quick/darwin.bash" -o -path "*/wg-quick.bash" | head -1)
if [ -n "$WG_QUICK" ]; then
    echo "    wg-quick 脚本: ${BUILD_DIR}/wireguard-tools/${WG_QUICK}"
fi
