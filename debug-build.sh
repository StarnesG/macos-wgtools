#!/bin/bash
# 调试脚本 - 检查 wireguard-tools 源代码结构

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BUILD_DIR="${SCRIPT_DIR}/build"

echo "==> 检查 wireguard-tools 目录结构"

if [ ! -d "${BUILD_DIR}/wireguard-tools" ]; then
    echo "错误: wireguard-tools 目录不存在"
    echo "请先运行: ./build-wireguard-tools.sh"
    exit 1
fi

cd "${BUILD_DIR}/wireguard-tools"

echo ""
echo "==> 顶层目录内容:"
ls -la

echo ""
echo "==> src 目录内容:"
if [ -d "src" ]; then
    ls -la src/
else
    echo "src 目录不存在"
fi

echo ""
echo "==> 查找 Makefile:"
find . -name "Makefile" -type f

echo ""
echo "==> 查找 wg 相关文件:"
find . -name "wg*" -type f | head -20

echo ""
echo "==> 查找 .c 源文件:"
find . -name "*.c" -type f | head -10
