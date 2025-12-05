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

echo "==> 当前工作目录: $(pwd)"

# 下载 wireguard-tools
if [ ! -f "wireguard-tools.tar.xz" ]; then
    echo "==> 正在下载 wireguard-tools..."
    curl -L -o wireguard-tools.tar.xz "${TOOLS_URL}"
    echo "==> 下载完成"
else
    echo "==> 使用已下载的 wireguard-tools.tar.xz"
fi

# 检查文件是否存在
if [ ! -f "wireguard-tools.tar.xz" ]; then
    echo "错误: wireguard-tools.tar.xz 文件不存在"
    exit 1
fi

# 解压（强制重新解压以确保完整）
echo "==> 正在解压 wireguard-tools..."
rm -rf wireguard-tools wireguard-tools-*
tar -xf wireguard-tools.tar.xz

# 查找解压后的目录
EXTRACTED_DIR=$(find . -maxdepth 1 -type d -name "wireguard-tools-*" | head -1)
if [ -z "$EXTRACTED_DIR" ]; then
    echo "错误: 解压后找不到 wireguard-tools 目录"
    echo "当前目录内容:"
    ls -la
    exit 1
fi

echo "==> 找到解压目录: $EXTRACTED_DIR"
mv "$EXTRACTED_DIR" wireguard-tools

# 检查目录是否存在
if [ ! -d "wireguard-tools" ]; then
    echo "错误: wireguard-tools 目录不存在"
    exit 1
fi

# 进入源代码目录
cd wireguard-tools
echo "==> 进入目录: $(pwd)"
echo "==> 目录内容:"
ls -la

echo ""
echo "==> 正在编译 wireguard-tools..."

# wireguard-tools 的标准构建方式
# 检查是否有 src 目录
if [ -d "src" ]; then
    echo "==> 找到 src 目录，进入 src"
    cd src
    echo "==> src 目录内容:"
    ls -la
    
    # 尝试构建 wg 工具
    if [ -f "Makefile" ]; then
        echo "==> 找到 Makefile，开始编译..."
        make WITH_BASHCOMPLETION=no WITH_WGQUICK=no WITH_SYSTEMDUNITS=no
    else
        echo "错误: src 目录中找不到 Makefile"
        exit 1
    fi
else
    echo "==> 没有 src 目录，在根目录构建"
    # 如果没有 src 目录，尝试在根目录构建
    if [ -f "Makefile" ]; then
        echo "==> 找到 Makefile，开始编译..."
        make WITH_BASHCOMPLETION=no WITH_WGQUICK=no WITH_SYSTEMDUNITS=no
    else
        echo "错误: 根目录中找不到 Makefile"
        exit 1
    fi
fi

echo ""
echo "==> wireguard-tools 构建完成"

# 查找生成的文件
cd "${BUILD_DIR}/wireguard-tools"
echo "==> 搜索生成的文件..."

# 检查标准位置
if [ -f "src/wg" ]; then
    echo "    ✅ wg 二进制文件: ${BUILD_DIR}/wireguard-tools/src/wg"
else
    echo "    ⚠️  警告: 未找到 wg 二进制文件"
fi

if [ -f "src/wg-quick/darwin.bash" ]; then
    echo "    ✅ wg-quick 脚本: ${BUILD_DIR}/wireguard-tools/src/wg-quick/darwin.bash"
else
    echo "    ⚠️  警告: 未找到 wg-quick 脚本"
fi
