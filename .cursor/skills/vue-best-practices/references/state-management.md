# 状态管理规范

## Store 定义

```typescript
// ✅ 推荐：使用 Setup Store 语法

import { defineStore } from 'pinia';

export const useUserStore = defineStore('user', () => {
  // state
  const user = ref<User | null>(null);
  const token = ref('');

  // getters
  const isLoggedIn = computed(() => !!token.value);
  const userName = computed(() => user.value?.name ?? '');

  // actions
  async function login(credentials: LoginCredentials) {
    const res = await api.login(credentials);
    user.value = res.user;
    token.value = res.token;
  }

  function logout() {
    user.value = null;
    token.value = '';
  }

  return {
    user: readonly(user),
    token: readonly(token),
    isLoggedIn,
    userName,
    login,
    logout,
  };
});
```

## 文件结构

```
stores/
├── modules/
│   ├── user.ts          # 用户相关状态
│   ├── app.ts           # 应用全局状态
│   └── settings.ts      # 设置相关状态
└── index.ts             # 导出所有 store
```

## 在组件中使用

```typescript
// ✅ 在 setup 中使用
const userStore = useUserStore();

// ✅ 解构时使用 storeToRefs 保持响应性
const { user, isLoggedIn } = storeToRefs(userStore);
const { login, logout } = userStore; // actions 可以直接解构

// ❌ 直接解构状态会丢失响应性
const { user } = userStore; // user 不再是响应式的
```

## Store 之间调用

```typescript
export const useCartStore = defineStore('cart', () => {
  const userStore = useUserStore();

  const items = ref<CartItem[]>([]);

  async function checkout() {
    if (!userStore.isLoggedIn) {
      throw new Error('请先登录');
    }
    // checkout 逻辑
  }

  return { items, checkout };
});
```

## 持久化

```typescript
// ✅ 使用 pinia-plugin-persistedstate
export const useSettingsStore = defineStore(
  'settings',
  () => {
    const theme = ref<'light' | 'dark'>('light');
    const locale = ref('zh-CN');

    return { theme, locale };
  },
  {
    persist: {
      key: 'app-settings',
      storage: localStorage,
      pick: ['theme', 'locale'],
    },
  }
);
```
