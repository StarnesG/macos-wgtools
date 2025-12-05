#!/bin/bash
# 测试构建脚本 - 仅测试 wireguard-tools 构建

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "=========================================="
echo "测试 wireguard-tools 构建"
echo "=========================================="
echo ""

# 清理之前的构建
echo "==> 清理之前的构建..."
rm -rf "${SCRIPT_DIR}/build/wireguard-tools"

# 运行构建脚本
echo ""
bash "${SCRIPT_DIR}/build-wireguard-tools.sh"

echo ""
echo "=========================================="
echo "构建测试完成"
echo "=========================================="
echo ""

# 检查结果
BUILD_DIR="${SCRIPT_DIR}/build"

echo "==> 检查构建结果..."
echo ""

if [ -d "${BUILD_DIR}/wireguard-tools" ]; then
    echo "✅ wireguard-tools 目录存在"
    
    # 查找 wg 二进制文件（检查标准位置）
    if [ -f "${BUILD_DIR}/wireguard-tools/src/wg" ]; then
        WG_BIN="${BUILD_DIR}/wireguard-tools/src/wg"
        echo "✅ 找到 wg 二进制文件: $WG_BIN"
        file "$WG_BIN"
        ls -lh "$WG_BIN"
    else
        echo "❌ 未找到 wg 二进制文件"
        echo ""
        echo "所有名为 wg 的文件:"
        find "${BUILD_DIR}/wireguard-tools" -name "wg" -type f 2>/dev/null
    fi
    
    echo ""
    
    # 查找 wg-quick 脚本
    if [ -f "${BUILD_DIR}/wireguard-tools/src/wg-quick/darwin.bash" ]; then
        WG_QUICK="${BUILD_DIR}/wireguard-tools/src/wg-quick/darwin.bash"
        echo "✅ 找到 wg-quick 脚本: $WG_QUICK"
        ls -lh "$WG_QUICK"
    else
        echo "❌ 未找到 wg-quick 脚本"
        echo ""
        echo "所有 .bash 文件:"
        find "${BUILD_DIR}/wireguard-tools" -name "*.bash" 2>/dev/null | head -10
    fi
else
    echo "❌ wireguard-tools 目录不存在"
fi

echo ""
echo "=========================================="
