---
name: figma-to-code
description: 使用 Framelink MCP 将 Figma 设计稿转换为像素级精确的代码。当用户提供 Figma 设计链接时使用此技能，系统地提取设计上下文、生成 Vue 3 + Tailwind CSS 代码，并通过持续对比确保设计与实现的 1:1 准确性。
category: 'Development'
keywords: ['figma', 'design-to-code', 'MCP', 'UI development', 'Vue', 'Tailwind CSS']
license: MIT
---

# Figma 设计转代码

使用 Framelink MCP 将 Figma 设计稿系统地转换为像素级精确的 Vue 3 代码。

## 适用场景

- 收到 Figma 设计 URL 需要实现为代码
- 将 Figma 组件、帧或页面转换为 Vue 组件
- 构建必须精确匹配 Figma 设计的 UI
- 从 Figma 提取设计 Token、变量和样式

## 核心原则

1. **迭代对比循环**：生成每个组件后，**必须**再次调用 `get_figma_data` 进行对比验证
2. **资源先行**：实现组件前，**必须**检查并下载设计中的图片资源
3. **优先使用 Arco Design Vue**：能用 Arco 组件实现的，尽量使用 Arco Design Vue
4. **使用项目设计 Token**：样式必须使用项目的 Tailwind 设计 Token，禁止硬编码

## MCP 服务器配置

本技能使用 **Framelink MCP for Figma** ([GLips/Figma-Context-MCP](https://github.com/GLips/Figma-Context-MCP))。

### 配置方法

在 Cursor MCP 配置文件中添加：

**macOS / Linux**：

```json
{
  "mcpServers": {
    "framelink-figma": {
      "command": "npx",
      "args": ["-y", "figma-developer-mcp", "--figma-api-key=YOUR-KEY", "--stdio"]
    }
  }
}
```

**Windows**：

```json
{
  "mcpServers": {
    "framelink-figma": {
      "command": "cmd",
      "args": ["/c", "npx", "-y", "figma-developer-mcp", "--figma-api-key=YOUR-KEY", "--stdio"]
    }
  }
}
```

> **注意**：需要创建 Figma 访问令牌。在 Figma 设置 > 安全 > 个人访问令牌中生成，确保具有「文件内容」和「开发资源」的读取权限。

## 理解 Figma URL

Figma URL 遵循以下模式：

```
https://figma.com/design/:fileKey/:fileName?node-id=1-2
```

**提取关键值**：

- `fileKey`：文件唯一标识符（如 `pqrs`）
- `nodeId`：节点标识符，URL 中的 `1-2` 转换为 `1:2`

**分支 URL**：

```
https://figma.com/design/:fileKey/branch/:branchKey/:fileName
```

当存在分支时，使用 `branchKey` 作为 `fileKey`。

## MCP 工具

### 1. get_figma_data

**主要工具**：从 Figma 文件、帧或组获取简化后的设计数据。

- 自动压缩 Figma API 响应约 90%
- 返回布局、间距、颜色、排版等关键信息
- 包含图片和图标的资源信息

### 2. download_figma_images

**图片下载工具**：下载 Figma 文件中的 SVG 和 PNG 图片。

- 支持批量下载多个节点的图片
- 可指定 PNG 导出比例（默认 2x）
- 自动保存到指定的本地路径

## 实现工作流

### 步骤 1：分析设计

1. 从用户处获取 Figma URL
2. 从 URL 中提取 fileKey 和 nodeId
3. 识别要构建的主要区块/组件

### 步骤 2：获取设计上下文

1. 调用 `get_figma_data` 获取设计数据
2. 分析返回的布局、样式、组件结构
3. 识别设计中包含的图片/图标资源

### 步骤 3：下载图片和图标资源（必须执行）

**必须检查** `get_figma_data` 返回的数据中是否包含图片或图标节点。

如果包含，**必须调用** `download_figma_images`，严格按以下参数格式：

```typescript
download_figma_images({
  fileKey: 'xxx', // 必填：Figma 文件的 key
  nodes: [
    // 必填：要下载的节点数组
    {
      nodeId: '1234:5678', // 必填：节点 ID
      fileName: 'icon.svg', // 必填：文件名，以 .svg 或 .png 结尾
      imageRef: 'xxx', // 可选：如果节点有 imageRef 填充则必须提供
    },
  ],
  localPath: '/absolute/path/to/src/assets/', // 必填：本地绝对路径
  pngScale: 2, // 可选：PNG 导出比例，默认 2
});
```

**资源类型与文件名**：

- **矢量图标**：fileName 以 `.svg` 结尾
- **位图图片**：fileName 以 `.png` 结尾

**调用步骤**：

1. 从 `get_figma_data` 返回数据中提取图片/图标节点的 nodeId 和 imageRef
2. 为每个资源指定合适的 fileName（svg 或 png）
3. 调用 `download_figma_images` 下载到项目的 `src/assets/` 目录
4. 记录下载的文件路径，供后续代码引用

**资源引用约束**：下载的图片/图标资源在代码中**只能使用 `<img>` 标签引用**，禁止使用其他方式（如内联 SVG、background-image 等）。

```vue
<!-- 正确：使用 img 标签 -->
<img src="@/assets/icons/icon-name.svg" alt="icon" class="h-6 w-6" />

<!-- 禁止：内联 SVG -->
<!-- 禁止：background-image -->
```

如果不包含图片或图标资源，在实现组件前明确说明「设计中无图片/图标资源，跳过下载步骤」。

### 步骤 4：实现组件

1. **优先检查 Arco Design Vue**：查看是否有现成组件可用
2. 如果 Arco 有对应组件，直接使用并调整样式
3. 如果需要自定义，使用项目设计系统的 Tailwind Token
4. 一次只专注一个组件或区块
5. 代码中使用步骤 3 下载的图片路径

### 步骤 5：对比验证（必须执行）

组件实现完成后，**必须执行**以下验证：

1. **再次调用 `get_figma_data`** 获取最新设计数据
2. **逐项对比**：
   - 间距（margin、padding、gap）是否一致
   - 颜色（背景、文字、边框）是否一致
   - 字体（大小、粗细、行高）是否一致
   - 布局（flex 方向、对齐、换行）是否一致
   - 尺寸（宽度、高度）是否一致
3. **修正差异**：发现不匹配时立即修正
4. **确认完成**：向用户报告验证结果

**禁止跳过此步骤**。

## 工作流检查清单

每次执行此技能时，确保完成以下检查：

- [ ] 调用了 `get_figma_data` 获取设计数据
- [ ] 检查了设计中是否包含图片（PNG）或图标（SVG）资源
- [ ] 如有图片/图标资源，调用了 `download_figma_images` 下载
- [ ] 实现组件时使用了 Arco Design Vue 和项目设计 Token
- [ ] 完成后再次调用 `get_figma_data` 进行对比验证
- [ ] 向用户报告了验证结果

## 组件选择指南

**优先使用 Arco Design Vue**：

| 需求     | 推荐方案         |
| -------- | ---------------- |
| 按钮     | `<a-button>`     |
| 输入框   | `<a-input>`      |
| 选择器   | `<a-select>`     |
| 开关     | `<a-switch>`     |
| 表单     | `<a-form>`       |
| 表格     | `<a-table>`      |
| 模态框   | `<a-modal>`      |
| 消息提示 | `Message.info()` |
| 下拉菜单 | `<a-dropdown>`   |
| 标签页   | `<a-tabs>`       |
| 布局     | `<a-layout>`     |

**使用 Tailwind CSS 自定义**：

- 自定义卡片容器
- 特殊的列表项样式
- 非标准的布局需求
- Arco 组件无法覆盖的场景

## 项目设计 Token

生成的代码**必须**使用项目的 Tailwind 设计 Token：

### 颜色

| 用途     | Tailwind 类          |
| -------- | -------------------- |
| 主要正文 | `text-text-1`        |
| 次级文字 | `text-text-2`        |
| 禁用文字 | `text-text-4`        |
| 品牌主色 | `bg-primary-6`       |
| 品牌悬浮 | `hover:bg-primary-5` |
| 背景容器 | `bg-bg-4`            |

### 间距

| 像素 | 值  | 像素 | 值  |
| ---- | --- | ---- | --- |
| 4px  | `1` | 16px | `4` |
| 8px  | `2` | 24px | `6` |
| 12px | `3` | 32px | `8` |

### 圆角 & 阴影

| 场景      | 圆角          | 阴影              |
| --------- | ------------- | ----------------- |
| 按钮/卡片 | `rounded-lg`  | `shadow-black-md` |
| 输入框    | `rounded-md`  | -                 |
| 弹窗      | `rounded-2xl` | `shadow-black-lg` |

> 完整设计 Token 参考 [design-token skill](../design-token/SKILL.md)

## 实现指南

### 必须做

1. **优先使用 Arco Design Vue 组件**
2. **使用项目设计 Token**：禁止硬编码颜色和间距
3. **遵循 Vue 组件规范**：参考 `.cursor/rules/vue-component.mdc`
4. **检查并下载图片资源**：实现组件前必须完成
5. **执行对比验证**：每个组件完成后必须对比设计稿

### 禁止做

1. **禁止重复造轮子**：Arco 有的组件不要自己写
2. **禁止硬编码颜色**：不要使用 `#007bff`，使用 `bg-primary-6`
3. **禁止跳过资源下载检查**：必须检查设计中是否有图片/图标资源
4. **禁止跳过对比验证**：必须对比实现与设计

## 代码示例

### 使用 Arco 组件

```vue
<template>
  <a-form :model="form" layout="vertical">
    <a-form-item field="name" label="名称">
      <a-input v-model="form.name" placeholder="请输入" />
    </a-form-item>
    <a-form-item>
      <a-button type="primary" html-type="submit">提交</a-button>
    </a-form-item>
  </a-form>
</template>
```

### 自定义卡片（Tailwind）

```html
<div class="bg-bg-4 rounded-xl p-4 shadow-black-md">
  <h3 class="text-lg font-medium text-text-1">标题</h3>
  <p class="mt-2 text-sm text-text-2">内容描述</p>
</div>
```

## 成功标准

- ✅ 实现与 Figma 设计像素级匹配
- ✅ 优先使用 Arco Design Vue 组件
- ✅ 使用项目设计系统的 Tailwind Token
- ✅ 下载了设计中的图片/图标资源（如有）
- ✅ 执行了对比验证并报告结果
- ✅ 代码生产就绪、可维护

## 参考文件

- [MCP 工具参考](./references/mcp-tools.md) - Framelink MCP 工具详细文档
- [URL 解析指南](./references/url-parsing.md) - 如何从 Figma URL 提取 fileKey 和 nodeId
- [框架示例](./references/framework-examples.md) - Vue 3 + Arco Design Vue 代码示例
- [样式技能](../design-token/SKILL.md) - 完整设计 Token 参考
