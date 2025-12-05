#!/bin/bash
set -e

# 创建 WireGuard macOS 离线安装包的主脚本
# 此脚本创建可以分发和离线安装的 .pkg 安装包

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BUILD_DIR="${SCRIPT_DIR}/build"
PKG_DIR="${SCRIPT_DIR}/package"
PKG_ROOT="${PKG_DIR}/root"
PKG_SCRIPTS="${PKG_DIR}/scripts"
OUTPUT_DIR="${SCRIPT_DIR}/output"
VERSION="1.0.20250521"

echo "==> 正在创建 WireGuard macOS 离线安装包"
echo "    版本: ${VERSION}"

# 清理之前的构建
rm -rf "${PKG_DIR}" "${OUTPUT_DIR}"
mkdir -p "${PKG_ROOT}/usr/local/bin"
mkdir -p "${PKG_ROOT}/usr/local/share/man/man8"
mkdir -p "${PKG_SCRIPTS}"
mkdir -p "${OUTPUT_DIR}"

# 构建 wireguard-tools
echo ""
bash "${SCRIPT_DIR}/build-wireguard-tools.sh"

# 构建 wireguard-go
echo ""
bash "${SCRIPT_DIR}/build-wireguard-go.sh"

# 复制二进制文件到包根目录
echo ""
echo "==> 正在打包二进制文件..."

# 查找并复制 wg 二进制文件
WG_BIN=$(find "${BUILD_DIR}/wireguard-tools" -name "wg" -type f -perm +111 2>/dev/null | grep -v ".o" | head -1)
if [ -n "$WG_BIN" ] && [ -f "$WG_BIN" ]; then
    echo "    找到 wg: $WG_BIN"
    cp "$WG_BIN" "${PKG_ROOT}/usr/local/bin/"
else
    echo "错误: 找不到 wg 二进制文件"
    echo "搜索路径: ${BUILD_DIR}/wireguard-tools"
    exit 1
fi

# 查找并复制 wg-quick 脚本
WG_QUICK=$(find "${BUILD_DIR}/wireguard-tools" -name "darwin.bash" -o -name "wg-quick.bash" 2>/dev/null | head -1)
if [ -z "$WG_QUICK" ]; then
    # 如果找不到，尝试查找任何 wg-quick 脚本
    WG_QUICK=$(find "${BUILD_DIR}/wireguard-tools" -path "*/wg-quick/*" -name "*.bash" 2>/dev/null | head -1)
fi
if [ -n "$WG_QUICK" ] && [ -f "$WG_QUICK" ]; then
    echo "    找到 wg-quick: $WG_QUICK"
    cp "$WG_QUICK" "${PKG_ROOT}/usr/local/bin/wg-quick"
else
    echo "错误: 找不到 wg-quick 脚本"
    echo "搜索路径: ${BUILD_DIR}/wireguard-tools"
    exit 1
fi

# 复制 wireguard-go
if [ -f "${BUILD_DIR}/wireguard-go/wireguard-go" ]; then
    echo "    找到 wireguard-go: ${BUILD_DIR}/wireguard-go/wireguard-go"
    cp "${BUILD_DIR}/wireguard-go/wireguard-go" "${PKG_ROOT}/usr/local/bin/"
else
    echo "错误: 找不到 wireguard-go 二进制文件"
    echo "搜索路径: ${BUILD_DIR}/wireguard-go"
    exit 1
fi

# 设置权限
chmod 755 "${PKG_ROOT}/usr/local/bin/wg"
chmod 755 "${PKG_ROOT}/usr/local/bin/wg-quick"
chmod 755 "${PKG_ROOT}/usr/local/bin/wireguard-go"

# 复制手册页（如果可用）
for manpage in wg.8 wg-quick.8; do
    if [ -f "${BUILD_DIR}/wireguard-tools/src/man/${manpage}" ]; then
        cp "${BUILD_DIR}/wireguard-tools/src/man/${manpage}" "${PKG_ROOT}/usr/local/share/man/man8/"
    elif [ -f "${BUILD_DIR}/wireguard-tools/src/${manpage}" ]; then
        cp "${BUILD_DIR}/wireguard-tools/src/${manpage}" "${PKG_ROOT}/usr/local/share/man/man8/"
    elif [ -f "${BUILD_DIR}/wireguard-tools/man/${manpage}" ]; then
        cp "${BUILD_DIR}/wireguard-tools/man/${manpage}" "${PKG_ROOT}/usr/local/share/man/man8/"
    fi
done

# 创建安装后脚本
cat > "${PKG_SCRIPTS}/postinstall" << 'EOF'
#!/bin/bash
set -e

echo "WireGuard 工具安装成功！"
echo ""
echo "已安装的二进制文件："
echo "  - /usr/local/bin/wg"
echo "  - /usr/local/bin/wg-quick"
echo "  - /usr/local/bin/wireguard-go"
echo ""
echo "开始使用，请运行: wg --help"

exit 0
EOF

chmod 755 "${PKG_SCRIPTS}/postinstall"

# 构建包
echo ""
echo "==> 正在构建 macOS 安装包..."
pkgbuild --root "${PKG_ROOT}" \
         --scripts "${PKG_SCRIPTS}" \
         --identifier "com.wireguard.tools" \
         --version "${VERSION}" \
         --install-location "/" \
         "${OUTPUT_DIR}/WireGuard-Tools-${VERSION}.pkg"

# 创建分发包（可选，提供更好的用户界面）
cat > "${PKG_DIR}/distribution.xml" << EOF
<?xml version="1.0" encoding="utf-8"?>
<installer-gui-script minSpecVersion="1">
    <title>WireGuard 工具</title>
    <organization>WireGuard</organization>
    <domains enable_localSystem="true"/>
    <options customize="never" require-scripts="false" hostArchitectures="x86_64,arm64"/>
    <welcome file="welcome.html" mime-type="text/html"/>
    <license file="license.txt" mime-type="text/plain"/>
    <conclusion file="conclusion.html" mime-type="text/html"/>
    <pkg-ref id="com.wireguard.tools"/>
    <options customize="never" require-scripts="false"/>
    <choices-outline>
        <line choice="default">
            <line choice="com.wireguard.tools"/>
        </line>
    </choices-outline>
    <choice id="default"/>
    <choice id="com.wireguard.tools" visible="false">
        <pkg-ref id="com.wireguard.tools"/>
    </choice>
    <pkg-ref id="com.wireguard.tools" version="${VERSION}" onConclusion="none">WireGuard-Tools-${VERSION}.pkg</pkg-ref>
</installer-gui-script>
EOF

# 创建欢迎消息
cat > "${PKG_DIR}/welcome.html" << 'EOF'
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <style>
        body { font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Helvetica, Arial, sans-serif; }
    </style>
</head>
<body>
    <h1>欢迎使用 WireGuard 工具安装程序</h1>
    <p>此安装程序将在您的 macOS 系统上安装 WireGuard 命令行工具。</p>
    <p>将安装以下工具：</p>
    <ul>
        <li><strong>wg</strong> - WireGuard 配置工具</li>
        <li><strong>wg-quick</strong> - WireGuard 隧道快速设置脚本</li>
        <li><strong>wireguard-go</strong> - WireGuard 用户态实现</li>
    </ul>
</body>
</html>
EOF

# 创建许可证文件
cat > "${PKG_DIR}/license.txt" << 'EOF'
WireGuard 采用 GPLv2 许可证。

版权所有 (C) 2015-2025 Jason A. Donenfeld <Jason@zx2c4.com>。保留所有权利。

本程序是自由软件；您可以根据自由软件基金会发布的 GNU 通用公共许可证
第 2 版或（根据您的选择）任何更高版本的条款重新分发和/或修改它。

本程序的分发是希望它有用，但不提供任何保证；甚至不提供适销性或
特定用途适用性的默示保证。有关更多详细信息，请参阅 GNU 通用公共许可证。
EOF

# 创建完成消息
cat > "${PKG_DIR}/conclusion.html" << 'EOF'
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <style>
        body { font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Helvetica, Arial, sans-serif; }
    </style>
</head>
<body>
    <h1>安装完成</h1>
    <p>WireGuard 工具已成功安装。</p>
    <p>您现在可以使用以下命令：</p>
    <ul>
        <li><code>wg --help</code> - 查看 WireGuard 配置帮助</li>
        <li><code>wg-quick --help</code> - 查看 WireGuard 快速设置帮助</li>
        <li><code>wireguard-go --help</code> - 查看 WireGuard 用户态守护进程帮助</li>
    </ul>
    <p>更多信息，请访问 <a href="https://www.wireguard.com/">https://www.wireguard.com/</a></p>
</body>
</html>
EOF

# 使用分发配置构建产品归档
echo "==> 正在构建分发包..."
productbuild --distribution "${PKG_DIR}/distribution.xml" \
             --package-path "${OUTPUT_DIR}" \
             --resources "${PKG_DIR}" \
             "${OUTPUT_DIR}/WireGuard-Tools-${VERSION}-Installer.pkg"

# 创建 README
cat > "${OUTPUT_DIR}/README.txt" << EOF
WireGuard Tools for macOS - 离线安装包
版本: ${VERSION}
构建日期: $(date)

安装方法：
1. 双击 WireGuard-Tools-${VERSION}-Installer.pkg
2. 按照安装向导操作
3. 工具将安装到 /usr/local/bin/

包含的工具：
- wg: WireGuard 配置工具
- wg-quick: WireGuard 隧道快速设置脚本
- wireguard-go: WireGuard 用户态实现

使用方法：
安装后，打开终端并运行：
  wg --help
  wg-quick --help
  wireguard-go --help

系统要求：
- macOS 10.15 或更高版本
- 安装需要管理员权限

更多信息：
https://www.wireguard.com/

许可证：
WireGuard 采用 GPLv2 许可证
版权所有 (C) 2015-2025 Jason A. Donenfeld
EOF

echo ""
echo "==> ✅ 构建完成！"
echo ""
echo "输出文件："
echo "  - ${OUTPUT_DIR}/WireGuard-Tools-${VERSION}.pkg (组件包)"
echo "  - ${OUTPUT_DIR}/WireGuard-Tools-${VERSION}-Installer.pkg (分发包)"
echo "  - ${OUTPUT_DIR}/README.txt"
echo ""
echo "安装方法："
echo "  sudo installer -pkg ${OUTPUT_DIR}/WireGuard-Tools-${VERSION}-Installer.pkg -target /"
echo ""
echo "或者双击 .pkg 文件使用图形界面安装。"
