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

## DNS Gateway

通过 nftables 将所有 DNS 流量（端口 53）重定向至 MosDNS（端口 5533），实现 DNS 分流。包含 LAN 流量和本机流量的重定向，并通过 cgroupv2 匹配避免 MosDNS 自身的 DNS 回环。

### 涉及文件

| 文件 | 代码位置 | 说明 |
|------|----------|------|
| `nikki/files/scripts/dns_gateway.sh` | 完整文件 | DNS Gateway nftables 规则，原子加载 |
| `nikki/files/scripts/include.sh` | `DNS_GATEWAY_SH` 变量声明 | 注册脚本路径变量 |
| `nikki/files/nikki.init` | `service_started()` 函数 | 调用 `$DNS_GATEWAY_SH apply` 并校验结果 |
| `nikki/files/nikki.init` | `cleanup()` 函数 | 调用 `$DNS_GATEWAY_SH cleanup` 清除规则 |
| `nikki/Makefile` | `define Package/nikki/install` | 安装脚本至目标路径 |

## 自动更新

本项目通过 GitHub Actions 每天自动检查 Mihomo 上游更新。当检测到新版本时，会自动更新 Makefile 中的版本号和哈希值。

## 致谢

- [MetaCubeX/mihomo](https://github.com/MetaCubeX/mihomo) - Mihomo 内核
- [nikkinikki-org/OpenWrt-nikki](https://github.com/nikkinikki-org/OpenWrt-nikki) - 原始项目

## 许可证

本项目采用 GPL-3.0 许可证。

