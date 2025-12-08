# OpenNikki

OpenNikki 是一个 OpenWrt 软件包源，提供 Nikki（Mihomo 内核）及其 LuCI 界面。

本项目固定 LuCI 界面版本，同时自动跟随 [MetaCubeX/mihomo](https://github.com/MetaCubeX/mihomo) 上游更新内核。

## 使用方法

在编译 OpenWrt 时，将本仓库添加为 feeds 源：

```bash
# 在 feeds.conf.default 中添加
src-git nikki https://github.com/vitoegg/OpenNikki.git
```

然后更新并安装：

```bash
./scripts/feeds update nikki
./scripts/feeds install -a -p nikki
```

在 `make menuconfig` 中选择：

```
LuCI -> Applications -> luci-app-nikki
```

## 自动更新

本项目通过 GitHub Actions 每天自动检查 Mihomo 上游更新。当检测到新版本时，会自动更新 Makefile 中的版本号和哈希值。

## 致谢

- [MetaCubeX/mihomo](https://github.com/MetaCubeX/mihomo) - Mihomo 内核
- [nikkinikki-org/OpenWrt-nikki](https://github.com/nikkinikki-org/OpenWrt-nikki) - 原始项目

## 许可证

本项目采用 GPL-3.0 许可证。

