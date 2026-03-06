# Vue 样式编写规范

## 核心原则

1. **Tailwind 优先**：优先使用 Tailwind CSS 类名
2. **禁止硬编码**：所有颜色、间距必须使用设计 Token
3. **动态样式用 cn**：条件样式、合并类名使用 `cn()` 方法
4. **复杂变体用 CVA**：多状态组件使用 `class-variance-authority`

## 设计 Token 参考

查看完整的设计 Token（颜色、间距、圆角、阴影等）和常用样式组合，请参考：

**`.cursor/skills/design-token/SKILL.md`**

## cn 方法使用

`cn()` 方法用于合并和条件渲染 Tailwind 类名（基于 `design-token` skill）。

### 检查和创建

如果项目中不存在 `cn` 方法（`src/utils/cn.ts`），使用模板创建：

**模板位置**：`assets/cn.template`

**依赖包**：

```bash
pnpm add clsx tailwind-merge
```

### 基础用法

```vue
<script setup lang="ts">
import { cn } from '@/utils';

const props = defineProps<{
  disabled?: boolean;
  active?: boolean;
}>();

// cn 方法合并 Tailwind 类名（使用设计 Token）
const buttonClass = computed(() =>
  cn(
    // 基础样式：使用设计 Token 的圆角、间距、字体
    'rounded-lg px-4 py-2 text-sm',
    // 条件样式：使用设计 Token 的颜色
    props.disabled && 'cursor-not-allowed opacity-50',
    props.active && 'bg-primary-6 text-white',
    !props.active && 'bg-primary-1 text-primary-6'
  )
);
</script>

<template>
  <button :class="buttonClass">按钮</button>
</template>
```

## CVA 样式变体

对于多状态组件，使用 CVA 定义样式变体（所有类名都基于 `design-token` skill）。

在组件目录下创建 `styles.ts`：

```typescript
import { cva } from 'class-variance-authority';

// CVA 变体定义：使用设计 Token 的 Tailwind 类名
export const button = cva('inline-flex items-center justify-center rounded-lg', {
  variants: {
    variant: {
      // 品牌色 Token：primary-6（常规）、primary-5（悬浮）
      primary: 'bg-primary-6 text-white hover:bg-primary-5',
      // 品牌色 Token：primary-1（浅色背景）、primary-2（悬浮）
      secondary: 'bg-primary-1 text-primary-6 hover:bg-primary-2',
    },
    size: {
      // 间距和字体 Token
      small: 'px-3 py-1.5 text-xs',
      medium: 'px-4 py-2 text-sm',
    },
  },
  defaultVariants: {
    variant: 'primary',
    size: 'medium',
  },
});
```

在组件中使用（结合 cn 方法）：

```vue
<script setup lang="ts">
import { cn } from '@/utils';

import { button } from './styles';

// cn 方法合并 CVA 变体和额外的类名
const buttonClass = computed(() =>
  cn(
    button({ variant: props.variant, size: props.size }),
    props.loading && 'opacity-50 pointer-events-none'
  )
);
</script>
```
