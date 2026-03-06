# 数据获取规范

本项目使用 TanStack Query（Vue Query）进行数据获取和缓存管理。

## Query Keys

使用工厂函数模式，支持层级结构和前缀匹配：

```typescript
// src/constant/queryKeys.ts
export const queryKeys = {
  model: {
    root: ['model', APP_ID],
    list: () => [...queryKeys.model.root, 'list'],
    detail: (id: string) => [...queryKeys.model.root, 'detail', id],
  },
} as const;
```

## useQuery

```typescript
// ✅ 封装为独立函数
export const useQueryModelList = () => {
  return useQuery({
    queryKey: queryKeys.model.list(),
    queryFn: () => getModelList(),
    select: data => data?.data?.result ?? [],
  });
};

// ✅ 响应式参数：queryKey 和 enabled 使用 computed
export const useQueryModelDetail = (id: Ref<string>) => {
  return useQuery({
    queryKey: computed(() => queryKeys.model.detail(id.value)),
    queryFn: () => getModelDetail(id.value),
    enabled: computed(() => !!id.value),
  });
};
```

## useMutation

```typescript
// ✅ 基础 mutation + 缓存失效
export const useModelOperate = () => {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: (body: OperateRequest) => postModelOperate(body),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: queryKeys.model.root });
    },
    onError: error => handleError(error),
  });
};
```

## 乐观更新

两种方式：UI 层（简单）和缓存层（复杂）。

```typescript
// 方式一：UI 层 - 使用 variables 临时显示
const { mutate, variables, isPending } = useMutation({
  mutationFn: addTodo,
});

// 模板中：isPending 时显示 variables 作为临时数据

// 方式二：缓存层 - 完整回滚模式
useMutation({
  mutationFn: updateTodo,
  onMutate: async newTodo => {
    await queryClient.cancelQueries({ queryKey: ['todos'] });
    const previous = queryClient.getQueryData(['todos']);
    queryClient.setQueryData(['todos'], old => [...old, newTodo]);
    return { previous }; // 传递给 onError
  },
  onError: (err, newTodo, context) => {
    queryClient.setQueryData(['todos'], context.previous); // 回滚
  },
  onSettled: () => {
    queryClient.invalidateQueries({ queryKey: ['todos'] }); // 始终重新获取
  },
});
```

## 缓存失效策略

```typescript
// 前缀匹配（默认）- 使所有以 'model' 开头的查询失效
queryClient.invalidateQueries({ queryKey: queryKeys.model.root });

// 精确匹配
queryClient.invalidateQueries({ queryKey: ['todos'], exact: true });

// 谓词函数（复杂条件）
queryClient.invalidateQueries({
  predicate: query => query.queryKey[0] === 'todos' && query.queryKey[1]?.version >= 10,
});
```

## 模板状态处理

```vue
<template>
  <div v-if="isPending">加载中...</div>
  <div v-else-if="isError">{{ error.message }}</div>
  <div v-else-if="data"><!-- 展示数据 --></div>
  <div v-else>暂无数据</div>
</template>
```

## 项目默认配置

```typescript
// src/lib/vueQuery.ts
{
  queries: {
    refetchOnWindowFocus: false,  // 禁用窗口聚焦刷新
    retry: false,                  // 禁用自动重试
    networkMode: 'always',
  },
  mutations: {
    networkMode: 'always',
  },
}
```

## 引用资料

- [TanStack Query](https://github.com/TanStack/query/tree/main/docs/framework/vue)
