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

# 构建
cd wireguard-tools/src
echo "==> 正在编译 wireguard-tools..."

# 构建 wg 和 wg-quick
make -C wg-quick
make -C wg

echo "==> wireguard-tools 构建完成"
echo "    wg 二进制文件: ${BUILD_DIR}/wireguard-tools/src/wg"
echo "    wg-quick 脚本: ${BUILD_DIR}/wireguard-tools/src/wg-quick/darwin.bash"
