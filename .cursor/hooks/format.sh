#!/bin/bash

# Cursor afterFileEdit hook - 自动格式化编辑后的文件
# 从 stdin 接收 JSON: { "file_path": "<path>", "edits": [...] }

# 获取项目根目录
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$(dirname "$SCRIPT_DIR")")"

# 切换到项目根目录
cd "$PROJECT_ROOT" || exit 0

# 从 stdin 读取 JSON 输入
JSON_INPUT=$(cat)

# 解析 file_path（需要 jq）
FILE_PATH=$(echo "$JSON_INPUT" | jq -r '.file_path // empty')

# 检查文件路径是否存在
if [[ -z "$FILE_PATH" ]] || [[ ! -f "$FILE_PATH" ]]; then
  exit 0
fi

# 获取文件扩展名
EXT="${FILE_PATH##*.}"

# 仅格式化支持的文件类型
case "$EXT" in
  js|ts|jsx|tsx|vue|json|md|css|less|html|yaml|yml)
    pnpm exec prettier --write "$FILE_PATH" 2>/dev/null
    ;;
esac

exit 0
