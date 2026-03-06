---
name: commit
description: 智能提交工作流。仅在用户明确请求时使用（如"/commit"、"帮我提交"）。不要主动触发此 skill。
---

# 智能提交工作流

帮助创建格式规范的提交，使用约定式提交信息和 emoji。自动检测 pre-commit 钩子中的 lint 配置，避免重复执行。

## 何时使用

- 用户输入 `/commit` 或要求提交代码
- 用户明确请求检测 pre-commit 钩子配置

**禁止**自动触发此 skill。

## 执行流程

### 1. 检测 pre-commit lint 钩子

运行检测脚本：

```bash
bash .cursor/skills/commit/scripts/detect.sh
```

脚本输出 key=value 格式：

- `LINT_IN_HOOKS=true`：pre-commit 钩子包含 lint，提交时 **跳过** 手动 lint
- `LINT_IN_HOOKS=false`：pre-commit 钩子不包含 lint，提交前 **需要** 手动执行 lint

附加信息字段（按需输出）：

| 字段                 | 说明                                  |
| -------------------- | ------------------------------------- |
| `TOOL`               | 检测到的 hooks 工具名称               |
| `PRE_COMMIT`         | pre-commit 钩子执行的具体命令         |
| `LINT_STAGED_CONFIG` | lint-staged 配置来源                  |
| `LINT_COMMANDS`      | 检测到的具体 lint 命令                |
| `REASON`             | 当 `LINT_IN_HOOKS=false` 时的原因说明 |

**根据结果决策：**

- **LINT_IN_HOOKS=true**：告知用户"已检测到 pre-commit 钩子包含 lint 检查（工具: {TOOL}，命令: {LINT_COMMANDS}），将由 git hooks 在提交时自动执行"
- **LINT_IN_HOOKS=false**：依次执行 `pnpm lint:all` 和 `pnpm build` 确保代码质量和构建正确，如果任一检查失败，询问用户是否要继续提交还是先修复问题

#### 支持的工具

| Git Hooks 工具   | 检测的配置位置                                                                              |
| ---------------- | ------------------------------------------------------------------------------------------- |
| simple-git-hooks | `package.json`、`.simple-git-hooks.{json,js,cjs,mjs}`、`simple-git-hooks.{json,js,cjs,mjs}` |
| husky            | `.husky/pre-commit`（v5+）、`package.json` 中 `husky.hooks`（v4）                           |
| yorkie           | `package.json` 中 `gitHooks`                                                                |

如果 pre-commit 通过 `lint-staged` 间接执行，还会进一步检测 lint-staged 配置（支持 `package.json`、`.lintstagedrc.*`、`lint-staged.config.*` 等 13 种配置格式）。

### 2. 检查暂存状态

使用 `git status` 检查哪些文件已暂存。如果没有暂存文件，自动使用 `git add` 添加所有修改和新文件。

### 3. 分析变更

执行 `git diff` 以了解正在提交的更改。分析 diff 以确定是否存在多个不同的逻辑更改。

### 4. 拆分或提交

如果检测到多个不同的更改，建议将提交拆分为多个较小的提交。对于每个提交（如果未拆分则为单个提交），使用 emoji 约定式提交格式创建提交信息。

## 提交规范参考

详见 [references/commit-conventions.md](references/commit-conventions.md)，包含：

- 提交最佳实践（约定式提交格式、现在时态祈使语气、72 字符限制）
- Emoji 映射表（60+ 种 emoji 与提交类型的对应关系）
- 拆分提交的准则（5 条判断标准）
- 好的提交信息示例和拆分提交示例

## 重要说明

- 提交前会自动检测 pre-commit 钩子中是否已包含 lint 检查（支持 simple-git-hooks、husky、yorkie）
- 如果 git hooks 已配置 lint，则跳过手动 lint，由 git hooks 在 `git commit` 时自动执行
- 如果 git hooks 未配置 lint，则在提交前依次执行 `pnpm lint:all` 和 `pnpm build`，检查失败时询问用户处理方式
- 如果特定文件已暂存，命令将只提交这些文件
- 如果没有暂存文件，将自动暂存所有修改和新文件
- 提交信息将根据检测到的更改构建
- 在提交之前，命令将审查 diff 以确定是否需要多个提交会更合适
- 如果建议多个提交，它将帮助你分别暂存和提交更改
- 始终审查提交 diff 以确保信息与更改匹配
