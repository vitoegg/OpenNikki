# OpenNikki

OpenNikki 基于 `nikkinikki-org/OpenWrt-nikki` 维护，自动更新 Mihomo 内核版本，以及在同步上游后手动应用 OpenNikki 的自定义 patch。

## 自动更新内容

仓库内置 GitHub Actions，会跟踪 [MetaCubeX/mihomo](https://github.com/MetaCubeX/mihomo) 的最新版本。
检测到新版本后，会自动更新 `nikki/Makefile` 中的 Mihomo 版本号与校验值。

## 手动 Patch

OpenNikki 的定制改动保存在 `patches/opennikki/`。
当上游代码更新后，可先检查，再在新的上游源码目录中应用 patch：

```bash
sh scripts/apply-opennikki-patches.sh --check /path/to/upstream-repo
sh scripts/apply-opennikki-patches.sh /path/to/upstream-repo
```

如果 patch 可以全部应用，就按结果提交；如果失败，按脚本输出处理冲突后再重新整理 patch。
