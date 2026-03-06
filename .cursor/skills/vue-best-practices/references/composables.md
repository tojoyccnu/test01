# Composables 规范

## 优先复用现有库

编写 Composables 前，先检查 VueUse 或 lodash-es 中是否有满足需求的功能，优先使用或组合现有方法。

## 参数设计

通用规范见 [function-design.md](function-design.md)

```typescript
// ✅ 支持 ref 和普通值作为参数
export function useDebounce<T>(value: MaybeRef<T>, delay = 300) {
  const debouncedValue = ref(unref(value)) as Ref<T>;

  watch(
    () => unref(value),
    newValue => {
      // debounce 逻辑
    }
  );

  return debouncedValue;
}
```

## 返回值结构

通用规范见 [function-design.md](function-design.md)

```typescript
// ✅ 可写状态直接返回 ref
export function useInput(initialValue = '') {
  const value = ref(initialValue);
  const clear = () => (value.value = '');

  return { value, clear }; // value 可被 v-model 绑定
}
```

## 清理副作用

```typescript
// ✅ 在 onUnmounted 中清理
export function useEventListener(target: EventTarget, event: string, handler: EventListener) {
  onMounted(() => {
    target.addEventListener(event, handler);
  });

  onUnmounted(() => {
    target.removeEventListener(event, handler);
  });
}
```

## 引用资料

- [VueUse Functions](https://vueuse.org/functions.html)
