# 文件路由系统

基于 `unplugin-vue-router` 实现基于文件的自动路由生成。

## 路由识别规则

**重要**：只有 **kebab-case** 格式的 `.vue` 文件会被识别为路由文件：

| 文件类型 | 命名格式   | 示例               | 是否为路由 |
| -------- | ---------- | ------------------ | ---------- |
| 路由页面 | kebab-case | `index.vue`        | ✓          |
| 路由页面 | kebab-case | `user-profile.vue` | ✓          |
| 业务组件 | PascalCase | `UserProfile.vue`  | ✗          |

## 添加新页面

在 `src/views/` 目录下创建 kebab-case 格式的 `.vue` 文件即可自动生成路由：

| 文件路径                               | 路由路径            |
| -------------------------------------- | ------------------- |
| `src/views/index.vue`                  | `/`                 |
| `src/views/about.vue`                  | `/about`            |
| `src/views/user/index.vue`             | `/user`             |
| `src/views/user/[id].vue`              | `/user/:id`         |
| `src/views/model-management/index.vue` | `/model-management` |

## 目录结构示例

```
src/views/
├── index.vue                           # / (根路由)
├── model-explore/
│   ├── index.vue                       # /model-explore (路由入口，kebab-case)
│   ├── ModelExplore.vue                # 业务组件（PascalCase，不会成为路由）
│   └── components/                     # 子组件目录
├── model-management/
│   ├── index.vue                       # /model-management
│   ├── language-model.vue              # /model-management/language-model
│   └── components/
│       └── ModelManagement.vue         # 业务组件
```

## 特殊语法

| 语法         | 示例            | 说明                   |
| ------------ | --------------- | ---------------------- |
| `[param]`    | `[id].vue`      | 动态参数               |
| `[[param]]`  | `[[id]].vue`    | 可选参数               |
| `[...param]` | `[...path].vue` | Catch-all              |
| `(group)`    | `(admin)/`      | 路由分组（不影响 URL） |

## 页面配置

使用 `definePage` 宏，**必须在 `<script setup>` 块中使用**：

```vue
<script setup lang="ts">
import UserProfile from './UserProfile.vue';

definePage({
  name: 'UserProfile',
  meta: { title: '用户资料' },
});
</script>

<template>
  <UserProfile />
</template>
```

## 重定向

```vue
<script setup lang="ts">
definePage({
  redirect: '/model-explore',
});
</script>
```
