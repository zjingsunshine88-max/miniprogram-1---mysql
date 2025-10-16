import { createRouter, createWebHistory } from 'vue-router'
import Layout from '@/components/Layout.vue'

const routes = [
  {
    path: '/',
    redirect: '/dashboard'
  },
  {
    path: '/login',
    name: 'Login',
    component: () => import('@/views/Login.vue'),
    meta: { title: '登录' }
  },
  {
    path: '/',
    component: Layout,
    children: [
      {
        path: 'dashboard',
        name: 'Dashboard',
        component: () => import('@/views/Dashboard.vue'),
        meta: { title: '仪表盘' }
      },
      {
        path: 'users',
        name: 'Users',
        component: () => import('@/views/Users.vue'),
        meta: { title: '用户管理' }
      },
      {
        path: 'question-bank-management',
        name: 'QuestionBankManagement',
        component: () => import('@/views/QuestionBankManagement.vue'),
        meta: { title: '题库管理' }
      },
      {
        path: 'smart-question-import',
        name: 'SmartQuestionImport',
        component: () => import('@/views/SmartQuestionImport.vue'),
        meta: { title: '智能题目上传' }
      },
      {
        path: 'activation-code-management',
        name: 'ActivationCodeManagement',
        component: () => import('@/views/ActivationCodeManagement.vue'),
        meta: { title: '激活码管理' }
      },
      {
        path: 'statistics',
        name: 'Statistics',
        component: () => import('@/views/Statistics.vue'),
        meta: { title: '数据统计' }
      },
      {
        path: 'permissions',
        name: 'Permissions',
        component: () => import('@/views/Permissions.vue'),
        meta: { title: '权限管理' }
      },
      {
        path: 'settings',
        name: 'Settings',
        component: () => import('@/views/Settings.vue'),
        meta: { title: '系统设置' }
      }
    ]
  }
]

const router = createRouter({
  history: createWebHistory(),
  routes
})

// 路由守卫
router.beforeEach((to, from, next) => {
  // 设置页面标题
  if (to.meta.title) {
    document.title = `${to.meta.title} - 刷题小程序管理系统`
  }
  
  // 检查登录状态
  const token = localStorage.getItem('token')
  
  if (to.path === '/login') {
    next()
  } else if (!token && to.path !== '/login') {
    next('/login')
  } else {
    next()
  }
})

export default router 