---
name: i18n-prepare
description: 仅在用户明确请求时使用（如"帮我处理国际化"、"提取中文到语言文件"、"/i18n-prepare"）。不要主动触发此 skill。功能：扫描 Vue/TS 文件中的硬编码中文，创建/更新 zh-CN 语言文件，将中文替换为 i18n 调用（模板用 $t，脚本用 i18n.t）。支持大规模文件批量处理。
---

# i18n Prepare

扫描指定文件/文件夹中的硬编码中文，生成语言文件并替换为 i18n 调用。

支持两种模式：

- **单文件/小范围模式**：直接处理，适合 < 10 个文件
- **批量模式**：预扫描 + 分批处理，适合 >= 10 个文件

## 工作流程

### Phase 1: 扫描与规划

**判断处理模式：**

1. 若用户指定单个文件或明确的小范围（< 10 文件），直接进入 Phase 2
2. 若目标范围较大或不确定，运行预扫描脚本

**运行预扫描脚本：**

```bash
npx tsx .cursor/skills/i18n-prepare/scripts/scan-chinese.ts [target-dir]
```

脚本输出 `i18n-scan-report.json`，包含：

- 文件总数和包含中文的文件数
- 按模块分组的统计信息
- 每个文件的中文数量

**向用户展示扫描结果：**

```
扫描完成：
- 共 X 个文件，Y 个包含中文硬编码
- 预计分 N 个批次处理：
  1. module-a (X 文件, Y 处中文)
  2. module-b (X 文件, Y 处中文)
  ...

确认开始处理？可选择：
- 全部处理
- 仅处理特定模块
- 仅处理特定文件
```

### Phase 2: 分批处理

每批次按以下步骤执行：

1. **读取批次文件列表**
   - 从扫描报告获取该批次的文件
   - 每批次建议 5-10 个文件

2. **逐文件处理**
   - 识别硬编码中文（参考 [i18n-patterns.md](references/i18n-patterns.md)）
   - 生成 i18n key
   - 更新/创建语言文件
   - 替换源文件

3. **更新进度文件**
   - 写入 `scripts/i18n-progress.json`
   - 标记已完成的文件

4. **输出批次报告**

   ```
   ✅ 批次 1/N 完成
   - 处理文件: 5 个
   - 生成 key: 45 个
   - 语言文件: setting.json

   继续处理下一批次？
   ```

**中断恢复：**

若 `i18n-progress.json` 存在且 status 为 `in_progress`：

1. 读取进度文件
2. 跳过已完成的批次/文件
3. 从上次位置继续

### Phase 3: 语言文件映射

根据源文件路径确定目标语言文件：

| 源文件路径                    | 语言文件                           |
| ----------------------------- | ---------------------------------- |
| `src/views/{module}/**/*.vue` | `src/language/zh-CN/{module}.json` |
| `src/components/**/*.vue`     | `src/language/zh-CN/common.json`   |
| `src/utils/*.ts`              | `src/language/zh-CN/common.json`   |

若语言文件已存在，读取现有内容进行合并；若不存在则创建新文件。

### Phase 4: 生成 i18n Key

Key 命名规则：

- 第一级：组件名（PascalCase），如 `AiDataStorage`
- 第二级：语义分组（camelCase），如 `title`、`button`、`placeholder`、`tip`、`toast`
- 完整 key：`{module}.{ComponentName}.{category}` 或 `{module}.{ComponentName}.{category}.{subKey}`
- `module` 的名称无固定格式，但需要保持与语言文件的名称完全一致，例如语言文件为 `src/language/zh-CN/ai-skill.json` 时，`module` 则为 `ai-skill`

示例：

```json
{
  "AiDataStorage": {
    "title": "AI数据存储",
    "button": {
      "migrate": "迁移数据"
    },
    "tip": {
      "storageInfo": "包含依赖环境、AI模型和向量数据"
    }
  }
}
```

### Phase 5: 更新源文件

**Vue 模板中（使用 `$t`）：**

- 文本内容：`<span>存储位置</span>` → `<span>{{ $t('setting.AiDataStorage.label') }}</span>`
- 属性值：`title="提示"` → `:title="$t('key')"`
- 组件属性：`ok-text="确定"` → `:ok-text="$t('key')"`

**Script / TypeScript 中（使用 `i18n.t`）：**

- 确保有导入：`import { i18n } from 'ugos-core';`
- 替换字符串：`Message.success('成功')` → `Message.success(i18n.t('key'))`

**动态拼接文本：**

- 原始：`` `模型 ${name} 启用成功` ``
- 语言文件：`{ "enable": "模型 {name} 启用成功" }`
- 调用：`i18n.t('model.Toast.enable', { name })`

**单复数文本（使用 `$tc` / `i18n.tc`）：**

- 语言文件格式：`"{n} 篇引用来源 | {n} 篇引用来源 | {n} 篇引用来源"`
- Vue 模板：`{{ $tc('key', count) }}`
- Script：`i18n.tc('key', count)`

详细模式参考 [i18n-patterns.md](references/i18n-patterns.md)。

## 排除规则

不处理以下内容：

- 代码注释（`//`、`/* */`、`<!-- -->`）
- console 日志语句
- 已使用 `$t()` / `$tc()` 或 `i18n.t()` / `i18n.tc()` 的内容
- 导入语句中的路径
- CSS 类名和选择器

## 批量处理策略

详见 [batch-strategy.md](references/batch-strategy.md)，包含：

- 批次大小决策
- 模块划分规则
- 大模块拆分策略
- 进度文件格式

## 执行检查清单

每批次完成后验证：

- [ ] 语言文件 JSON 格式正确
- [ ] 所有 key 命名符合规范
- [ ] Vue 模板中使用 `$t`，脚本中使用 `i18n.t`
- [ ] 单复数文本使用 `$tc` / `i18n.tc`
- [ ] 脚本中已正确导入 `import { i18n } from 'ugos-core'`
- [ ] 动态拼接文本已转换为插值语法
- [ ] 进度文件已更新

全部批次完成后：

- [ ] 删除进度文件 `i18n-progress.json`
- [ ] 运行 `pnpm typecheck` 确保无类型错误
