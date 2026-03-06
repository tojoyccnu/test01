# Sync Design-token

同步更新 `design-token` skill 的设计 Token 参考内容，确保与源文件保持一致。

## 使用方法

同步设计 Token，只需输入：

```
/sync-design-token
```

## 此命令的功能

1. 读取设计 Token 源文件：
   - `src/styles/cssVar.less` - CSS 变量定义
   - `tailwind.config.js` - Tailwind 配置
2. 提取设计 Token（颜色、间距、圆角、字体、阴影、动画）
3. 更新 `.cursor/skills/design-token/references/design-tokens.md`（完整 Token 参考表）
4. 更新 `.cursor/skills/design-token/SKILL.md`（快速参考部分）
5. 输出变更摘要

## Token 提取规则

### 从 cssVar.less 提取

解析 CSS 变量及其注释，按分类提取：

| 变量前缀         | 分类   | Tailwind 前缀                    |
| ---------------- | ------ | -------------------------------- |
| `--ug-text-*`    | 文本色 | `text-text-*`                    |
| `--ug-primary-*` | 品牌色 | `bg-primary-*`, `text-primary-*` |
| `--ug-danger-*`  | 错误色 | `bg-danger-*`, `text-danger-*`   |
| `--ug-warning-*` | 警告色 | `bg-warning-*`, `text-warning-*` |
| `--ug-success-*` | 成功色 | `bg-success-*`, `text-success-*` |
| `--ug-bg-*`      | 背景色 | `bg-bg-*`                        |
| `--ug-fill-*`    | 填充色 | `bg-fill-*`                      |
| `--ug-border-*`  | 边框色 | `border-border-*`                |
| `--ug-shadow-*`  | 阴影   | `shadow-*`                       |

**注释格式**：`/* 用途说明 */` 用于提取语义描述

### 从 tailwind.config.js 提取

解析 `theme.extend` 中的配置：

- `colors` → 颜色类名映射
- `spacing` → 间距系统（p-_, m-_, gap-\* 等）
- `borderRadius` → 圆角（rounded-\*）
- `fontSize` → 字体大小和行高（text-\*）
- `boxShadow` → 阴影（shadow-\*）
- `animation` → 动画（animate-\*）

## 更新目标文件

### design-tokens.md

**路径**: `.cursor/skills/design-token/references/design-tokens.md`

**格式要求**：

- 按分类组织（文本色、品牌色、语义色、背景色、填充色、边框色、阴影）
- 每个分类使用表格展示：`CSS 变量 | Tailwind 类 | 值 | 用途`
- Tailwind 配置（字体、间距、圆角、动画）使用代码块展示

### SKILL.md 快速参考

**路径**: `.cursor/skills/design-token/SKILL.md`

**更新范围**：`## 快速参考` 部分的表格

- 保留现有的用途说明（语义部分）
- 仅更新 Token 数据（类名、值）
- 如有新增 Token，添加到对应表格末尾

## 输出格式

完成后输出变更摘要：

```
## 同步完成

### 变更摘要
- 新增: X 个 Token
- 修改: X 个 Token
- 删除: X 个 Token

### 详细变更
（列出具体变更的 Token）

### 需要检查
（提示可能需要人工调整的语义说明）
```

## 注意事项

- **保留语义说明**：SKILL.md 中的用途说明由人工维护，不要覆盖
- **增量更新**：只更新变化的部分，保留未变化的内容
- **格式一致**：遵循现有文件的格式和风格
- **注释提取**：cssVar.less 中的注释是用途说明的来源

## 源文件格式参考

### cssVar.less 格式

```less
:root {
  /* 文本色 */
  --ug-text-1: var(--ug-black-opacity-90); /* 文本色-正文 */
  --ug-text-2: var(--ug-black-opacity-60); /* 文本色-次强调 & 正文标题 */

  /* 品牌色 */
  --ug-primary-1: var(--ug-blue-opacity-5); /* 品牌色-浅蓝色背景 */
  --ug-primary-6: rgba(var(--ug-blue), 1); /* 品牌色-常规 */
}
```

### tailwind.config.js 格式

```javascript
theme: {
  extend: {
    colors: {
      text: {
        1: 'var(--ug-text-1)',
        2: 'var(--ug-text-2)',
      },
      primary: {
        1: 'var(--ug-primary-1)',
        // ...
      },
    },
    spacing: {
      0.5: '2px',
      1: '4px',
      // ...
    },
  },
}
```
