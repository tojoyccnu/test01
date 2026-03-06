# 函数设计规范

## 命名规范

`rules/naming.mdc`

## 参数数量

```typescript
// ✅ 2个及以下参数：直接传递
function formatDate(date: Date, format: string) {}

// ✅ 超过2个参数：使用对象
function createUser(options: { name: string; email: string; role?: string; avatar?: string }) {}

// ❌ 避免：过多位置参数
function createUser(name: string, email: string, role: string, avatar: string) {}
```

## 参数顺序

```typescript
// ✅ 必填参数在前，可选参数在后
function fetchData(url: string, options?: RequestOptions) {}

// ✅ 回调函数放最后
function processItems(items: Item[], callback: (item: Item) => void) {}
```

## 默认值

```typescript
// ✅ 使用解构默认值
function useDialog(
  options: {
    title?: string;
    width?: number;
    closable?: boolean;
  } = {}
) {
  const { title = '提示', width = 400, closable = true } = options;
}

// ✅ 简单参数直接给默认值
function delay(ms = 300) {}
```

## 返回值

```typescript
// ✅ 多个返回值使用对象
function useCounter() {
  return {
    count,
    increment,
    decrement,
  };
}

// ✅ 异步函数返回 Promise
async function fetchUser(id: string): Promise<User> {}

// ❌ 避免：返回数组（除非顺序有意义）
function useCounter() {
  return [count, increment, decrement]; // 难以记忆顺序
}
```
