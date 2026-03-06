# 设计 Token 完整参考

## CSS 变量定义

所有设计 Token 通过 CSS 变量在 `src/styles/cssVar.less` 中定义。

### 基础色值

```css
--ug-black: 0, 0, 0;
--ug-white: 255, 255, 255;
--ug-blue: 0, 123, 255;
--ug-green: 36, 179, 60;
```

### 文本色

| CSS 变量      | Tailwind 类   | 值               | 用途          |
| ------------- | ------------- | ---------------- | ------------- |
| `--ug-text-1` | `text-text-1` | rgba(0,0,0,0.9)  | 正文主要文字  |
| `--ug-text-2` | `text-text-2` | rgba(0,0,0,0.6)  | 次级强调/标题 |
| `--ug-text-3` | `text-text-3` | rgba(0,0,0,0.4)  | 次要信息      |
| `--ug-text-4` | `text-text-4` | rgba(0,0,0,0.25) | 置灰/禁用     |

### 品牌色 (Primary)

| CSS 变量         | Tailwind 类    | 值                   | 用途       |
| ---------------- | -------------- | -------------------- | ---------- |
| `--ug-primary-1` | `bg-primary-1` | rgba(0,123,255,0.05) | 浅蓝背景   |
| `--ug-primary-2` | `bg-primary-2` | rgba(0,123,255,0.08) | 一般蓝背景 |
| `--ug-primary-3` | `bg-primary-3` | rgba(0,123,255,0.15) | 深蓝背景   |
| `--ug-primary-4` | `bg-primary-4` | rgba(0,123,255,0.25) | 一般禁用   |
| `--ug-primary-5` | `bg-primary-5` | #268fff              | 悬浮态     |
| `--ug-primary-6` | `bg-primary-6` | #007bff              | 常规态     |
| `--ug-primary-7` | `bg-primary-7` | #006fe5              | 点击态     |

### 错误色 (Danger)

| CSS 变量        | Tailwind 类   | 值      | 用途     |
| --------------- | ------------- | ------- | -------- |
| `--ug-danger-1` | `bg-danger-1` | #ffefe8 | 白色悬浮 |
| `--ug-danger-2` | `bg-danger-2` | #fbcebe | 文字禁用 |
| `--ug-danger-3` | `bg-danger-3` | #f7ac96 | 一般禁用 |
| `--ug-danger-4` | `bg-danger-4` | #fbcebe | 特殊场景 |
| `--ug-danger-5` | `bg-danger-5` | #f76560 | 悬浮态   |
| `--ug-danger-6` | `bg-danger-6` | #ea3f24 | 常规态   |
| `--ug-danger-7` | `bg-danger-7` | #c32816 | 点击态   |

### 警告色 (Warning)

| CSS 变量         | Tailwind 类    | 值      | 用途     |
| ---------------- | -------------- | ------- | -------- |
| `--ug-warning-1` | `bg-warning-1` | #fff7e8 | 白色悬浮 |
| `--ug-warning-2` | `bg-warning-2` | #ffecc0 | 文字禁用 |
| `--ug-warning-3` | `bg-warning-3` | #fdde96 | 一般禁用 |
| `--ug-warning-4` | `bg-warning-4` | #fdde96 | 特殊场景 |
| `--ug-warning-5` | `bg-warning-5` | #fbb946 | 悬浮态   |
| `--ug-warning-6` | `bg-warning-6` | #faa21e | 常规态   |
| `--ug-warning-7` | `bg-warning-7` | #fb8a10 | 点击态   |

### 成功色 (Success)

| CSS 变量         | Tailwind 类    | 值      | 用途     |
| ---------------- | -------------- | ------- | -------- |
| `--ug-success-1` | `bg-success-1` | #e8ffe8 | 白色悬浮 |
| `--ug-success-2` | `bg-success-2` | #aff0b5 | 文字禁用 |
| `--ug-success-3` | `bg-success-3` | #8de192 | 一般禁用 |
| `--ug-success-4` | `bg-success-4` | #4cd263 | 特殊场景 |
| `--ug-success-5` | `bg-success-5` | #43c254 | 悬浮态   |
| `--ug-success-6` | `bg-success-6` | #24b33c | 常规态   |
| `--ug-success-7` | `bg-success-7` | #179931 | 点击态   |

### 背景色 (Background)

| CSS 变量    | Tailwind 类 | 值                     | 用途         |
| ----------- | ----------- | ---------------------- | ------------ |
| `--ug-bg-1` | `bg-bg-1`   | rgba(255,255,255,0.8)  | 桌面小窗背景 |
| `--ug-bg-2` | `bg-bg-2`   | rgba(255,255,255,0.95) | 应用窗口背景 |
| `--ug-bg-3` | `bg-bg-3`   | rgba(255,255,255,0.7)  | 侧边栏背景   |
| `--ug-bg-4` | `bg-bg-4`   | #ffffff                | 一级容器     |
| `--ug-bg-5` | `bg-bg-5`   | #ffffff                | 二级容器     |
| `--ug-bg-6` | `bg-bg-6`   | #ffffff                | 三级容器     |
| `--ug-bg-7` | `bg-bg-7`   | #ffffff                | 下拉弹框     |

### 填充色 (Fill)

| CSS 变量      | Tailwind 类 | 值               | 用途       |
| ------------- | ----------- | ---------------- | ---------- |
| `--ug-fill-1` | `bg-fill-1` | rgba(0,0,0,0.02) | 浅色填充   |
| `--ug-fill-2` | `bg-fill-2` | rgba(0,0,0,0.03) | 浅色悬浮   |
| `--ug-fill-3` | `bg-fill-3` | rgba(0,0,0,0.05) | 白底悬浮   |
| `--ug-fill-4` | `bg-fill-4` | rgba(0,0,0,0.08) | 深色悬浮   |
| `--ug-fill-5` | `bg-fill-5` | #c9cdd4          | 开关未开启 |
| `--ug-fill-6` | `bg-fill-6` | rgba(0,0,0,0.1)  | 滚动条默认 |
| `--ug-fill-7` | `bg-fill-7` | rgba(0,0,0,0.25) | 滚动条悬停 |
| `--ug-fill-8` | `bg-fill-8` | #202735          | 气泡背景   |

### 边框色 (Border)

| CSS 变量        | Tailwind 类       | 值                   | 用途     |
| --------------- | ----------------- | -------------------- | -------- |
| `--ug-border-1` | `border-border-1` | rgba(0,0,0,0.05)     | 浅色边框 |
| `--ug-border-2` | `border-border-2` | rgba(0,0,0,0.1)      | 深色边框 |
| `--ug-border-3` | `border-border-3` | rgba(0,123,255,0.3)  | 浅蓝边框 |
| `--ug-border-4` | `border-border-4` | rgba(0,123,255,0.65) | 中蓝边框 |

### 阴影 (Shadow)

**黑色阴影**

| CSS 变量                | Tailwind 类        | 值                          | 用途       |
| ----------------------- | ------------------ | --------------------------- | ---------- |
| `--ug-shadow-black-sm`  | `shadow-black-sm`  | 0 0 30px rgba(0,0,0,0.05)   | Toast 提示 |
| `--ug-shadow-black-md`  | `shadow-black-md`  | 0 0 30px rgba(0,0,0,0.1)    | 菜单栏     |
| `--ug-shadow-black-lg`  | `shadow-black-lg`  | 0 4px 16px rgba(0,0,0,0.1)  | 桌面小窗   |
| `--ug-shadow-black-xl`  | `shadow-black-xl`  | 0 4px 16px rgba(0,0,0,0.05) | 超大投影   |
| `--ug-shadow-black-2xl` | `shadow-black-2xl` | 0 4px 16px rgba(0,0,0,0.08) | 加强投影   |

**蓝色阴影**

| CSS 变量              | Tailwind 类      | 值                            | 用途        |
| --------------------- | ---------------- | ----------------------------- | ----------- |
| `--ug-shadow-blue-sm` | `shadow-blue-sm` | 0 0 20px rgba(0,123,255,0.05) | 全屏对话框  |
| `--ug-shadow-blue-md` | `shadow-blue-md` | 0 0 20px rgba(0,123,255,0.08) | 悬浮按钮    |
| `--ug-shadow-blue-lg` | `shadow-blue-lg` | 0 0 30px rgba(0,123,255,0.1)  | AI 按钮悬浮 |

## Tailwind 配置扩展

### 字体大小 (fontSize)

```javascript
fontSize: {
  xxs: ['10px', { lineHeight: '18px' }],
  xs: ['12px', { lineHeight: '20px' }],
  sm: ['14px', { lineHeight: '22px' }],
  base: ['16px', { lineHeight: '24px' }],
  lg: ['18px', { lineHeight: '26px' }],
  xl: ['20px', { lineHeight: '28px' }],
  '2xl': ['24px', { lineHeight: '32px' }],
  '3xl': ['36px', { lineHeight: '44px' }],
  '4xl': ['48px', { lineHeight: '56px' }],
  '5xl': ['56px', { lineHeight: '64px' }],
}
```

### 间距 (spacing)

```javascript
spacing: {
  0.5: '2px',
  1: '4px',
  1.5: '6px',
  2: '8px',
  2.5: '10px',
  3: '12px',
  3.5: '14px',
  4: '16px',
  5: '20px',
  6: '24px',
  7: '28px',
  8: '32px',
  9: '36px',
  10: '40px',
  11: '44px',
  12: '48px',
  14: '56px',
  16: '64px',
}
```

### 圆角 (borderRadius)

```javascript
borderRadius: {
  xs: '2px',
  sm: '4px',
  md: '6px',
  lg: '8px',
  xl: '10px',
  '2xl': '12px',
  '3xl': '16px',
}
```

### 动画 (animation)

```javascript
animation: {
  'loader-in': 'loader-in 0.16s linear forwards',
  'fade-in': 'fade-in 0.16s linear forwards',
  'fade-out': 'fade-out 0.08s linear forwards',
}
```

## 相关文件

- CSS 变量定义：`src/styles/cssVar.less`
- Tailwind 共享配置：`tailwind.shared.config.js`
- Tailwind 主配置：`tailwind.config.js`
