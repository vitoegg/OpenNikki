#!/bin/sh

set -eu

WORKFLOW_PATH=".github/workflows/sync-upstream-patches.yml"
TEMP_DIR="$(mktemp -d)"

cleanup() {
	rm -rf "$TEMP_DIR"
}

trap cleanup EXIT INT TERM

test -f "$WORKFLOW_PATH"

grep -Fq "name: Sync Upstream With Patches" "$WORKFLOW_PATH"
grep -Fq "workflow_dispatch:" "$WORKFLOW_PATH"
! grep -Fq "schedule:" "$WORKFLOW_PATH"
grep -Fq "contents: write" "$WORKFLOW_PATH"
grep -Fq "actions: write" "$WORKFLOW_PATH"
grep -Fq "UPSTREAM_REPO: nikkinikki-org/OpenWrt-nikki" "$WORKFLOW_PATH"
grep -Fq "TARGET_BRANCH: master" "$WORKFLOW_PATH"
grep -Fq "git push origin HEAD:master" "$WORKFLOW_PATH"
grep -Fq 'git commit -m "sync: upstream ${short_upstream_sha}"' "$WORKFLOW_PATH"
grep -Fq -e '-m "Source: ${UPSTREAM_REPO}@${upstream_sha}"' "$WORKFLOW_PATH"
grep -Fq -e '-m "Mode: apply OpenNikki patches"' "$WORKFLOW_PATH"
grep -Fq 'PATCH_STATUS=conflict' "$WORKFLOW_PATH"
grep -Fq 'exit 0' "$WORKFLOW_PATH"
grep -Fq 'custom-files.list' "$WORKFLOW_PATH"
grep -Fq '[ -e "$path" ] || continue' "$WORKFLOW_PATH"
grep -Fq 'tar -czf "$custom_bundle" -T "$custom_list"' "$WORKFLOW_PATH"
grep -Fq "name: Delete Workflow Runs" "$WORKFLOW_PATH"
grep -Fq "uses: ophub/delete-releases-workflows@main" "$WORKFLOW_PATH"
grep -Fq "gh_token: \${{ secrets.GITHUB_TOKEN }}" "$WORKFLOW_PATH"

PACK_SECTION="$(sed -n '/cat <<'\''EOF'\'' | while IFS= read -r path; do/,/EOF/p' "$WORKFLOW_PATH")"
if printf '%s\n' "$PACK_SECTION" | grep -Fq '.github/workflows/update-mihomo.yml'; then
	echo "update-mihomo workflow must not be restored before patch apply" >&2
	exit 1
fi

sh -eu -c '
  temp_dir="$1"
  custom_bundle="$temp_dir/custom-files.tar.gz"
  custom_list="$temp_dir/custom-files.list"
  paths="
patches
scripts
docs/patch-workflow.md
.github/workflows/sync-upstream-patches.yml
"
  : > "$custom_list"
  printf "%s\n" "$paths" | while IFS= read -r path; do
    [ -n "$path" ] || continue
    [ -e "$path" ] || continue
    printf "%s\n" "$path" >> "$custom_list"
  done
  tar -czf "$custom_bundle" -T "$custom_list"
' sh "$TEMP_DIR"

printf 'Workflow verification succeeded for %s\n' "$WORKFLOW_PATH"
