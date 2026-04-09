#!/bin/sh

set -eu

BASELINE_COMMIT="6882d48a245797508c183cddf78bff859f6c8d14"
SCRIPT_DIR=$(CDPATH= cd -- "$(dirname "$0")" && pwd)
REPO_ROOT=$(CDPATH= cd -- "$SCRIPT_DIR/.." && pwd)
TMPDIR_ROOT="${TMPDIR:-/tmp}"
WORKDIR=$(mktemp -d "$TMPDIR_ROOT/opennikki-patch-verify.XXXXXX")

cleanup() {
	rm -rf "$WORKDIR"
}

trap cleanup EXIT INT TERM

UPSTREAM_DIR="$WORKDIR/upstream"
mkdir -p "$UPSTREAM_DIR"

git -C "$REPO_ROOT" archive "$BASELINE_COMMIT" | tar -x -C "$UPSTREAM_DIR"

git -C "$UPSTREAM_DIR" init -q
git -C "$UPSTREAM_DIR" config user.name "OpenNikki Patch Verifier"
git -C "$UPSTREAM_DIR" config user.email "patch-verifier@example.com"
git -C "$UPSTREAM_DIR" add -A
git -C "$UPSTREAM_DIR" commit -q -m "baseline snapshot"

sh "$REPO_ROOT/scripts/apply-opennikki-patches.sh" "$UPSTREAM_DIR"

test -f "$UPSTREAM_DIR/.github/workflows/update-mihomo-core.yml"
test -f "$UPSTREAM_DIR/nikki/files/scripts/dns_gateway.sh"
test ! -e "$UPSTREAM_DIR/feed.sh"
test ! -e "$UPSTREAM_DIR/install.sh"
test ! -e "$UPSTREAM_DIR/uninstall.sh"
test ! -e "$UPSTREAM_DIR/README.zh.md"
test ! -e "$UPSTREAM_DIR/.github/workflows/update-mihomo.yml"

grep -Fq '# OpenNikki' "$UPSTREAM_DIR/README.md"
grep -Fq '## 自动更新内容' "$UPSTREAM_DIR/README.md"
grep -Fq '## 手动 Patch' "$UPSTREAM_DIR/README.md"
grep -Fq 'MetaCubeX/mihomo' "$UPSTREAM_DIR/README.md"
grep -Fq 'sh scripts/apply-opennikki-patches.sh --check /path/to/upstream-repo' "$UPSTREAM_DIR/README.md"
grep -Fq 'DNS_GATEWAY_SH="$SH_DIR/dns_gateway.sh"' "$UPSTREAM_DIR/nikki/files/scripts/include.sh"
grep -Fq '$DNS_GATEWAY_SH apply' "$UPSTREAM_DIR/nikki/files/nikki.init"
grep -Fq '$DNS_GATEWAY_SH cleanup' "$UPSTREAM_DIR/nikki/files/nikki.init"
grep -Fq '$(INSTALL_BIN) $(CURDIR)/files/scripts/dns_gateway.sh $(1)/etc/nikki/scripts/dns_gateway.sh' "$UPSTREAM_DIR/nikki/Makefile"
grep -Fq 'name: Update Mihomo Core' "$UPSTREAM_DIR/.github/workflows/update-mihomo-core.yml"

printf 'Patch verification succeeded against baseline %s\n' "$BASELINE_COMMIT"
