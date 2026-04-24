# OpenNikki

基于 `nikkinikki-org/OpenWrt-nikki` 维护。

## 自动更新

- 自动跟踪 [MetaCubeX/mihomo](https://github.com/MetaCubeX/mihomo) 内核版本
- 同步上游后应用 OpenNikki 自定义内容
  > Patch: `maint/patches/`
  > 脚本: `maint/scripts/`
  > 检查: `maint/checks/`
  > 清单: `maint/manifests/`

## 手动检查

```bash
sh maint/scripts/apply-customizations.sh --check /path/to/upstream-dir
sh maint/scripts/apply-customizations.sh /path/to/upstream-dir
```
