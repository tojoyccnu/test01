# 错误处理规范

## 前置依赖

确保项目中存在以下工具函数，如不存在则从模板复制：

- `src/utils/handleError.ts` → 模板：`assets/handleError.template`
- `src/utils/tipMessage.ts` → 模板：`assets/tipMessage.template`

依赖：`@arco-design/web-vue`（Message 组件）、`lodash-es`

## 核心工具

```typescript
import { getErrorMessage, handleError } from '@/utils/handleError';
import { tipMessage } from '@/utils/tipMessage';
```

| 函数                    | 用途               |
| ----------------------- | ------------------ |
| `handleError(err)`      | 统一处理并显示提示 |
| `getErrorMessage(err)`  | 提取错误信息文本   |
| `tipMessage(msg, type)` | 显示消息提示       |

## 常用模式

### try-catch

```typescript
try {
  await someAsyncOperation();
  tipMessage('操作成功', 'success');
} catch (error) {
  handleError(error);
}
```

### TanStack Query

```typescript
// Mutation
useMutation({
  mutationFn: updateData,
  onError: handleError,
  onSuccess: () => tipMessage('保存成功', 'success'),
});

// Query - 使用 watch 监听错误
const { isError, error } = useQuery({ queryKey: ['data'], queryFn: fetchData });

watch(isError, hasError => {
  if (hasError && error.value) {
    handleError(error.value);
  }
});
```

### 组件错误边界

```vue
<template>
  <ErrorBoundary>
    <template #default>
      <RiskyComponent />
    </template>
    <template #error="{ error, clearError }">
      <p>出错了: {{ error.message }}</p>
      <button @click="clearError">重试</button>
    </template>
  </ErrorBoundary>
</template>

<script setup lang="ts">
import ErrorBoundary from '@/components/error-boundary/ErrorBoundary.vue';
</script>
```

### 静默处理

```typescript
try {
  await optionalOperation();
} catch (error) {
  console.error('Operation failed:', error); // 至少记录日志
}
```

## 注意事项

1. **优先使用 `handleError`** - 保持一致性
2. **避免吞掉错误** - 静默处理时记录 `console.error`
3. **特殊错误码** - 检查 `error.code` 进行业务处理
4. **消息限制** - 使用 `tipMessage` 进行提示
