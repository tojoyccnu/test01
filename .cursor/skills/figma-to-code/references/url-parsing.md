# Figma URL 解析指南

从各种 Figma URL 格式中提取 `fileKey` 和 `nodeId` 的完整指南。

## URL 格式概览

Figma 根据内容类型使用不同的 URL 结构：

- **设计文件**：`/design/`
- **FigJam 白板**：`/board/`
- **原型模式**：`/proto/`
- **开发模式**：`/dev/`
- **分支文件**：`/branch/`

## 标准设计文件 URL

### 格式

```
https://figma.com/design/:fileKey/:fileName?node-id=:int1-:int2
```

### 示例

```
https://figma.com/design/pqrs/ExampleFile?node-id=1-2
```

### 提取方法

```javascript
const url = 'https://figma.com/design/pqrs/ExampleFile?node-id=1-2';

// 提取 fileKey
const fileKey = 'pqrs'; // 从 URL 路径中获取

// 提取 nodeId
const nodeId = '1:2'; // 从查询参数获取，将短横线转换为冒号
```

### 规则

- **fileKey**：`/design/` 和下一个 `/` 之间的文本
- **nodeId**：`node-id` 查询参数的值
- **转换短横线为冒号**：`1-2` 变为 `1:2`

---

## 分支 URL

### 格式

```
https://figma.com/design/:fileKey/branch/:branchKey/:fileName?node-id=:int1-:int2
```

### 示例

```
https://figma.com/design/abcd/branch/xyz123/MyBranch?node-id=5-10
```

### 提取方法

```javascript
const url = 'https://figma.com/design/abcd/branch/xyz123/MyBranch?node-id=5-10';

// 当存在分支时，使用 branchKey 作为 fileKey
const fileKey = 'xyz123'; // 使用 branchKey，而非 "abcd"
const nodeId = '5:10'; // 从查询参数获取
```

### 规则

- **fileKey**：使用 `branchKey`（`/branch/` 之后的值），而非主文件 key
- **nodeId**：与标准格式相同
- 分支 URL 优先于主文件 URL

---

## FigJam 白板 URL

### 格式

```
https://figma.com/board/:fileKey/:fileName?node-id=:int1-:int2
```

### 示例

```
https://figma.com/board/board123/TeamBrainstorm?node-id=0-1
```

### 提取方法

```javascript
const url = 'https://figma.com/board/board123/TeamBrainstorm?node-id=0-1';

const fileKey = 'board123';
const nodeId = '0:1';
```

### 重要提示

- FigJam URL 使用不同的处理方式
- `/board/` 表示这是 FigJam 文件

---

## 原型模式 URL

### 格式

```
https://figma.com/proto/:fileKey/:fileName?node-id=:int1-:int2
```

### 示例

```
https://figma.com/proto/proto456/MyPrototype?node-id=10-20
```

### 提取方法

```javascript
const url = 'https://figma.com/proto/proto456/MyPrototype?node-id=10-20';

const fileKey = 'proto456';
const nodeId = '10:20';
```

### 说明

- 原型 URL 指向与设计 URL 相同的文件
- 提取方法相同

---

## 开发模式 URL

### 格式

```
https://figma.com/dev/:fileKey/:fileName?node-id=:int1-:int2
```

### 示例

```
https://figma.com/dev/dev789/DesignSystem?node-id=100-200
```

### 提取方法

```javascript
const url = 'https://figma.com/dev/dev789/DesignSystem?node-id=100-200';

const fileKey = 'dev789';
const nodeId = '100:200';
```

---

## 无 node-id 参数的 URL

### 示例

```
https://figma.com/design/xyz789/HomePage
```

### 提取方法

```javascript
const url = 'https://figma.com/design/xyz789/HomePage';

const fileKey = 'xyz789';
const nodeId = '0:1'; // 默认为页面根节点
```

### 默认行为

- 当 `node-id` 缺失时，默认为 `"0:1"`（通常是第一个页面）
- 可以询问用户想要哪个具体节点

---

## 带多个查询参数的 URL

### 示例

```
https://figma.com/design/abc/File?node-id=10-20&scaling=min-zoom&page-id=5%3A0
```

### 提取方法

```javascript
const url = new URL(
  'https://figma.com/design/abc/File?node-id=10-20&scaling=min-zoom&page-id=5%3A0'
);

const fileKey = 'abc';
const nodeId = '10:20'; // 只提取 node-id
const pageId = '5:0'; // 可选：page-id（解码 %3A 为 :）
```

### 规则

- 只提取 `node-id` 参数
- 忽略其他参数（`scaling`、`page-id` 等）
- URL 解码特殊字符（`%3A` 变为 `:`）

---

## Node ID 格式规则

### 有效格式

#### URL 中（使用短横线）

```
node-id=1-2
node-id=123-456
node-id=0-1
```

#### MCP 中（使用冒号）

```
"1:2"
"123:456"
"0:1"
```

### 转换

```javascript
// URL 格式 → MCP 格式
function convertNodeId(urlNodeId) {
  return urlNodeId.replace(/-/g, ':')
}

// 示例
"1-2"     → "1:2"
"123-456" → "123:456"
"0-1"     → "0:1"
```

### 模式

- URL 使用**短横线**：`1-2`
- MCP 使用**冒号**：`1:2`
- 调用 MCP 工具前始终进行转换

---

## 特殊情况

### 情况 1：负数 Node ID

```
node-id=-5--10
```

表示 node ID `-5:-10`

```javascript
// 小心提取
const nodeId = '-5:-10'; // 负数是有效的
```

### 情况 2：编码字符

```
node-id=1%3A2  // %3A 是 URL 编码的冒号
```

```javascript
// 先解码
const decoded = decodeURIComponent('1%3A2'); // "1:2"
const nodeId = '1:2';
```

### 情况 3：缺少文件名

```
https://figma.com/design/abc123?node-id=1-2
```

```javascript
// 仍然有效 - URL 中文件名是可选的
const fileKey = 'abc123';
const nodeId = '1:2';
```

---

## 完整解析函数

```javascript
function parseFigmaUrl(url) {
  try {
    const urlObj = new URL(url);
    const pathParts = urlObj.pathname.split('/').filter(Boolean);

    // 确定文件类型
    const fileType = pathParts[0]; // 'design', 'board', 'proto', 'dev'

    // 提取 fileKey
    let fileKey;
    if (pathParts.includes('branch')) {
      // 分支 URL：使用 branchKey
      const branchIndex = pathParts.indexOf('branch');
      fileKey = pathParts[branchIndex + 1];
    } else {
      // 标准 URL：使用 fileKey
      fileKey = pathParts[1];
    }

    // 提取 nodeId
    const nodeIdParam = urlObj.searchParams.get('node-id');
    const nodeId = nodeIdParam
      ? nodeIdParam.replace(/-/g, ':') // 将短横线转换为冒号
      : '0:1'; // 默认为页面根节点

    // 确定是否为 FigJam
    const isFigJam = fileType === 'board';

    return {
      fileKey,
      nodeId,
      fileType,
      isFigJam,
      originalUrl: url,
    };
  } catch (error) {
    throw new Error(`无效的 Figma URL: ${url}`);
  }
}

// 使用示例
parseFigmaUrl('https://figma.com/design/abc/File?node-id=1-2');
// → { fileKey: "abc", nodeId: "1:2", fileType: "design", isFigJam: false }

parseFigmaUrl('https://figma.com/design/abc/branch/xyz/Branch?node-id=5-10');
// → { fileKey: "xyz", nodeId: "5:10", fileType: "design", isFigJam: false }

parseFigmaUrl('https://figma.com/board/board123/Team?node-id=0-1');
// → { fileKey: "board123", nodeId: "0:1", fileType: "board", isFigJam: true }
```

---

## 验证清单

调用 MCP 工具前，验证：

- ✅ **fileKey 已提取**：非空，非 undefined
- ✅ **nodeId 格式正确**：使用冒号（`:`）而非短横线（`-`）
- ✅ **分支处理**：分支 URL 使用了 branchKey
- ✅ **FigJam 检测**：`/board/` URL 需要特殊处理
- ✅ **URL 已解码**：没有 `%3A` 或其他编码字符

---

## 常见错误

### ❌ 错误 1：nodeId 使用短横线

```javascript
// 错误
get_figma_data({
  fileKey: 'abc',
  nodeId: '1-2', // ❌ 仍有短横线
});

// 正确
get_figma_data({
  fileKey: 'abc',
  nodeId: '1:2', // ✅ 已转换为冒号
});
```

### ❌ 错误 2：分支使用主文件 fileKey

```javascript
// 错误
// URL: figma.com/design/abc/branch/xyz/Branch
get_figma_data({
  fileKey: 'abc', // ❌ 使用了主文件 key
  nodeId: '1:2',
});

// 正确
get_figma_data({
  fileKey: 'xyz', // ✅ 使用分支 key
  nodeId: '1:2',
});
```

---

## 快速参考

| URL 类型 | 模式                                | fileKey 来源 | 特殊说明     |
| -------- | ----------------------------------- | ------------ | ------------ |
| 设计文件 | `/design/:key/:name`                | `:key`       | 标准         |
| 分支     | `/design/:key/branch/:branch/:name` | `:branch`    | 使用分支 key |
| FigJam   | `/board/:key/:name`                 | `:key`       | 白板文件     |
| 原型     | `/proto/:key/:name`                 | `:key`       | 与设计相同   |
| 开发模式 | `/dev/:key/:name`                   | `:key`       | 与设计相同   |

**Node ID 转换**：始终 `短横线 → 冒号`（`1-2` → `1:2`）

---

更多工具使用示例请参考 [mcp-tools.md](./mcp-tools.md) 和 [SKILL.md](../SKILL.md)。
