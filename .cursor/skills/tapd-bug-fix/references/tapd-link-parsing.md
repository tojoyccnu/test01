# TAPD 链接格式与解析

用于从用户输入中提取 TAPD 缺陷链接并解析 `workspace_id` 与 `bug_id`，供 `get_bug`、`update_bug`、`get_commit_msg`、`create_comments` 等 MCP 工具使用。

---

## 支持的链接格式

### 格式 1：完整链接（带或不带标题前缀）

```
【标题】https://www.tapd.cn/tapd_fe/40685585/bug/detail/1140685585001154492
```

```
https://www.tapd.cn/tapd_fe/40685585/bug/detail/1140685585001154492
```

### 格式 2：Markdown 链接

```
[1154492](https://www.tapd.cn/tapd_fe/40685585/bug/detail/1140685585001154492)
```

### 格式 3：bugtrace 格式（API 文档中提及）

```
{tapd_base_url}/{workspace_id}/.../bugtrace/bugs/view/{id}
```

---

## 解析规则

**匹配条件**：输入包含 `tapd.cn` 的 URL

**提取步骤**：

1. 从输入中提取 URL（可能前面有 `【标题】` 或为 Markdown 链接格式）
2. **workspace_id**：`tapd.cn` 之后路径中的**第一个纯数字段**
3. **bug_id**：`bug/detail/` 或 `bugtrace/bugs/view/` **之后的数字段**

**正则参考**：

```regex
# 提取 URL（普通或 Markdown 链接）
https?://[^\s\]\)]+tapd\.cn[^\s\]\)]+

# 从 URL 路径提取 workspace_id（第一个纯数字段）
tapd\.cn/[^/]*/(\d+)/

# 从 URL 路径提取 bug_id
bug/detail/(\d+)|bugtrace/bugs/view/(\d+)
```

---

## 解析示例

### 示例 1：完整链接带标题

**输入**：

```
【【uliya】左侧栏智能总结...】https://www.tapd.cn/tapd_fe/40685585/bug/detail/1140685585001154492
```

**解析结果**：

- `workspace_id`: `40685585`
- `bug_id`: `1140685585001154492`

### 示例 2：Markdown 链接

**输入**：

```
[1154492](https://www.tapd.cn/tapd_fe/40685585/bug/detail/1140685585001154492)
```

**解析结果**：

- `workspace_id`: `40685585`
- `bug_id`: `1140685585001154492`

---

## 异常处理

| 情况                 | 处理方式                         |
| -------------------- | -------------------------------- |
| 输入不包含 TAPD 链接 | 提示用户提供完整的 TAPD 缺陷链接 |
| URL 格式异常         | 提示用户检查链接是否完整         |
