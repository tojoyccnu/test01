#!/bin/bash
# 获取可用的目标分支列表
# 过滤: main, master, release/*, develop

set -e

# 检查是否在 git 仓库中
if ! git rev-parse --git-dir >/dev/null 2>&1; then
  echo "❌ 当前目录不是 git 仓库" >&2
  exit 1
fi

# 拉取远程分支信息
echo "🔄 获取远程分支..." >&2
if ! git fetch --prune origin 2>/dev/null; then
  echo "⚠️  无法连接远程仓库，使用本地缓存的分支信息" >&2
fi

# 获取当前分支（用于排除）
CURRENT_BRANCH=$(git branch --show-current 2>/dev/null || echo "")

# 获取并过滤分支（排除 HEAD 和当前分支）
BRANCHES=$(git branch -r 2>/dev/null | \
  grep -v 'HEAD' | \
  grep -E 'origin/(main|master|release|develop)' | \
  sed 's/origin\///' | \
  sed 's/^[[:space:]]*//' | \
  grep -v "^${CURRENT_BRANCH}$" || true)

if [ -z "$BRANCHES" ]; then
  echo "❌ 未找到可用的目标分支 (main/master/release/develop)" >&2
  echo "   请确认远程仓库有这些分支" >&2
  exit 1
fi

# 输出分支列表（每行一个，方便解析）
echo "$BRANCHES"
