#!/bin/bash
# 创建 GitLab Merge Request
# 用法: ./create-mr.sh <target_branch> <title> [--keep-source-branch]
# Description 通过 stdin 传入

set -e

# 参数检查
if [ $# -lt 2 ]; then
  echo "用法: $0 <target_branch> <title> [--keep-source-branch]"
  echo "Description 通过 stdin 传入 (可选)"
  echo ""
  echo "示例:"
  echo "  echo '修复登录问题' | $0 master 'fix: 修复登录bug'"
  echo "  $0 master 'feat: 新功能' --keep-source-branch"
  exit 1
fi

TARGET_BRANCH="$1"
TITLE="$2"
KEEP_SOURCE_BRANCH=false

# 解析可选参数
shift 2
while [ $# -gt 0 ]; do
  case "$1" in
    --keep-source-branch)
      KEEP_SOURCE_BRANCH=true
      ;;
    *)
      echo "⚠️  未知参数: $1"
      ;;
  esac
  shift
done

# 获取当前分支
SOURCE_BRANCH=$(git branch --show-current)

if [ -z "$SOURCE_BRANCH" ]; then
  echo "❌ 无法获取当前分支"
  exit 1
fi

if [ "$SOURCE_BRANCH" = "$TARGET_BRANCH" ]; then
  echo "❌ 当前分支与目标分支相同 ($SOURCE_BRANCH)"
  exit 1
fi

# 检查是否已存在 MR
EXISTING_MR=$(glab mr list --source-branch "$SOURCE_BRANCH" --target-branch "$TARGET_BRANCH" --state opened 2>/dev/null | head -1)
if [ -n "$EXISTING_MR" ]; then
  echo "⚠️  已存在相同的 MR:"
  echo "   $EXISTING_MR"
  echo ""
  echo "如需更新，请直接推送代码或关闭现有 MR 后重试"
  exit 1
fi

# 读取 stdin 作为 description (如果有)
DESCRIPTION=""
if [ ! -t 0 ]; then
  DESCRIPTION=$(cat)
fi

# 推送当前分支
echo "📤 推送分支 $SOURCE_BRANCH..."
git push -u origin HEAD

# 构建 glab 命令参数
GLAB_ARGS=(
  "--target-branch" "$TARGET_BRANCH"
  "--title" "$TITLE"
  "--yes"
)

if [ "$KEEP_SOURCE_BRANCH" = false ]; then
  GLAB_ARGS+=("--remove-source-branch")
fi

# 创建 MR
echo "🔄 创建 Merge Request..."
echo "   Source: $SOURCE_BRANCH"
echo "   Target: $TARGET_BRANCH"
echo "   Title: $TITLE"
if [ "$KEEP_SOURCE_BRANCH" = true ]; then
  echo "   保留源分支: 是"
fi
echo ""

if [ -n "$DESCRIPTION" ]; then
  # 使用临时文件传递 description，避免特殊字符问题
  TMPFILE=$(mktemp)
  trap "rm -f $TMPFILE" EXIT
  echo "$DESCRIPTION" > "$TMPFILE"

  glab mr create "${GLAB_ARGS[@]}" --description "$(cat "$TMPFILE")"
else
  glab mr create "${GLAB_ARGS[@]}"
fi

echo ""
echo "✅ MR 创建成功"
