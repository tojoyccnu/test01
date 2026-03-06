# TypeScript 规范

通用规则见 `rules/typescript.mdc`

## 禁止 any

```typescript
// ❌ 禁止
function parse(data: any) {}

// ✅ 使用 unknown + 类型收窄
function parse(data: unknown) {
  if (typeof data === 'string') {
    return JSON.parse(data);
  }
}

// ✅ 任意对象
const config: Record<string, unknown> = {};

// ✅ 任意数组
const items: unknown[] = [];
```

## type vs interface

```typescript
// ✅ 对象结构用 interface
interface User {
  id: string;
  name: string;
}

interface Props {
  title: string;
  count?: number;
}

// ✅ 联合类型、函数类型用 type
type Status = 'pending' | 'success' | 'error';
type Handler = (event: Event) => void;
type Result<T> = T | null;
```

## 类型断言

```typescript
// ❌ 滥用 as
const user = data as User;

// ✅ 类型守卫
function isUser(data: unknown): data is User {
  return typeof data === 'object' && data !== null && 'id' in data;
}

if (isUser(data)) {
  console.log(data.name);
}

// ❌ 非空断言
const name = user!.name;

// ✅ 可选链 + 默认值
const name = user?.name ?? '';
```

## 枚举

```typescript
// ❌ 数字枚举
enum Status {
  Pending,
  Success,
}

// ✅ 字符串枚举
enum Status {
  Pending = 'pending',
  Success = 'success',
}

// ✅ 字面量联合类型（更推荐）
type Status = 'pending' | 'success' | 'error';
```

## Vue 相关类型

```typescript
// ✅ Props 类型
const props = defineProps<{
  title: string;
  count?: number;
}>();

// ✅ Emits 类型
const emit = defineEmits<{
  (e: 'update', value: string): void;
  (e: 'close'): void;
}>();

// ✅ Ref 类型
const user = ref<User | null>(null);
const items = ref<string[]>([]);

// ✅ 模板引用类型
const inputRef = ref<HTMLInputElement | null>(null);
const formRef = ref<InstanceType<typeof ElForm> | null>(null);
```

## 提取组件类型

> 参考引用：[extract-component-props](https://github.com/hyf0/vue-skills/blob/master/skills/vue-best-practices/rules/extract-component-props.md)

## withDefaults 联合类型问题

> 参考引用：[with-defaults-union-types](https://github.com/hyf0/vue-skills/blob/master/skills/vue-best-practices/rules/with-defaults-union-types.md)
