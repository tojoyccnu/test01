#!/bin/bash
# ==============================================================================
# detect.sh — 检测 pre-commit 钩子是否包含 lint 检查
#
# 支持的 git hooks 工具：simple-git-hooks、husky、yorkie
# 支持的 lint 工具检测：lint-staged、oxlint、eslint、prettier、stylelint、biome
#
# 输出格式（key=value）：
#   LINT_IN_HOOKS=true|false
#   TOOL=simple-git-hooks|husky|yorkie
#   PRE_COMMIT=<pre-commit 命令>
#   LINT_STAGED_CONFIG=<lint-staged 配置来源>（仅当通过 lint-staged 间接执行时）
#   LINT_COMMANDS=<检测到的 lint 命令>（仅当通过 lint-staged 间接执行时）
#
# 退出码：0 = hooks 包含 lint，1 = hooks 不包含 lint
# ==============================================================================

set -euo pipefail

# ---- 工具函数 ----------------------------------------------------------------

# 项目根目录（脚本所在目录向上 3 层：scripts/ -> detect-pre-commit-lint/ -> skills/ -> .cursor/ -> 项目根）
PROJECT_ROOT="$(cd "$(dirname "$0")/../../.." && cd .. && pwd)"
PKG="$PROJECT_ROOT/package.json"

# 输出结果变量
TOOL_NAME=""
PRE_COMMIT_CMD=""
LINT_STAGED_SOURCE=""
LINT_COMMANDS_FOUND=""

# 直接 lint 关键词（不含 lint-staged，lint-staged 需要二次解析）
DIRECT_LINT_REGEX='oxlint|eslint|prettier|stylelint|biome'

# 包含 lint-staged 的完整关键词
ALL_LINT_REGEX='lint-staged|oxlint|eslint|prettier|stylelint|biome'

# 检查字符串是否包含 lint 关键词（含 lint-staged）
contains_any_lint() {
  echo "$1" | grep -qiE "$ALL_LINT_REGEX"
}

# 检查字符串是否包含直接 lint 关键词（不含 lint-staged）
contains_direct_lint() {
  echo "$1" | grep -qiE "$DIRECT_LINT_REGEX"
}

# 检查字符串是否包含 lint-staged
contains_lint_staged() {
  echo "$1" | grep -qiE 'lint-staged'
}

# 从 package.json 中提取指定 JSON 路径的值（使用 node）
# 用法: pkg_field "simple-git-hooks" "pre-commit"
pkg_field() {
  if [ ! -f "$PKG" ]; then
    echo ""
    return
  fi
  node -e "
    const fs = require('fs');
    try {
      const pkg = JSON.parse(fs.readFileSync('$PKG', 'utf8'));
      const keys = process.argv.slice(1);
      let val = pkg;
      for (const k of keys) {
        if (val == null || typeof val !== 'object') { process.exit(0); }
        val = val[k];
      }
      if (typeof val === 'string') { console.log(val); }
      else if (val != null) { console.log(JSON.stringify(val)); }
    } catch(e) { /* ignore */ }
  " "$@" 2>/dev/null || echo ""
}

# 从 JS/CJS/MJS 文件中提取 pre-commit 字段值（文本匹配，不执行）
# 用法: extract_pre_commit_from_js <file>
extract_pre_commit_from_js() {
  local file="$1"
  if [ ! -f "$file" ]; then
    echo ""
    return
  fi
  # 匹配 "pre-commit": "..." 或 'pre-commit': '...' 模式
  local result
  result=$(grep -oE "['\"]pre-commit['\"]\\s*:\\s*['\"]([^'\"]+)['\"]" "$file" 2>/dev/null | head -1 | sed -E "s/['\"]pre-commit['\"]\\s*:\\s*['\"]([^'\"]+)['\"]/\\1/" || echo "")
  echo "$result"
}

# 从 JSON 文件中提取 pre-commit 字段值
# 用法: extract_pre_commit_from_json <file>
extract_pre_commit_from_json() {
  local file="$1"
  if [ ! -f "$file" ]; then
    echo ""
    return
  fi
  node -e "
    const fs = require('fs');
    try {
      const cfg = JSON.parse(fs.readFileSync('$1', 'utf8'));
      if (cfg['pre-commit']) console.log(cfg['pre-commit']);
    } catch(e) { /* ignore */ }
  " 2>/dev/null || echo ""
}

# ---- Step 1: 检测 git hooks 工具及 pre-commit 命令 ----------------------------

detect_simple_git_hooks() {
  # 独立配置文件（优先级高于 package.json）
  local config_files=(
    ".simple-git-hooks.json"
    "simple-git-hooks.json"
    ".simple-git-hooks.js"
    "simple-git-hooks.js"
    ".simple-git-hooks.cjs"
    "simple-git-hooks.cjs"
    ".simple-git-hooks.mjs"
    "simple-git-hooks.mjs"
  )

  # 先检查独立配置文件
  for cf in "${config_files[@]}"; do
    local filepath="$PROJECT_ROOT/$cf"
    if [ -f "$filepath" ]; then
      TOOL_NAME="simple-git-hooks"
      case "$cf" in
        *.json)
          PRE_COMMIT_CMD=$(extract_pre_commit_from_json "$filepath")
          ;;
        *.js|*.cjs|*.mjs)
          PRE_COMMIT_CMD=$(extract_pre_commit_from_js "$filepath")
          ;;
      esac
      if [ -n "$PRE_COMMIT_CMD" ]; then
        return 0
      fi
    fi
  done

  # 再检查 package.json
  local pkg_cmd
  pkg_cmd=$(pkg_field "simple-git-hooks" "pre-commit")
  if [ -n "$pkg_cmd" ]; then
    TOOL_NAME="simple-git-hooks"
    PRE_COMMIT_CMD="$pkg_cmd"
    return 0
  fi

  return 1
}

detect_husky() {
  # v5+: .husky/pre-commit 文件
  local husky_file="$PROJECT_ROOT/.husky/pre-commit"
  if [ -f "$husky_file" ]; then
    TOOL_NAME="husky"
    PRE_COMMIT_CMD=$(cat "$husky_file" 2>/dev/null || echo "")
    if [ -n "$PRE_COMMIT_CMD" ]; then
      return 0
    fi
  fi

  # v4: package.json 中的 husky.hooks.pre-commit
  local pkg_cmd
  pkg_cmd=$(pkg_field "husky" "hooks" "pre-commit")
  if [ -n "$pkg_cmd" ]; then
    TOOL_NAME="husky"
    PRE_COMMIT_CMD="$pkg_cmd"
    return 0
  fi

  return 1
}

detect_yorkie() {
  # package.json 中的 gitHooks.pre-commit
  local pkg_cmd
  pkg_cmd=$(pkg_field "gitHooks" "pre-commit")
  if [ -n "$pkg_cmd" ]; then
    TOOL_NAME="yorkie"
    PRE_COMMIT_CMD="$pkg_cmd"
    return 0
  fi

  return 1
}

# ---- Step 2 & 3: 分析 lint 并解析 lint-staged ---------------------------------

# 检测 lint-staged 配置并提取 lint 命令
detect_lint_staged_config() {
  # lint-staged 独立配置文件（按优先级）
  local config_files=(
    ".lintstagedrc"
    ".lintstagedrc.json"
    ".lintstagedrc.yaml"
    ".lintstagedrc.yml"
    ".lintstagedrc.js"
    ".lintstagedrc.cjs"
    ".lintstagedrc.mjs"
    "lint-staged.config.js"
    "lint-staged.config.cjs"
    "lint-staged.config.mjs"
    "lint-staged.config.ts"
  )

  # 先检查独立配置文件
  for cf in "${config_files[@]}"; do
    local filepath="$PROJECT_ROOT/$cf"
    if [ -f "$filepath" ]; then
      LINT_STAGED_SOURCE="$cf"
      local content
      content=$(cat "$filepath" 2>/dev/null || echo "")
      if contains_direct_lint "$content"; then
        LINT_COMMANDS_FOUND=$(echo "$content" | grep -oiE "$DIRECT_LINT_REGEX" | sort -u | tr '\n' ',' | sed 's/,$//')
        return 0
      fi
      return 1
    fi
  done

  # 再检查 package.json 中的 lint-staged 字段
  local pkg_lint_staged
  pkg_lint_staged=$(pkg_field "lint-staged")
  if [ -n "$pkg_lint_staged" ] && [ "$pkg_lint_staged" != "undefined" ]; then
    LINT_STAGED_SOURCE="package.json"
    if contains_direct_lint "$pkg_lint_staged"; then
      LINT_COMMANDS_FOUND=$(echo "$pkg_lint_staged" | grep -oiE "$DIRECT_LINT_REGEX" | sort -u | tr '\n' ',' | sed 's/,$//')
      return 0
    fi
    return 1
  fi

  return 1
}

# ---- 主流程 ------------------------------------------------------------------

main() {
  # 检查 package.json 是否存在
  if [ ! -f "$PKG" ]; then
    echo "LINT_IN_HOOKS=false"
    echo "REASON=package.json not found"
    exit 1
  fi

  # Step 1: 检测 git hooks 工具
  local found_tool=false
  if detect_simple_git_hooks; then
    found_tool=true
  elif detect_husky; then
    found_tool=true
  elif detect_yorkie; then
    found_tool=true
  fi

  if [ "$found_tool" = false ] || [ -z "$PRE_COMMIT_CMD" ]; then
    echo "LINT_IN_HOOKS=false"
    echo "REASON=no git hooks tool with pre-commit config found"
    exit 1
  fi

  # Step 2: 检查 pre-commit 命令是否直接包含 lint 工具
  if contains_direct_lint "$PRE_COMMIT_CMD"; then
    echo "LINT_IN_HOOKS=true"
    echo "TOOL=$TOOL_NAME"
    echo "PRE_COMMIT=$PRE_COMMIT_CMD"
    exit 0
  fi

  # Step 3: 如果 pre-commit 使用 lint-staged，进一步解析
  if contains_lint_staged "$PRE_COMMIT_CMD"; then
    if detect_lint_staged_config; then
      echo "LINT_IN_HOOKS=true"
      echo "TOOL=$TOOL_NAME"
      echo "PRE_COMMIT=$PRE_COMMIT_CMD"
      echo "LINT_STAGED_CONFIG=$LINT_STAGED_SOURCE"
      echo "LINT_COMMANDS=$LINT_COMMANDS_FOUND"
      exit 0
    else
      # lint-staged 存在但其中没有 lint 命令
      echo "LINT_IN_HOOKS=false"
      echo "TOOL=$TOOL_NAME"
      echo "PRE_COMMIT=$PRE_COMMIT_CMD"
      echo "REASON=lint-staged config found but no lint commands detected"
      exit 1
    fi
  fi

  # pre-commit 命令既不直接包含 lint 也不使用 lint-staged
  echo "LINT_IN_HOOKS=false"
  echo "TOOL=$TOOL_NAME"
  echo "PRE_COMMIT=$PRE_COMMIT_CMD"
  echo "REASON=pre-commit command does not contain lint-related tools"
  exit 1
}

main
