# Script Setup 组件的 JSDoc 文档

`<script setup>` 内部的 JSDoc 注释无法附加到组件导出（没有显式 export）。使用双 script 模式解决。

## 模式

```vue
<script lang="ts">
/**
 * 计数器组件，显示并递增数值。
 *
 * @example
 * <Counter :initial="5" @update="handleUpdate" />
 */
export default {};
</script>

<script setup lang="ts">
const props = defineProps<{
  /** 计数器初始值 */
  initial?: number;
}>();

const emit = defineEmits<{
  /** 数值变化时触发 */
  update: [value: number];
}>();
</script>
```

## 文档位置

| 位置                      | 显示于           |
| ------------------------- | ---------------- |
| `export default {}` JSDoc | 组件导入时的悬停 |
| `defineProps` JSDoc       | 模板中 prop 悬停 |
| `defineEmits` JSDoc       | 事件处理器悬停   |

原理：普通 `<script>` 的默认导出会与 `<script setup>` 合并。
