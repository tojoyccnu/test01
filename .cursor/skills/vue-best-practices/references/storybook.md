# Storybook

项目使用 [Storybook](https://storybook.js.org/) 作为组件文档和开发环境。

## 启动 Storybook

```bash
pnpm storybook
```

访问 http://localhost:6006 查看组件文档。

## 编写 Story

Story 文件放置在组件同目录下，命名格式为 `组件名.stories.ts`：

```
src/components/
└── empty/
    ├── Empty.vue           # 组件文件
    ├── empty.stories.ts    # Story 文件
    └── index.ts            # 导出文件
```

## Story 示例

```typescript
import type { Meta, StoryObj } from '@storybook/vue3';

import Empty from './Empty.vue';

const meta: Meta<typeof Empty> = {
  title: 'Components/Empty',
  component: Empty,
  tags: ['autodocs'],
};

export default meta;
type Story = StoryObj<typeof Empty>;

export const Default: Story = {};

export const WithCustomText: Story = {
  args: {
    description: '自定义描述文本',
  },
};
```

## 何时编写 Story

| 需要编写                 | 无需编写                     |
| ------------------------ | ---------------------------- |
| 可复用的 UI 组件         | 页面级组件（views/）         |
| 有多种状态/变体的组件    | 布局组件                     |
| 需要独立展示和测试的组件 | 仅在特定上下文使用的业务组件 |
