# 组件结构规范

## SFC 组件结构顺序

```vue
<template>
  <!-- 模板内容 -->
</template>

<script setup lang="ts">
// 脚本内容
</script>

<style scoped lang="scss">
/* 样式内容 */
</style>
```

## Script Setup 内部顺序

1. 类型导入
2. 组件导入
3. Composables 导入
4. Props 定义
5. Emits 定义
6. 响应式状态
7. 计算属性
8. 方法
9. 生命周期钩子
10. defineExpose

## 注释规范

注释应描述业务逻辑或复杂实现的原因，不要写代码分类标签。

```typescript
// ❌ 错误：无意义的分类注释
// 响应式状态
const count = ref(0);
// 计算属性
const doubleCount = computed(() => count.value * 2);

// ✅ 正确：简单代码不需要注释
const count = ref(0);
const doubleCount = computed(() => count.value * 2);

// ✅ 正确：解释业务逻辑
// 防止用户重复提交，3秒内只允许点击一次
const isSubmitting = ref(false);
```

## Props 定义

```typescript
// ✅ 使用 TypeScript 类型定义
const props = defineProps<{
  title: string;
  count?: number;
  items: string[];
}>();

// ✅ 带默认值
const props = withDefaults(
  defineProps<{
    title?: string;
    count?: number;
  }>(),
  {
    title: '默认标题',
    count: 0,
  }
);

// ❌ 不要使用运行时声明
const props = defineProps({
  title: String,
  count: Number,
});
```

## Emits 定义

```typescript
// ✅ 使用 TypeScript 类型定义
const emit = defineEmits<{
  (e: 'update', value: string): void;
  (e: 'close'): void;
}>();

// ❌ 不要使用数组形式
const emit = defineEmits(['update', 'close']);
```
