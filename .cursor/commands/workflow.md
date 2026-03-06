# 编排命令

用于复杂任务的多代理顺序执行工作流。

## 使用方法

`/workflow [workflow-type] [task-description]`

## 工作流类型

### feature（功能开发）

调用 **tdd-workflow** skill 执行完整功能开发流程：

```
需求澄清 → planner（多方案） → 用户选择 → tdd-guide → code-reviewer
```

附加 security-reviewer 作为最后一步（涉及认证/支付/敏感数据时）。

### bugfix（缺陷修复）

缺陷调查与修复工作流：

```
explorer -> tdd-guide -> code-reviewer
```

### refactor（重构）

安全重构工作流：

```
architect -> code-reviewer -> tdd-guide
```

### security（安全审查）

以安全为核心的审查工作流：

```
security-reviewer -> code-reviewer -> architect
```

## 执行模式

对于工作流中的每个代理：

1. **调用代理** - 传入上一个代理的上下文
2. **收集输出** - 生成结构化的交接文档
3. **传递给下一个代理** - 沿链条传递
4. **汇总结果** - 生成最终报告

## 交接文档格式

代理之间创建交接文档：

```markdown
## HANDOFF: [前一个代理] -> [下一个代理]

### 上下文

[完成工作的摘要]

### 发现

[关键发现或决策]

### 修改的文件

[涉及的文件列表]

### 待解决问题

[需要下一个代理处理的未解决事项]

### 建议

[建议的后续步骤]
```

## 并行执行

对于独立的检查任务，可以并行运行代理：

```markdown
### 并行阶段

同时运行：

- code-reviewer（代码质量）
- security-reviewer（安全性）

### 合并结果

将各输出合并为单一报告
```

## 参数说明

$ARGUMENTS:

- `feature <description>` - 完整功能开发工作流
- `bugfix <description>` - 缺陷修复工作流
- `refactor <description>` - 重构工作流
- `security <description>` - 安全审查工作流
- `custom <agents> <description>` - 自定义代理序列

## 自定义工作流示例

```
/workflow custom "architect,tdd-guide,code-reviewer" "重新设计缓存层"
```

## 使用技巧

1. **从 planner 开始** - 用于复杂功能
2. **始终包含 code-reviewer** - 在合并之前
3. **使用 security-reviewer** - 涉及认证/支付/个人敏感信息时
4. **保持交接文档简洁** - 聚焦于下一个代理所需的信息
