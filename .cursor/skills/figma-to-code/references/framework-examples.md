# Vue 3 + Arco Design Vue 示例

使用 Framelink MCP 和项目设计系统的代码示例。

## 核心原则

**优先使用 Arco Design Vue**：能用 Arco Design Vue 组件实现的，尽量使用 Arco Design Vue，而非自己编写组件。只有当 Arco 组件无法满足需求时，才使用 Tailwind CSS 自定义实现。

---

## 组件选择指南

| 需求            | 推荐方案         |
| --------------- | ---------------- |
| 按钮            | `<a-button>`     |
| 输入框          | `<a-input>`      |
| 选择器          | `<a-select>`     |
| 开关            | `<a-switch>`     |
| 表单            | `<a-form>`       |
| 表格            | `<a-table>`      |
| 模态框          | `<a-modal>`      |
| 消息提示        | `Message.info()` |
| 下拉菜单        | `<a-dropdown>`   |
| 标签页          | `<a-tabs>`       |
| 自定义布局/卡片 | Tailwind CSS     |

---

## Arco Design Vue 常用示例

### 按钮

```vue
<template>
  <a-space>
    <a-button type="primary">主要按钮</a-button>
    <a-button>次要按钮</a-button>
    <a-button type="text">文字按钮</a-button>
    <a-button type="primary" status="danger">危险按钮</a-button>
    <a-button type="primary" :loading="loading">加载中</a-button>
  </a-space>
</template>
```

### 表单

```vue
<template>
  <a-form :model="form" layout="vertical" @submit="handleSubmit">
    <a-form-item field="name" label="名称" :rules="[{ required: true, message: '请输入名称' }]">
      <a-input v-model="form.name" placeholder="请输入名称" />
    </a-form-item>
    <a-form-item field="type" label="类型">
      <a-select v-model="form.type" :options="typeOptions" placeholder="请选择类型" />
    </a-form-item>
    <a-form-item>
      <a-space>
        <a-button type="primary" html-type="submit">提交</a-button>
        <a-button @click="handleReset">重置</a-button>
      </a-space>
    </a-form-item>
  </a-form>
</template>

<script lang="ts" setup>
import { reactive } from 'vue';

const form = reactive({ name: '', type: '' });
const typeOptions = [
  { label: '类型 A', value: 'a' },
  { label: '类型 B', value: 'b' },
];

const handleSubmit = () => console.log('提交:', form);
const handleReset = () => Object.assign(form, { name: '', type: '' });
</script>
```

### 表格

```vue
<template>
  <a-table :columns="columns" :data="data" :pagination="{ pageSize: 10 }">
    <template #status="{ record }">
      <a-tag :color="record.status === 'active' ? 'green' : 'red'">
        {{ record.status === 'active' ? '启用' : '禁用' }}
      </a-tag>
    </template>
    <template #action="{ record }">
      <a-space>
        <a-button type="text" size="small" @click="handleEdit(record)">编辑</a-button>
        <a-popconfirm content="确定删除？" @ok="handleDelete(record)">
          <a-button type="text" status="danger" size="small">删除</a-button>
        </a-popconfirm>
      </a-space>
    </template>
  </a-table>
</template>

<script lang="ts" setup>
const columns = [
  { title: 'ID', dataIndex: 'id' },
  { title: '名称', dataIndex: 'name' },
  { title: '状态', slotName: 'status' },
  { title: '操作', slotName: 'action', width: 150 },
];

const data = [
  { id: 1, name: '项目 A', status: 'active' },
  { id: 2, name: '项目 B', status: 'inactive' },
];

const handleEdit = (record: any) => console.log('编辑:', record);
const handleDelete = (record: any) => console.log('删除:', record);
</script>
```

### 模态框

```vue
<template>
  <a-button @click="visible = true">打开弹窗</a-button>
  <a-modal v-model:visible="visible" title="标题" @ok="handleOk" @cancel="handleCancel">
    <p>弹窗内容</p>
  </a-modal>
</template>

<script lang="ts" setup>
import { ref } from 'vue';

const visible = ref(false);
const handleOk = () => console.log('确认');
const handleCancel = () => console.log('取消');
</script>
```

---

## Tailwind CSS 自定义组件

仅当 Arco Design Vue 无法满足需求时使用。

### 卡片容器

```vue
<template>
  <div class="bg-bg-4 rounded-xl p-4 shadow-black-md">
    <h3 class="text-lg font-medium text-text-1">{{ title }}</h3>
    <p class="mt-2 text-sm text-text-2">{{ description }}</p>
    <slot />
  </div>
</template>

<script lang="ts" setup>
defineProps<{ title: string; description?: string }>();
</script>
```

### 可点击列表项

```vue
<template>
  <div
    class="cursor-pointer rounded-lg p-3 transition-colors hover:bg-fill-3"
    @click="$emit('click')"
  >
    <span class="text-sm text-text-1"><slot /></span>
  </div>
</template>
```

### 状态标签（自定义样式）

```vue
<template>
  <span :class="tagClasses">{{ text }}</span>
</template>

<script lang="ts" setup>
import { computed } from 'vue';

const props = defineProps<{ type: 'success' | 'warning' | 'danger'; text: string }>();

const tagClasses = computed(() => {
  const base = 'rounded-sm px-2 py-0.5 text-xs';
  const variants = {
    success: 'bg-success-6/10 text-success-6',
    warning: 'bg-warning-6/10 text-warning-6',
    danger: 'bg-danger-6/10 text-danger-6',
  };
  return `${base} ${variants[props.type]}`;
});
</script>
```

---

## 布局示例

### 页面布局（Arco + Tailwind）

```vue
<template>
  <a-layout class="h-screen">
    <a-layout-sider :width="200" class="bg-bg-3">
      <div class="p-4 text-lg font-medium text-text-1">Logo</div>
      <a-menu :selected-keys="[currentKey]">
        <a-menu-item key="home">首页</a-menu-item>
        <a-menu-item key="user">用户</a-menu-item>
        <a-menu-item key="settings">设置</a-menu-item>
      </a-menu>
    </a-layout-sider>
    <a-layout-content class="bg-bg-2 p-6">
      <slot />
    </a-layout-content>
  </a-layout>
</template>

<script lang="ts" setup>
defineProps<{ currentKey?: string }>();
</script>
```

---

## 设计 Token 快速参考

### 颜色

| 用途     | Tailwind 类      |
| -------- | ---------------- |
| 主要正文 | `text-text-1`    |
| 次级文字 | `text-text-2`    |
| 禁用文字 | `text-text-4`    |
| 品牌主色 | `bg-primary-6`   |
| 成功     | `text-success-6` |
| 警告     | `text-warning-6` |
| 错误     | `text-danger-6`  |

### 间距

| 像素 | 值  | 像素 | 值  |
| ---- | --- | ---- | --- |
| 4px  | `1` | 16px | `4` |
| 8px  | `2` | 24px | `6` |
| 12px | `3` | 32px | `8` |

### 圆角

| 场景      | Tailwind 类         |
| --------- | ------------------- |
| 小元素    | `rounded-sm` (4px)  |
| 输入框    | `rounded-md` (6px)  |
| 按钮/卡片 | `rounded-lg` (8px)  |
| 大卡片    | `rounded-xl` (10px) |

### 阴影

| 场景  | Tailwind 类       |
| ----- | ----------------- |
| Toast | `shadow-black-sm` |
| 菜单  | `shadow-black-md` |
| 弹窗  | `shadow-black-lg` |

---

完整设计 Token 定义请参考 [design-token skill](../../design-token/SKILL.md)。
