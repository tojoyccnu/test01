---
name: design-token
description: 包含 Tailwind CSS 设计系统、颜色、间距、字体、圆角、阴影等 Token 参考。
---

# 设计系统 tokens 查询指南

## 快速参考

### 文字颜色

| 类名          | 用途          | 透明度 |
| ------------- | ------------- | ------ |
| `text-text-1` | 主要正文      | 90% 黑 |
| `text-text-2` | 次级强调/标题 | 60% 黑 |
| `text-text-3` | 次要信息      | 40% 黑 |
| `text-text-4` | 置灰/禁用     | 25% 黑 |

### 品牌色 (primary)

| 类名           | 用途             |
| -------------- | ---------------- |
| `bg-primary-1` | 浅蓝背景 (5%)    |
| `bg-primary-2` | 一般蓝背景 (8%)  |
| `bg-primary-3` | 深蓝背景 (15%)   |
| `bg-primary-4` | 禁用状态 (25%)   |
| `bg-primary-5` | 悬浮态 `hover:`  |
| `bg-primary-6` | 常规/默认态      |
| `bg-primary-7` | 点击态 `active:` |

### 语义色

```html
<!-- 成功 -->
<div class="bg-success-6/10 text-success-6">成功</div>

<!-- 警告 -->
<div class="bg-warning-6/10 text-warning-6">警告</div>

<!-- 错误 -->
<div class="bg-danger-6/10 text-danger-6">错误</div>
```

### 背景色层级

| 类名                  | 场景              |
| --------------------- | ----------------- |
| `bg-bg-1`             | 桌面小窗 (80% 白) |
| `bg-bg-2`             | 应用窗口 (95% 白) |
| `bg-bg-3`             | 侧边栏 (70% 白)   |
| `bg-bg-4` ~ `bg-bg-6` | 容器层级 (纯白)   |
| `bg-bg-7`             | 下拉弹框          |

### 填充色（交互状态）

| 类名              | 用途          |
| ----------------- | ------------- |
| `bg-fill-1`       | 浅色填充 (2%) |
| `hover:bg-fill-2` | 浅色悬浮 (3%) |
| `hover:bg-fill-3` | 白底悬浮 (5%) |
| `bg-fill-4`       | 深色悬浮 (8%) |

### 字体大小

| 类名        | 尺寸/行高 | 场景     |
| ----------- | --------- | -------- |
| `text-xxs`  | 10px/18px | 超小字   |
| `text-xs`   | 12px/20px | 辅助文字 |
| `text-sm`   | 14px/22px | 正文     |
| `text-base` | 16px/24px | 主要文字 |
| `text-lg`   | 18px/26px | 小标题   |
| `text-xl`   | 20px/28px | 标题     |
| `text-2xl`  | 24px/32px | 大标题   |

### 间距系统

| 值  | 像素 | 示例            |
| --- | ---- | --------------- |
| 0.5 | 2px  | `p-0.5` `m-0.5` |
| 1   | 4px  | `p-1` `gap-1`   |
| 1.5 | 6px  | `p-1.5`         |
| 2   | 8px  | `p-2` `m-2`     |
| 3   | 12px | `p-3` `gap-3`   |
| 4   | 16px | `p-4` `m-4`     |
| 6   | 24px | `p-6`           |
| 8   | 32px | `p-8`           |

### 圆角

| 类名          | 像素 | 场景      |
| ------------- | ---- | --------- |
| `rounded-xs`  | 2px  | 细节元素  |
| `rounded-sm`  | 4px  | 小按钮    |
| `rounded-md`  | 6px  | 输入框    |
| `rounded-lg`  | 8px  | 按钮/卡片 |
| `rounded-xl`  | 10px | 大卡片    |
| `rounded-2xl` | 12px | 模态框    |
| `rounded-3xl` | 16px | 大型容器  |

### 阴影

```html
<!-- 黑色阴影 -->
<div class="shadow-black-sm">Toast 提示</div>
<div class="shadow-black-md">菜单栏/悬浮图标</div>
<div class="shadow-black-lg">桌面对话小窗</div>

<!-- 蓝色阴影（品牌相关） -->
<div class="shadow-blue-sm">全屏对话框</div>
<div class="shadow-blue-md">悬浮按钮/卡片悬浮</div>
<div class="shadow-blue-lg">AI 技能按钮悬浮</div>
```

### 边框

| 类名              | 用途                |
| ----------------- | ------------------- |
| `border-border-1` | 浅色分割线 (5% 黑)  |
| `border-border-2` | 深色分割线 (10% 黑) |
| `border-border-3` | 浅蓝边框 (30% 蓝)   |
| `border-border-4` | 中蓝边框 (65% 蓝)   |

### 动画

```html
<div class="animate-loader-in">加载进入（旋转缩放 0.16s）</div>
<div class="animate-fade-in">淡入（0.16s）</div>
<div class="animate-fade-out">淡出（0.08s）</div>

<!-- tailwindcss-animated 插件 -->
<div class="animate-bounce">弹跳</div>
<div class="animate-pulse">脉冲</div>
```

## 完整 Token 参考

详细设计 Token 定义见 [references/design-tokens.md](references/design-tokens.md)，在需要查找完整 Token 列表时加载
