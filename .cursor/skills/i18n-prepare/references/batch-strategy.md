# 批量处理策略

大规模 i18n 处理的分批策略和进度管理。

## 批次划分规则

### 按模块自动分组

扫描脚本自动按以下规则分组：

| 源文件路径              | 模块名       |
| ----------------------- | ------------ |
| `src/views/{module}/**` | `{module}`   |
| `src/components/**`     | `components` |
| `src/utils/**`          | `utils`      |
| `src/hooks/**`          | `hooks`      |
| 其他                    | `other`      |

### 批次大小策略

| 场景                | 建议批次大小 | 说明             |
| ------------------- | ------------ | ---------------- |
| 模块文件数 <= 10    | 整个模块     | 一次处理完整模块 |
| 模块文件数 11-20    | 10 个文件    | 拆分为 2 批      |
| 模块文件数 > 20     | 10 个文件    | 按文件数拆分     |
| 中文数量 > 100/文件 | 5 个文件     | 减少单批处理量   |

### 处理优先级

建议按以下顺序处理模块：

1. **中文数量最多的模块** - 优先处理主要工作量
2. **独立模块** - 无跨模块依赖的先处理
3. **通用组件** - `components` 最后处理（可能有 key 复用）

## 进度文件格式

进度文件路径：`.cursor/skills/i18n-prepare/scripts/i18n-progress.json`

```json
{
  "version": "1.0",
  "startTime": "2026-01-26T10:00:00Z",
  "lastUpdateTime": "2026-01-26T10:30:00Z",
  "status": "in_progress",
  "targetDirectory": "src/views",
  "currentBatch": 2,
  "totalBatches": 5,
  "batches": [
    {
      "id": 1,
      "module": "model-management",
      "status": "completed",
      "files": [
        { "path": "src/views/model-management/components/ModelList.vue", "status": "completed" },
        { "path": "src/views/model-management/hooks/useModelManagement.ts", "status": "completed" }
      ],
      "generatedKeys": 45,
      "languageFile": "model-management.json"
    },
    {
      "id": 2,
      "module": "setting",
      "status": "in_progress",
      "files": [
        { "path": "src/views/setting/AiDataStorage.vue", "status": "completed" },
        { "path": "src/views/setting/Setting.vue", "status": "pending" }
      ],
      "generatedKeys": 12,
      "languageFile": "setting.json"
    }
  ],
  "summary": {
    "totalFiles": 42,
    "processedFiles": 17,
    "totalKeys": 320,
    "generatedKeys": 157
  }
}
```

### 字段说明

| 字段                       | 类型   | 说明                                    |
| -------------------------- | ------ | --------------------------------------- |
| `version`                  | string | 进度文件版本                            |
| `status`                   | enum   | `pending` / `in_progress` / `completed` |
| `currentBatch`             | number | 当前处理的批次号（1-based）             |
| `totalBatches`             | number | 总批次数                                |
| `batches[].id`             | number | 批次 ID                                 |
| `batches[].files[].status` | enum   | `pending` / `completed` / `skipped`     |

## 中断恢复流程

```
1. 检查 i18n-progress.json 是否存在
   ├─ 不存在 → 从头开始，运行扫描脚本
   └─ 存在 → 读取进度

2. 检查 status 字段
   ├─ completed → 询问是否重新开始
   └─ in_progress → 提示恢复选项

3. 恢复选项：
   - 从当前批次继续
   - 从当前文件继续
   - 重新开始（删除进度文件）

4. 继续处理
   - 跳过 status=completed 的批次/文件
   - 从第一个 pending 状态开始
```

## 扫描报告格式

扫描脚本生成的报告路径：`.cursor/skills/i18n-prepare/scripts/i18n-scan-report.json`

```json
{
  "scanTime": "2026-01-26T10:00:00Z",
  "targetDirectory": "src/views",
  "summary": {
    "totalFiles": 85,
    "filesWithChinese": 42,
    "totalChineseStrings": 320
  },
  "modules": {
    "model-management": {
      "name": "model-management",
      "fileCount": 15,
      "chineseCount": 120,
      "files": [
        { "path": "src/views/model-management/components/ModelList.vue", "count": 25 },
        { "path": "src/views/model-management/hooks/useModelManagement.ts", "count": 8 }
      ]
    }
  },
  "fileDetails": [
    {
      "path": "/absolute/path/to/file.vue",
      "relativePath": "src/views/model-management/components/ModelList.vue",
      "count": 25,
      "strings": [
        { "text": "模型列表", "line": 15, "column": 10, "context": "template", "type": "text" },
        {
          "text": "删除确认",
          "line": 42,
          "column": 18,
          "context": "script",
          "type": "string-literal"
        }
      ]
    }
  ]
}
```

## 批次完成报告模板

每批次完成后输出：

```
✅ 批次 {current}/{total} 完成

📁 模块: {module}
📄 处理文件: {fileCount} 个
🔑 生成 key: {keyCount} 个
📝 语言文件: {languageFile}

处理的文件:
  ✓ src/views/{module}/ComponentA.vue (15 keys)
  ✓ src/views/{module}/ComponentB.vue (8 keys)
  ✓ src/views/{module}/hooks/useXxx.ts (5 keys)

📊 总体进度: {processedFiles}/{totalFiles} 文件 ({percentage}%)

继续处理下一批次？[Y/n]
```

## 错误处理

### 单文件处理失败

1. 记录错误信息到进度文件
2. 将文件状态标记为 `failed`
3. 继续处理下一个文件
4. 批次完成后汇报失败文件

```json
{
  "path": "src/views/xxx/Component.vue",
  "status": "failed",
  "error": "JSON parse error at line 15"
}
```

### 批次失败

1. 保存当前进度
2. 输出错误详情
3. 提供重试选项

## 最佳实践

1. **先小范围测试** - 选择一个小模块完整处理，验证流程
2. **及时提交** - 每批次完成后建议 git commit
3. **保留报告** - 扫描报告可用于后续审查
4. **清理进度文件** - 全部完成后删除 `i18n-progress.json`
