# i18n 模式参考

详细的中文识别和替换模式指南。

## 中文匹配规则

匹配包含至少 2 个连续中文字符的字符串：

- 正则参考：`[\u4e00-\u9fff]{2,}`
- 包括中文标点：`[\u4e00-\u9fff\u3000-\u303f\uff00-\uffef]{2,}`

## Vue 模板中的模式

### 1. 文本内容

```vue
<!-- 原始 -->
<span>存储位置</span>
<h2 class="title">AI数据存储</h2>
<p>{{ '暂无数据' }}</p>

<!-- 转换后 -->
<span>{{ $t('module.Component.label') }}</span>
<h2 class="title">{{ $t('module.Component.title') }}</h2>
<p>{{ $t('module.Component.empty') }}</p>
```

### 2. 原生 HTML 属性

```vue
<!-- 原始 -->
<input placeholder="请输入内容" />
<div title="点击查看详情">...</div>
<img alt="用户头像" />

<!-- 转换后 -->
<input :placeholder="$t('module.Component.placeholder')" />
<div :title="$t('module.Component.tooltip')">...</div>
<img :alt="$t('module.Component.altText')" />
```

### 3. Arco Design 组件属性

```vue
<!-- 原始 -->
<a-modal title="选择位置" ok-text="确定" cancel-text="取消">
<a-input placeholder="请输入" />
<a-button>提交</a-button>
<a-empty description="暂无数据" />

<!-- 转换后 -->
<a-modal :title="$t('key')" :ok-text="$t('key')" :cancel-text="$t('key')">
<a-input :placeholder="$t('key')" />
<a-button>{{ $t('key') }}</a-button>
<a-empty :description="$t('key')" />
```

### 4. v-bind 动态绑定

```vue
<!-- 原始 -->
<component :label="'标签'" :tips="'提示信息'" />

<!-- 转换后 -->
<component :label="$t('key')" :tips="$t('key')" />
```

## Script / TypeScript 中的模式

### 1. 函数调用参数

```typescript
// 原始
Message.success('删除成功');
Message.error('操作失败，请重试');
tipMessage('保存成功', 'success');

// 转换后
Message.success(i18n.t('module.Component.deleteSuccess'));
Message.error(i18n.t('module.Component.operationFailed'));
tipMessage(i18n.t('module.Component.saveSuccess'), 'success');
```

### 2. Modal 对话框

```typescript
// 原始
Modal.info({
  title: '删除确认',
  content: '确定要删除吗？',
  okText: '删除',
  cancelText: '取消',
});

// 转换后
Modal.info({
  title: i18n.t('module.Component.deleteTitle'),
  content: i18n.t('module.Component.deleteContent'),
  okText: i18n.t('module.Component.deleteOk'),
  cancelText: i18n.t('common.cancel'),
});
```

### 3. 对象字面量

```typescript
// 原始
const config = {
  title: '设置',
  description: '系统设置页面',
};

// 转换后
const config = {
  title: i18n.t('module.Component.title'),
  description: i18n.t('module.Component.description'),
};
```

### 4. 变量赋值

```typescript
// 原始
const errorMessage = '请求发生错误';
let statusText = '加载中...';

// 转换后
const errorMessage = i18n.t('common.requestError');
let statusText = i18n.t('common.loading');
```

### 5. 数组中的字符串

```typescript
// 原始
const options = [
  { label: '全部', value: 'all' },
  { label: '已启用', value: 'enabled' },
  { label: '已停用', value: 'disabled' },
];

// 转换后
const options = [
  { label: i18n.t('module.Component.all'), value: 'all' },
  { label: i18n.t('module.Component.enabled'), value: 'enabled' },
  { label: i18n.t('module.Component.disabled'), value: 'disabled' },
];
```

## 动态拼接文本

### 1. 模板字符串

```typescript
// 原始
const msg = `模型 ${name} 启用成功`;
const tip = `已选择 ${count} 个文件`;

// 转换后
const msg = i18n.t('model.Toast.enable', { name });
const tip = i18n.t('file.selected', { count });

// 语言文件
{
  "Toast": { "enable": "模型 {name} 启用成功" },
  "selected": "已选择 {count} 个文件"
}
```

### 2. 字符串连接

```typescript
// 原始
const msg = '删除' + modelName + '成功';
const text = '共' + total + '条，已选' + selected + '条';

// 转换后
const msg = i18n.t('model.deleteSuccess', { name: modelName });
const text = i18n.t('common.selectedCount', { total, selected });

// 语言文件
{
  "deleteSuccess": "删除 {name} 成功",
  "selectedCount": "共 {total} 条，已选 {selected} 条"
}
```

### 3. Vue 模板中的拼接

```vue
<!-- 原始 -->
<span>{{ '共 ' + count + ' 条记录' }}</span>
<span>{{ `${name} 的设置` }}</span>

<!-- 转换后 -->
<span>{{ $t('common.totalRecords', { count }) }}</span>
<span>{{ $t('module.settingsOf', { name }) }}</span>

<!-- 语言文件 -->
{ "totalRecords": "共 {count} 条记录", "settingsOf": "{name} 的设置" }
```

### 4. 复杂多变量拼接

```typescript
// 原始
Modal.info({
  content: `启用「${newModel}」将停止「${currentModel}」，正在生成的内容将被中断`
});

// 转换后
Modal.info({
  content: i18n.t('model.Confirm.switchContent', {
    name: newModel,
    otherName: currentModel
  })
});

// 语言文件
{
  "switchContent": "启用「{name}」将停止「{otherName}」，正在生成的内容将被中断"
}
```

## 单复数文本（Pluralization）

当文本包含数量且需要根据数量显示不同形式时，使用 `$tc` / `i18n.tc` 和管道符语法。

### 语言文件格式

使用管道符 `|` 分隔三种形式：`零 | 单数 | 复数`

```json
{
  "referenceCount": "{n} 篇引用来源 | {n} 篇引用来源 | {n} 篇引用来源",
  "fileCount": "没有文件 | {n} 个文件 | {n} 个文件",
  "selectedItems": "未选择 | 已选择 {n} 项 | 已选择 {n} 项"
}
```

> **注意**：中文通常不区分单复数，三种形式可以相同。但保留此格式是为了支持英文等有单复数变化的语言。

### Vue 模板中使用 `$tc`

```vue
<!-- 原始 -->
<span>{{ count }} 篇引用来源</span>
<span>已选择 {{ selected }} 项</span>

<!-- 转换后 -->
<span>{{ $tc('module.Component.referenceCount', count) }}</span>
<span>{{ $tc('module.Component.selectedItems', selected) }}</span>
```

### Script / TypeScript 中使用 `i18n.tc`

```typescript
// 原始
const text = `${count} 篇引用来源`;
const msg = `已选择 ${selected} 个文件`;

// 转换后
const text = i18n.tc('module.Component.referenceCount', count);
const msg = i18n.tc('module.Component.fileSelected', selected);
```

### 复数与额外参数结合

当复数文本中还需要其他变量时：

```typescript
// 原始
const msg = `${userName} 有 ${count} 条未读消息`;

// 转换后
const msg = i18n.tc('module.Component.unreadMessages', count, { name: userName });

// 语言文件
{
  "unreadMessages": "{name} 没有未读消息 | {name} 有 {n} 条未读消息 | {name} 有 {n} 条未读消息"
}
```

### 何时使用 `$tc` vs `$t`

| 场景                         | 使用              | 示例                       |
| ---------------------------- | ----------------- | -------------------------- |
| 文本中数量会影响语法形式     | `$tc` / `i18n.tc` | "1 个文件" vs "2 个文件"   |
| 数量只是插值，不影响文本结构 | `$t` / `i18n.t`   | "共 {count} 条记录"        |
| 需要支持多语言单复数变化     | `$tc` / `i18n.tc` | 英文 "1 item" vs "2 items" |

## 排除规则详解

### 1. 代码注释

```typescript
// 这是中文注释，不处理
/* 多行中文注释
   也不处理 */
```

```vue
<!-- Vue 模板注释不处理 -->
```

### 2. console 日志

```typescript
// 不处理
console.log('调试信息');
console.error('错误详情', error);
console.warn('警告信息');
```

### 3. 已国际化的内容

```typescript
// 已处理，跳过
i18n.t('common.confirm');
i18n.tc('common.itemCount', count);
$t('module.title');
$tc('module.fileCount', count);
```

### 4. 导入路径

```typescript
// 不处理

import { something } from '某个路径'; // 实际不会出现中文路径
```

### 5. CSS 相关

```vue
<!-- class 名称不处理 -->
<div class="中文类名"></div>
<!-- 实际不应出现 -->

<!-- style 中的内容不处理 -->
<style>
.selector::before {
  content: '装饰符'; /* 特殊情况，通常不处理 */
}
</style>
```

## 导入语句处理

### Vue 文件 Script 部分

检查是否已有导入，若无则添加：

```typescript
// 在 <script setup lang="ts"> 开头添加

import { i18n } from 'ugos-core';
```

若已有 ugos-core 导入但没有 i18n：

```typescript
// 原始

// 修改为

import { i18n, urlUtils, urlUtils } from 'ugos-core';
```

### TypeScript 文件

同样检查并添加导入：

```typescript
import { i18n } from 'ugos-core';
```

## Key 命名最佳实践

### 语义化命名

```json
{
  "title": "页面标题",
  "button": {
    "submit": "提交",
    "cancel": "取消",
    "confirm": "确认"
  },
  "placeholder": {
    "input": "请输入",
    "search": "搜索"
  },
  "toast": {
    "success": "操作成功",
    "error": "操作失败"
  },
  "confirm": {
    "title": "确认操作",
    "content": "确定要执行吗？"
  },
  "empty": {
    "data": "暂无数据",
    "result": "无搜索结果"
  }
}
```

### 避免重复

若多个组件使用相同文案，考虑放入 `common.json`：

```json
{
  "GlobalActions": {
    "confirm": "确认",
    "cancel": "取消",
    "delete": "删除",
    "edit": "编辑",
    "save": "保存"
  },
  "GlobalStatus": {
    "loading": "加载中...",
    "error": "发生错误",
    "success": "操作成功"
  }
}
```
