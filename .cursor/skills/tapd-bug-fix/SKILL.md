---
name: tapd-bug-fix
description: 仅在用户输入包含「修复 TAPD bug」类表述或 TAPD 缺陷链接时触发。通过 TAPD MCP（mcp-server-tapd）拉取缺陷详情、实施修复。
---

# TAPD Bug 修复

根据用户输入的 TAPD 缺陷链接，拉取缺陷信息、实施代码修复，完成后自动生成 commit message 供用户使用。

**前提**：Cursor 已启用 TAPD MCP，server 名为 `mcp-server-tapd`。

---

## 触发条件

仅在以下情况使用本 skill，**不要主动触发**：

- 用户输入包含：修复 TAPD bug、TAPD bug 修复、修 TAPD 缺陷、处理 TAPD bug、修 tapd 单 等与「修复 TAPD 缺陷」相关的表述；或
- 用户输入为（或包含）一条 TAPD 缺陷链接（如含 `bug/detail` 或 `bugtrace/bugs/view` 的 `tapd.cn` 链接）。用户可能附带标题前缀，如 `【标题】https://www.tapd.cn/...`。

---

## 执行流程

### 1. 解析输入

从用户输入中提取 TAPD 缺陷链接（需包含完整 URL）：

- 提取 URL（可能前面有 `【标题】` 或为 Markdown `[文本](URL)` 格式）
- **workspace_id**：`tapd.cn` 之后路径中的**第一个纯数字段**
- **bug_id**：`bug/detail/` 或 `bugtrace/bugs/view/` **之后的数字段**

若输入不包含完整链接，提示用户提供 TAPD 缺陷链接。

详细规则与示例见 [tapd-link-parsing.md](references/tapd-link-parsing.md)。

### 2. 拉取缺陷

调用 TAPD MCP：

- **Server**：`mcp-server-tapd`
- **Tool**：`get_bug`
- **Arguments**：`{ "workspace_id": <number>, "options": { "id": "<bug_id>", "fields": "id,title,description,status" } }`

将返回的标题、描述、状态等展示给用户，作为后续修复依据。

### 3. 实施修复

根据缺陷描述定位问题并实施修复：

1. **定位问题**：根据缺陷描述搜索相关代码，分析根因
2. **修复代码**：实现修复方案
3. **验证修复**：确保修改不引入新问题

### 4. 生成 commit message

修复完成后，调用 TAPD MCP 获取规范 commit 关键字：

- **Tool**：`get_commit_msg`
- **Arguments**：`{ "workspace_id": <number>, "options": { "object_id": "<bug_id>", "type": "bug" } }`

将返回的字符串作为 commit message 提供给用户，供按需使用。

---

## MCP 工具汇总

| 步骤 | 工具           | 用途                       |
| ---- | -------------- | -------------------------- |
| 2    | get_bug        | 拉取缺陷详情               |
| 4    | get_commit_msg | 获取 commit message 关键字 |

以上工具均通过 `call_mcp_tool` 调用，**server 统一为 `mcp-server-tapd`**。调用前请先读取对应工具的 schema（若需自定义字段，可先调用 `get_entity_custom_fields`，entity_type: `bugs`）。

---

## 参考

- TAPD 链接格式与解析示例：[references/tapd-link-parsing.md](references/tapd-link-parsing.md)
