# Vue 国际化使用规范

## 前置条件

使用 `i18n-prepare` skill 创建规范的 i18n key 值，然后按照本规范使用。

## 核心用法

### 模板中使用 `$t()`

```vue
<template>
  <!-- 基础用法 -->
  <header>{{ $t('settings.pageTitle') }}</header>

  <!-- 属性绑定 -->
  <a-input :placeholder="$t('knowledge.inputSearch.placeholderSearch')" />

  <!-- 带插值 -->
  <span>{{ $t('knowledge.detailsHeader.updateTime', { n: props.info.show_time }) }}</span>

  <!-- 复数形式 -->
  {{ $tc('tools.controlPanel.cpuInfo.coreUnit', props.core) }}
</template>
```

### Script 中使用 `i18n.t()`

```typescript
import { i18n } from 'ugos-core';

// 基础用法
const label = i18n.t('sidebar.newChatButton.text');

// 带插值
const text = i18n.t('tools.docker.container.image', { n: imageName });

// 动态 key
const message = i18n.t(`ai-elements.Sender.placeholder.${chatMode.value}`);

// 复数形式
const coreText = i18n.tc('tools.controlPanel.cpuInfo.coreUnit', coreCount);

// 在对象中使用
const options = {
  [i18n.t('common.status.active')]: 'active',
  [i18n.t('common.status.inactive')]: 'inactive',
} as const;
```

### `<i18n>` 组件（包含 HTML 的复杂文本）

用于处理包含可点击元素、链接等复杂 HTML 内容的国际化文本。

**方式 A：位置占位符**

```vue
<template>
  <i18n path="tools.errorCode.404" tag="span" :places="{ title: queryAppTitle }">
    <span class="cursor-pointer text-blue-500" @click="handleDownloadApp">
      {{ $t('tools.normal.appCenter') }}
    </span>
  </i18n>
</template>
```

语言文件：

```json
{
  "errorCode": {
    "404": "抱歉，当前设备未安装{title}应用，请前往{0}下载。"
  }
}
```

**方式 B：具名插槽（推荐）**

```vue
<template>
  <i18n path="tools.controlPanel.title" tag="label">
    <template #path>
      <a class="text-blue-500" @click.prevent="handleAboutMachine">
        {{ $t('tools.controlPanel.aboutMachine') }}
      </a>
    </template>
    <template #otherPath>
      <a class="text-blue-500" @click.prevent="handleHardwareAndPower">
        {{ $t('tools.controlPanel.hardwareAndPower') }}
      </a>
    </template>
  </i18n>
</template>
```

语言文件：

```json
{
  "controlPanel": {
    "title": "检索到的信息如下，详情可在{path}或{otherPath}中查看："
  }
}
```

**参数说明**：

- `path`：i18n key
- `tag`：渲染的外层 HTML 标签
- `:places`：传递命名占位符对象（如 `{title}`）
- 默认插槽：替换位置占位符（如 `{0}`, `{1}`）
- 具名插槽：替换命名占位符（如 `{path}`, `{otherPath}`）

## 使用场景

### 表单字段

```vue
<template>
  <a-form-item :label="$t('settings.UserProfile.nameLabel')">
    <a-input v-model="name" :placeholder="$t('settings.UserProfile.namePlaceholder')" />
  </a-form-item>
</template>
```

### 错误提示

```typescript
import { i18n } from 'ugos-core';

import { tipMessage } from '@/utils/tipMessage';

try {
  // ...
} catch (error) {
  tipMessage(i18n.t('common.requestErrorTip'), 'error');
}
```

### 下拉选项

```typescript
const options = computed(() => [
  { label: i18n.t('settings.LanguageSelector.zhCN'), value: 'zh-CN' },
  { label: i18n.t('settings.LanguageSelector.enUS'), value: 'en-US' },
]);
```

### 动态内容

```vue
<script setup lang="ts">
const statusText = computed(() => i18n.t(`common.status.${status.value}`));
</script>

<template>
  <div>{{ statusText }}</div>
</template>
```

## 规范要点

| 场景        | 方式                     | 说明                     |
| ----------- | ------------------------ | ------------------------ |
| Vue 模板    | `$t()` / `$tc()`         | 直接使用，无需导入       |
| Script 代码 | `i18n.t()` / `i18n.tc()` | 需要导入 `ugos-core`     |
| 插值参数    | 命名参数 `{ n: }`        | 不使用位置参数           |
| 动态 key    | 模板字符串               | 使用 `` `key.${var}` ``  |
| 复数形式    | `$tc()` / `i18n.tc()`    | 根据数量自动选择         |
| 包含 HTML   | `<i18n>` 组件            | 处理链接、按钮等复杂内容 |

## 常见错误

### 字符串拼接

```typescript
// ❌ 错误
i18n.t('common.' + type);

// ✅ 正确
i18n.t(`common.${type}`);
```

### 模板中复杂动态 key

```vue
<!-- ❌ 错误 -->
<span>{{ $t(`ai-elements.${computedType}.${status}`) }}</span>

<!-- ✅ 正确：使用计算属性 -->
<script setup>
const text = computed(() => i18n.t(`ai-elements.${type.value}.${status.value}`));
</script>
<template>
  <span>{{ text }}</span>
</template>
```

### 混用方式

```vue
<!-- ❌ 错误：模板中混用 $t() 和 i18n.t() -->
<template>
  <div>{{ $t('key1') }}</div>
  <div>{{ i18n.t('key2') }}</div>
</template>

<!-- ✅ 正确：统一使用 $t() -->
<template>
  <div>{{ $t('key1') }}</div>
  <div>{{ $t('key2') }}</div>
</template>
```

### 硬编码文本

```vue
<!-- ❌ 错误：硬编码中文 -->
<button>确定</button>

<!-- ✅ 正确：使用 i18n -->
<button>{{ $t('common.Prompt.confirm') }}</button>
```

**注意**：如果遇到硬编码文本，先使用 `i18n-prepare` skill 创建规范的 i18n key，然后根替换为 `$t()` 或 `i18n.t()` 调用（注意复数使用`$tc()` 或 `i18n.tc()` ）。
