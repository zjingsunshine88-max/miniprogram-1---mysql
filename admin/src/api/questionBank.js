// 获取服务器URL - 使用相对路径通过nginx代理
const getServerUrl = () => {
  // 在生产环境中使用相对路径，让nginx代理处理API请求
  if (import.meta.env.PROD) {
    return ''; // 使用相对路径，nginx会代理到主域名
  }
  // 开发环境使用完整URL
  return import.meta.env.VITE_SERVER_URL || 'https://practice.insightdata.top'
}

// 题库管理API
const callServerAPI = async (endpoint, options = {}) => {
  const token = localStorage.getItem('token')
  
  const config = {
    method: options.method || 'GET',
    headers: {
      'Content-Type': 'application/json',
      ...(token && { 'Authorization': `Bearer ${token}` })
    },
    credentials: 'include',
    ...options
  }

  try {
    const response = await fetch(`${getServerUrl()}${endpoint}`, config)
    const data = await response.json()
    
    if (!response.ok) {
      throw new Error(data.message || `HTTP ${response.status}`)
    }
    
    return data
  } catch (error) {
    console.error('服务器API调用失败:', error)
    throw error
  }
}

export const questionBankAPI = {
  // 获取题库列表
  getQuestionBanks: (params = {}) => {
    const queryString = new URLSearchParams(params).toString()
    return callServerAPI(`/api/question-bank?${queryString}`)
  },

  // 创建题库
  createQuestionBank: (data) => {
    return callServerAPI('/api/question-bank', {
      method: 'POST',
      body: JSON.stringify(data)
    })
  },

  // 获取题库详情
  getQuestionBankDetail: (id) => {
    return callServerAPI(`/api/question-bank/${id}`)
  },

  // 更新题库
  updateQuestionBank: (id, data) => {
    return callServerAPI(`/api/question-bank/${id}`, {
      method: 'PUT',
      body: JSON.stringify(data)
    })
  },

  // 删除题库
  deleteQuestionBank: (id) => {
    return callServerAPI(`/api/question-bank/${id}`, {
      method: 'DELETE'
    })
  }
}
