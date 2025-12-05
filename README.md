# WireGuard Tools macOS 离线安装包构建工具

本仓库包含用于在 macOS 上构建 WireGuard 工具离线安装包的脚本。

## 构建内容

安装包包含：
- **wg** - WireGuard 配置工具
- **wg-quick** - WireGuard 隧道快速设置脚本
- **wireguard-go** - WireGuard 用户态实现

## 前置要求

构建安装包需要：
- macOS (10.15 或更高版本)
- Xcode 命令行工具 (`xcode-select --install`)
- Go 编程语言 (https://golang.org/dl/)
- 互联网连接（用于下载源代码）

## 构建说明

### 快速开始

运行主构建脚本：

```bash
./create-macos-installer.sh
```

脚本将会：
1. 从官方仓库下载 WireGuard 源代码
2. 编译 wireguard-tools 和 wireguard-go
3. 创建 macOS .pkg 安装包
4. 输出文件到 `output/` 目录

### 构建输出

构建成功后，在 `output/` 目录中可以找到：
- `WireGuard-Tools-{VERSION}.pkg` - 组件包
- `WireGuard-Tools-{VERSION}-Installer.pkg` - 分发包（推荐使用）
- `README.txt` - 安装说明

### 单独构建脚本

也可以单独运行各个构建脚本：

```bash
# 仅构建 wireguard-tools
./build-wireguard-tools.sh

# 仅构建 wireguard-go
./build-wireguard-go.sh
```

## 安装

### 图形界面安装
1. 双击 `WireGuard-Tools-{VERSION}-Installer.pkg`
2. 按照安装向导操作
3. 在提示时输入管理员密码

### 命令行安装
```bash
sudo installer -pkg output/WireGuard-Tools-*-Installer.pkg -target /
```

## 安装位置

所有工具安装到：
- 二进制文件：`/usr/local/bin/`
- 手册页：`/usr/local/share/man/man8/`

## 使用方法

安装后：

```bash
# 查看 WireGuard 接口状态
wg

# 创建 WireGuard 接口
sudo wg-quick up wg0

# 停止 WireGuard 接口
sudo wg-quick down wg0

# 运行 wireguard-go 用户态守护进程
sudo wireguard-go wg0
```

## 架构支持

安装包创建的通用二进制文件支持：
- Intel (x86_64)
- Apple Silicon (arm64)

## 源代码仓库

- wireguard-tools: https://git.zx2c4.com/wireguard-tools
- wireguard-go: https://git.zx2c4.com/wireguard-go

## 版本

当前版本：
- wireguard-tools: v1.0.20250521
- wireguard-go: 0.0.20250522

## 许可证

WireGuard 采用 GPLv2 许可证。
版权所有 (C) 2015-2025 Jason A. Donenfeld

## 故障排除

### 构建失败提示 "Go not found"
从 https://golang.org/dl/ 安装 Go 或使用 Homebrew：
```bash
brew install go
```

### 构建失败提示 "command not found: pkgbuild"
安装 Xcode 命令行工具：
```bash
xcode-select --install
```

### 安装时权限被拒绝
使用 `sudo` 进行安装：
```bash
sudo installer -pkg output/WireGuard-Tools-*-Installer.pkg -target /
```

## 分发

生成的 `.pkg` 文件是完全独立的，可以：
- 复制到 U 盘
- 通过网络共享分发
- 在没有互联网连接的机器上安装
- 用于企业部署

## 清理构建

重新开始构建：
```bash
rm -rf build/ package/ output/
./create-macos-installer.sh
```

## 注意事项

- 构建过程需要互联网连接来下载源代码
- 构建完成后，安装包可以离线使用
- 安装包需要管理员权限才能安装
- 二进制文件从官方 WireGuard 源代码编译
- 未对源代码进行任何修改
