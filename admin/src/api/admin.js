// 获取token
const getToken = () => {
  return localStorage.getItem('token')
}

// 服务器API基础URL
const getServerUrl = () => {
  return import.meta.env.VITE_SERVER_URL || 'http://localhost:3002'
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

    // 如果是blob响应，直接返回
    if (options.responseType === 'blob') {
      return response.blob()
    }

    const data = await response.json()
    
    // 检查业务逻辑错误
    if (data.code && data.code !== 200) {
      throw new Error(data.message || '请求失败')
    }
    
    return data
  } catch (error) {
    console.error('服务器API调用失败:', error)
    throw error
  }
}

// 管理员相关API
export const adminAPI = {
  // 管理员登录
  login: (credentials) => {
    return callServerAPI('/api/user/admin-login', {
      method: 'POST',
      body: JSON.stringify(credentials)
    })
  },

  // 获取统计数据
  getStats: () => {
    return callServerAPI('/api/admin/stats')
  },

  // 获取用户列表
  getUsers: (params = {}) => {
    const queryString = new URLSearchParams(params).toString()
    return callServerAPI(`/api/user/stats?${queryString}`)
  },

  // 获取题目列表
  getQuestions: (params = {}) => {
    const queryString = new URLSearchParams(params).toString()
    return callServerAPI(`/api/question/list?${queryString}`)
  },

  // 添加题目
  addQuestion: (question) => {
    return callServerAPI('/api/question/import', {
      method: 'POST',
      body: JSON.stringify({ questions: [question] })
    })
  },

  // 更新题目
  updateQuestion: (id, question) => {
    return callServerAPI(`/api/question/detail/${id}`, {
      method: 'PUT',
      body: JSON.stringify(question)
    })
  },

  // 删除题目
  deleteQuestion: (id) => {
    return callServerAPI(`/api/question/detail/${id}`, {
      method: 'DELETE'
    })
  },

  // 批量删除题目
  batchDeleteQuestions: (questionIds) => {
    return callServerAPI('/api/question/batch-delete', {
      method: 'POST',
      body: JSON.stringify({ questionIds })
    })
  },

  // 批量导入题目
  importQuestions: (questions) => {
    return callServerAPI('/api/question/import', {
      method: 'POST',
      body: JSON.stringify({ questions })
    })
  },

  // 删除题库
  deleteQuestionBank: (subject) => {
    return callServerAPI('/api/question/delete-bank', {
      method: 'POST',
      body: JSON.stringify({ subject })
    })
  },

  // 导出题库
  exportQuestionBank: (questionBankId, format = 'excel') => {
    return callServerAPI(`/api/question-bank/${questionBankId}/export?format=${format}`, {
      method: 'GET',
      responseType: 'blob'
    })
  }
}

export default adminAPI
