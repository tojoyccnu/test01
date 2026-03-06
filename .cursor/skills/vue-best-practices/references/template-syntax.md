# 模板语法规范

## v-if vs v-show

```vue
<!-- ✅ 切换频率低用 v-if -->
<Dialog v-if="visible" />

<!-- ✅ 切换频率高用 v-show -->
<Tooltip v-show="showTip" />

<!-- ❌ 避免：v-if 和 v-for 同时使用 -->
<li v-for="item in items" v-if="item.active">
  {{ item.name }}
</li>

<!-- ✅ 使用计算属性过滤 -->
<li v-for="item in activeItems" :key="item.id">
  {{ item.name }}
</li>
```

## v-for 必须使用 key

```vue
<!-- ✅ 使用唯一 id 作为 key -->
<li v-for="item in items" :key="item.id">
  {{ item.name }}
</li>

<!-- ❌ 不要使用 index 作为 key（除非列表不会变化） -->
<li v-for="(item, index) in items" :key="index">
  {{ item.name }}
</li>

<!-- ❌ 不要省略 key -->
<li v-for="item in items">
  {{ item.name }}
</li>
```

## 事件绑定

```vue
<!-- ✅ 无参数直接传方法引用 -->
<button @click="handleClick">点击</button>

<!-- ✅ 需要传参时使用箭头函数 -->
<button @click="() => handleClick(item.id)">点击</button>

<!-- ✅ 需要 event 对象 -->
<input @input="e => handleInput(e, item.id)" />

<!-- ❌ 避免：在模板中写复杂逻辑 -->
<button
  @click="
    count++;
    validate();
    submit();
  "
>提交</button>
```

## 属性绑定

```vue
<!-- ✅ 动态属性使用 v-bind -->
<img :src="imageUrl" :alt="imageAlt" />

<!-- ✅ 布尔属性 -->
<button :disabled="isLoading">提交</button>

<!-- ✅ 多个属性使用对象展开 -->
<input v-bind="inputAttrs" />

<!-- ❌ 避免：在模板中拼接字符串 -->
<div :class="'prefix-' + status + '-suffix'"></div>

<!-- ✅ 使用计算属性或对象语法 -->
<div :class="statusClass"></div>
<div :class="{ active: isActive, disabled: isDisabled }"></div>
```

## 插槽

```vue
<!-- ✅ 具名插槽 -->
<template #header>
  <h1>标题</h1>
</template>

<!-- ✅ 作用域插槽 -->
<template #item="{ item, index }">
  <li>{{ index }}: {{ item.name }}</li>
</template>

<!-- ❌ 过时语法 -->
<template slot="header">
  <h1>标题</h1>
</template>
```

## 模板引用

```vue
<template>
  <input ref="inputRef" />
</template>

<script setup lang="ts">
// ✅ 类型化的模板引用
const inputRef = ref<HTMLInputElement | null>(null);

onMounted(() => {
  inputRef.value?.focus();
});
</script>
```

## 条件渲染优化

```vue
<!-- ✅ 使用 template 包裹多个元素 -->
<template v-if="condition">
  <header>头部</header>
  <main>内容</main>
  <footer>底部</footer>
</template>

<!-- ❌ 避免：重复的条件判断 -->
<header v-if="condition">头部</header>
<main v-if="condition">内容</main>
<footer v-if="condition">底部</footer>
```
