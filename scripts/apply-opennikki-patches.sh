#!/bin/sh

set -eu

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname "$0")" && pwd)
REPO_ROOT=$(CDPATH= cd -- "$SCRIPT_DIR/.." && pwd)
PATCH_DIR="$REPO_ROOT/patches/opennikki"
SERIES_FILE="$PATCH_DIR/series"

usage() {
	echo "Usage: sh scripts/apply-opennikki-patches.sh [--check] <target-repo>" >&2
	exit 1
}

cleanup_removed_paths() {
	cat <<'EOF' | while IFS= read -r path; do
.github/FUNDING.yml
.github/ISSUE_TEMPLATE/bug_report.yml
.github/ISSUE_TEMPLATE/config.yml
.github/ISSUE_TEMPLATE/feature_request.yml
.github/workflows/build-packages.yml
.github/workflows/delete-workflow-runs.yml
.github/workflows/dependabot.yml
.github/workflows/release-packages.yml
.github/workflows/stale-issues.yml
README.zh.md
feed.sh
install.sh
uninstall.sh
EOF
		[ -z "$path" ] && continue
		rm -rf "$TARGET_DIR/$path"
	done
}

MODE="apply"
if [ "${1:-}" = "--check" ]; then
	MODE="check"
	shift
fi

[ "$#" -eq 1 ] || usage
[ -f "$SERIES_FILE" ] || {
	echo "Missing patch series: $SERIES_FILE" >&2
	exit 1
}

TARGET_DIR=$(CDPATH= cd -- "$1" && pwd)

git -C "$TARGET_DIR" rev-parse --show-toplevel > /dev/null 2>&1 || {
	echo "Target directory must be a git repository: $TARGET_DIR" >&2
	exit 1
}

while IFS= read -r patch_name || [ -n "$patch_name" ]; do
	[ -z "$patch_name" ] && continue

	patch_path="$PATCH_DIR/$patch_name"
	[ -f "$patch_path" ] || {
		echo "Missing patch file: $patch_path" >&2
		exit 1
	}

	printf '[%s] %s\n' "$MODE" "$patch_name"
	case "$MODE" in
		check)
			git -C "$TARGET_DIR" apply --check --whitespace=nowarn "$patch_path"
			;;
		apply)
			git -C "$TARGET_DIR" apply --whitespace=nowarn "$patch_path"
			;;
	esac
done < "$SERIES_FILE"

if [ "$MODE" = "apply" ]; then
	cleanup_removed_paths
	echo "[apply] cleanup removed paths"
fi
