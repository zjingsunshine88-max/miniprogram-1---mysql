// 获取token
const getToken = () => {
  return localStorage.getItem('token')
}

// 服务器API基础URL - 使用相对路径通过nginx代理
const getServerUrl = () => {
  // 在生产环境中使用相对路径，让nginx代理处理API请求
  if (import.meta.env.PROD) {
    return ''; // 使用相对路径，nginx会代理到主域名
  }
  // 开发环境使用完整URL
  return import.meta.env.VITE_SERVER_URL || 'https://practice.insightdata.top'
}

// 调用服务器API
const callServerAPI = async (endpoint, options = {}) => {
  const token = getToken()
  
  try {
    const response = await fetch(`${getServerUrl()}${endpoint}`, {
      method: options.method || 'GET',
      headers: {
        'Content-Type': 'application/json',
        'X-Requested-With': 'XMLHttpRequest',
        ...(token && { 'Authorization': `Bearer ${token}` }),
        ...options.headers
      },
      credentials: 'include',
      ...options
    })

    // 检查响应状态
    if (!response.ok) {
      const errorData = await response.json().catch(() => ({}))
      throw new Error(errorData.message || `HTTP ${response.status}: ${response.statusText}`)
    }

    const data = await response.json()
    
    // 检查业务逻辑错误
    if (data.code && data.code !== 200) {
      throw new Error(data.message || '请求失败')
    }
    
    return data
  } catch (error) {
    console.error('服务器API调用失败:', error)
    
    // 如果是CORS错误，提供更友好的错误信息
    if (error.message.includes('CORS') || error.message.includes('blocked')) {
      throw new Error('跨域请求被阻止，请检查服务器CORS配置')
    }
    
    throw error
  }
}

// 题目相关API
export const questionAPI = {
  // 获取题目列表
  getList: (params = {}) => {
    const queryString = new URLSearchParams(params).toString()
    return callServerAPI(`/api/question/list?${queryString}`)
  },

  // 获取题目详情
  getDetail: (id) => {
    return callServerAPI(`/api/question/detail/${id}`)
  },

  // 随机获取题目
  getRandom: (params = {}) => {
    const queryString = new URLSearchParams(params).toString()
    return callServerAPI(`/api/question/random?${queryString}`)
  },

  // 批量导入题目
  importQuestions: (questions) => {
    return callServerAPI('/api/question/import', {
      method: 'POST',
      body: JSON.stringify({ questions })
    })
  },

  // 获取题目统计
  getStats: () => {
    return callServerAPI('/api/question/stats')
  }
}

// 用户相关API
export const userAPI = {
  // 用户登录
  login: (credentials) => {
    return callServerAPI('/api/user/login', {
      method: 'POST',
      body: JSON.stringify(credentials)
    })
  },

  // 获取用户信息
  getUserInfo: () => {
    return callServerAPI('/api/user/info')
  }
}

export default {
  question: questionAPI,
  user: userAPI
}
