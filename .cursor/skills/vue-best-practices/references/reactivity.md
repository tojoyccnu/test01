# 响应式 API 规范

## ref vs reactive

```typescript
// ✅ 推荐：使用 ref（更一致、更灵活）
const count = ref(0);
const user = ref<User | null>(null);
const items = ref<string[]>([]);

// ⚠️ 可选：复杂对象可使用 reactive
const form = reactive({
  name: '',
  email: '',
  age: 0,
});

// ❌ 避免：reactive 包装原始值
const count = reactive({ value: 0 }); // 应使用 ref
```

## computed

```typescript
// ✅ 只读计算属性
const fullName = computed(() => `${firstName.value} ${lastName.value}`);

// ✅ 可写计算属性
const fullName = computed({
  get: () => `${firstName.value} ${lastName.value}`,
  set: value => {
    const [first, last] = value.split(' ');
    firstName.value = first;
    lastName.value = last;
  },
});

// ❌ 不要在 computed 中有副作用
const result = computed(() => {
  api.logAccess(); // 副作用
  return count.value * 2;
});
```

## watch

```typescript
// ✅ 监听单个 ref
watch(count, (newVal, oldVal) => {
  console.log(`count changed: ${oldVal} -> ${newVal}`);
});

// ✅ 监听多个源
watch([firstName, lastName], ([newFirst, newLast]) => {
  console.log(`name changed: ${newFirst} ${newLast}`);
});

// ✅ 监听 getter
watch(
  () => props.id,
  newId => {
    fetchData(newId);
  }
);

// ✅ 深度监听
watch(
  () => state.nested,
  newVal => {},
  { deep: true }
);

// ✅ 立即执行
watch(source, val => {}, { immediate: true });
```

## watchEffect

```typescript
// ✅ 自动追踪依赖
watchEffect(() => {
  console.log(`count is: ${count.value}`);
});

// ✅ 清理副作用
watchEffect(onCleanup => {
  const timer = setInterval(() => {}, 1000);
  onCleanup(() => clearInterval(timer));
});
```

## toRef / toRefs

```typescript
// ✅ 从 props 解构保持响应性
const props = defineProps<{ title: string; count: number }>();
const { title, count } = toRefs(props);

// ✅ 单个属性
const title = toRef(props, 'title');

// ❌ 直接解构会丢失响应性
const { title } = props; // title 不再是响应式的
```
