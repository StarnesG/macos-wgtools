#!/bin/bash
# 验证构建文件是否存在

BUILD_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/build"

echo "=========================================="
echo "验证 WireGuard 构建文件"
echo "=========================================="
echo ""

# 检查 wg
if [ -f "${BUILD_DIR}/wireguard-tools/src/wg" ]; then
    echo "✅ wg 二进制文件存在"
    echo "   路径: ${BUILD_DIR}/wireguard-tools/src/wg"
    echo "   大小: $(ls -lh "${BUILD_DIR}/wireguard-tools/src/wg" | awk '{print $5}')"
    echo "   类型: $(file "${BUILD_DIR}/wireguard-tools/src/wg")"
else
    echo "❌ wg 二进制文件不存在"
fi

echo ""

# 检查 wg-quick
if [ -f "${BUILD_DIR}/wireguard-tools/src/wg-quick/darwin.bash" ]; then
    echo "✅ wg-quick 脚本存在"
    echo "   路径: ${BUILD_DIR}/wireguard-tools/src/wg-quick/darwin.bash"
    echo "   大小: $(ls -lh "${BUILD_DIR}/wireguard-tools/src/wg-quick/darwin.bash" | awk '{print $5}')"
else
    echo "❌ wg-quick 脚本不存在"
fi

echo ""

# 检查 wireguard-go
if [ -f "${BUILD_DIR}/wireguard-go/wireguard-go" ]; then
    echo "✅ wireguard-go 二进制文件存在"
    echo "   路径: ${BUILD_DIR}/wireguard-go/wireguard-go"
    echo "   大小: $(ls -lh "${BUILD_DIR}/wireguard-go/wireguard-go" | awk '{print $5}')"
    echo "   类型: $(file "${BUILD_DIR}/wireguard-go/wireguard-go")"
else
    echo "❌ wireguard-go 二进制文件不存在"
fi

echo ""
echo "=========================================="
