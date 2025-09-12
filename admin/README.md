# 刷题小程序后台管理系统

## 项目简介

这是刷题小程序的Web端后台管理系统，基于Vue3 + Element Plus开发，提供题库管理、用户管理、数据统计等功能。

## 技术栈

- **前端框架**: Vue 3 (Composition API)
- **UI组件库**: Element Plus
- **路由管理**: Vue Router 4
- **图表库**: ECharts
- **构建工具**: Vite
- **HTTP客户端**: Axios

## 功能模块

- **仪表盘**: 数据统计、快捷入口、公告栏、趋势图表
- **用户管理**: 用户列表、搜索、编辑、禁用等
- **题库管理**: 题目分类、增删改查、批量导入导出、审核
- **数据统计**: 活跃度、刷题量、错题率等数据报表
- **权限管理**: 管理员列表、角色分配、权限分配
- **系统设置**: 公告发布、活动配置、基础设置

## 快速开始

### 安装依赖

```bash
npm install
```

### 启动开发服务器

```bash
npm run dev
```

### 构建生产版本

```bash
npm run build
```

### 预览生产版本

```bash
npm run preview
```

## 登录信息

- **用户名**: admin
- **密码**: 123456

## 项目结构

```
admin/
├── src/
│   ├── components/     # 公共组件
│   │   └── Layout.vue  # 主布局组件
│   ├── views/          # 页面组件
│   │   ├── Dashboard.vue    # 仪表盘
│   │   ├── Login.vue        # 登录页
│   │   ├── Users.vue        # 用户管理
│   │   ├── Questions.vue    # 题库管理
│   │   ├── Statistics.vue   # 数据统计
│   │   ├── Permissions.vue  # 权限管理
│   │   └── Settings.vue     # 系统设置
│   ├── router/         # 路由配置
│   ├── api/            # API接口
│   ├── utils/          # 工具函数
│   ├── assets/         # 静态资源
│   ├── App.vue         # 根组件
│   └── main.js         # 入口文件
├── public/             # 公共资源
├── index.html          # HTML入口
├── vite.config.js      # Vite配置
├── package.json        # 依赖配置
└── README.md           # 项目说明
```

## 开发说明

1. 项目使用Vue3 Composition API开发
2. 使用Element Plus作为UI组件库
3. 使用ECharts进行数据可视化
4. 支持响应式设计，适配移动端
5. 使用Vite作为构建工具，提供快速的开发体验

## 注意事项

- 当前版本为开发版本，部分功能页面为占位组件
- 登录功能为模拟实现，实际项目中需要对接后端API
- 数据统计图表使用模拟数据，实际项目中需要对接真实数据 