#!/bin/bash
set -e

# macOS 上构建 wireguard-go 的脚本
# 此脚本下载并编译 wireguard-go

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BUILD_DIR="${SCRIPT_DIR}/build"
GO_VERSION="0.0.20250522"
GO_URL="https://git.zx2c4.com/wireguard-go/snapshot/wireguard-go-${GO_VERSION}.tar.xz"

echo "==> 正在构建 wireguard-go ${GO_VERSION}"

# 检查 Go 是否已安装
if ! command -v go &> /dev/null; then
    echo "错误: Go 未安装。请先安装 Go。"
    echo "访问: https://golang.org/dl/"
    exit 1
fi

echo "==> 使用 Go 版本: $(go version)"

# 创建构建目录
mkdir -p "${BUILD_DIR}"
cd "${BUILD_DIR}"

# 下载 wireguard-go
if [ ! -f "wireguard-go.tar.xz" ]; then
    echo "==> 正在下载 wireguard-go..."
    curl -L -o wireguard-go.tar.xz "${GO_URL}"
fi

# 解压
if [ ! -d "wireguard-go" ]; then
    echo "==> 正在解压 wireguard-go..."
    tar -xf wireguard-go.tar.xz
    mv wireguard-go-* wireguard-go
fi

# 构建
cd wireguard-go
echo "==> 正在编译 wireguard-go..."

# 为 macOS 构建
GOOS=darwin GOARCH=amd64 go build -v -o wireguard-go-amd64
GOOS=darwin GOARCH=arm64 go build -v -o wireguard-go-arm64

# 创建通用二进制文件
echo "==> 正在创建通用二进制文件..."
lipo -create -output wireguard-go wireguard-go-amd64 wireguard-go-arm64

echo "==> wireguard-go 构建完成"
echo "    二进制文件: ${BUILD_DIR}/wireguard-go/wireguard-go"
