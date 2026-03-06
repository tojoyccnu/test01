---
name: commit-push-mr
description: 创建 GitLab Merge Request。Use when: (1) 用户请求创建 MR/合并请求, (2) 提及"创建 MR"、"提交 MR"、"merge request"。
---

# 创建 Merge Request

## 执行流程

### 1. 推送本地 commit

如果有未推送的 commit，自动执行（无需询问）：

```bash
git push -u origin HEAD
```

### 2. 获取目标分支并让用户选择

```bash
bash .cursor/skills/commit-push-mr/scripts/list-target-branches.sh
```

### 3. 获取 commit 差异

```bash
bash .cursor/skills/commit-push-mr/scripts/get-commits-diff.sh <target_branch>
```

### 4. 生成 MR 信息

**Title**: 单个 commit 用其 message，多个 commit 则总结

**Description**:

```markdown
## 变更内容

- 变更点 1
- 变更点 2
```

### 5. 用户确认后创建 MR

```bash
echo "<description>" | bash .cursor/skills/commit-push-mr/scripts/create-mr.sh <target_branch> "<title>"

# 保留源分支则加 --keep-source-branch
```

### 6. 返回 MR 链接,告知用户可以点击。
