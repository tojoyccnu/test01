---
name: vue-best-practices (Vue3 + Typescript项目最佳实践)
description: Vue3 + TypeScript 项目业务开发最佳实践指南。适用场景：创建/修改 Vue 组件, 编写 Composables, 使用响应式 API, Pinia 状态管理, TanStack Query 数据请求, 错误处理, 模板语法, TypeScript 类型, 组件样式, Storybook 文档
metadata:
  author: yangjie@ugreen
  version: '1.0.0'
---

# Vue 最佳实践

根据任务类型阅读对应规范文件：

| 规范文件                                                    | 适用场景                                                        |
| ----------------------------------------------------------- | --------------------------------------------------------------- |
| [component-structure.md](references/component-structure.md) | 创建新组件、定义 Props/Emits/Slots、组织 SFC 代码结构           |
| [composables.md](references/composables.md)                 | 创建 use 开头的 Composable、抽取可复用逻辑、设计返回值结构      |
| [function-design.md](references/function-design.md)         | 设计函数参数、定义返回值类型                                    |
| [reactivity.md](references/reactivity.md)                   | 使用 ref/reactive/computed/watch、响应式数据的解构和传递        |
| [state-management.md](references/state-management.md)       | 创建 Pinia Store、跨组件状态共享、实现 reset 方法               |
| [data-fetching.md](references/data-fetching.md)             | 使用 useQuery/useMutation、配置缓存策略、处理加载和错误状态     |
| [error-handling.md](references/error-handling.md)           | try/catch 异常捕获、用户友好的错误提示、API 错误处理            |
| [template-syntax.md](references/template-syntax.md)         | v-if/v-for/v-model 指令、属性绑定、插槽使用、事件处理           |
| [typescript.md](references/typescript.md)                   | 定义 interface/type、类型守卫、Vue 组件类型（PropType、Ref 等） |
| [script-setup-jsdoc.md](references/script-setup-jsdoc.md)   | 为 Props 添加 JSDoc 注释、组件文档化                            |
| [vue-styling.md](references/vue-styling.md)                 | scoped 样式、动态类名（computed）、CSS 变量、样式变体管理       |
| [i18n-usage.md](references/i18n-usage.md)                   | 模板中使用 $t()、脚本中使用 i18n.t()、带参数的翻译文本          |
| [file-based-routing.md](references/file-based-routing.md)   | 创建新页面路由、配置路由 meta、动态路由参数、嵌套路由           |
| [storybook.md](references/storybook.md)                     | 为可复用 UI 组件编写 Story、组件多状态/变体展示、组件文档化     |
