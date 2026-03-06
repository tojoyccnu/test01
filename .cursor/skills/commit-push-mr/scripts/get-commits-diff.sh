#!/bin/bash
# 获取本地源分支与远程目标分支的 commit 差异
# 用法: ./get-commits-diff.sh [target_branch]

set -e

TARGET_BRANCH="${1:-master}"

# 获取当前分支
SOURCE_BRANCH=$(git branch --show-current)

if [ -z "$SOURCE_BRANCH" ]; then
  echo "❌ 无法获取当前分支"
  exit 1
fi

# 拉取最新远程信息
git fetch origin >/dev/null 2>&1 || true

# 检查远程目标分支是否存在
if ! git rev-parse --verify "origin/${TARGET_BRANCH}" >/dev/null 2>&1; then
  echo "❌ 目标分支 origin/${TARGET_BRANCH} 不存在"
  exit 1
fi

echo "## 分支信息"
echo "- Source: \`$SOURCE_BRANCH\` (本地)"
echo "- Target: \`origin/$TARGET_BRANCH\` (远程)"
echo ""

# 获取差异的 commits (本地 HEAD vs 远程目标分支)
COMMITS=$(git log "origin/${TARGET_BRANCH}..HEAD" --format="- %s" --no-merges 2>/dev/null)

if [ -z "$COMMITS" ]; then
  echo "⚠️  没有找到与 origin/${TARGET_BRANCH} 的差异 commits"
  exit 0
fi

echo "## Commits"
echo "$COMMITS"
echo ""

# 获取变更文件统计
echo "## Changed Files"
git diff "origin/${TARGET_BRANCH}...HEAD" --stat 2>/dev/null

# 统计信息
echo ""
echo "## Summary"
COMMIT_COUNT=$(git log "origin/${TARGET_BRANCH}..HEAD" --oneline --no-merges 2>/dev/null | wc -l | tr -d ' ')
FILE_COUNT=$(git diff "origin/${TARGET_BRANCH}...HEAD" --name-only 2>/dev/null | wc -l | tr -d ' ')
echo "- Total commits: $COMMIT_COUNT"
echo "- Files changed: $FILE_COUNT"
