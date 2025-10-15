// 获取服务器URL - 使用相对路径通过nginx代理
const getServerUrl = () => {
  // 在生产环境中使用相对路径，让nginx代理处理API请求
  if (import.meta.env.PROD) {
    return ''; // 使用相对路径，nginx会代理到主域名
  }
  // 开发环境使用完整URL
  return import.meta.env.VITE_SERVER_URL || 'https://practice.insightdata.top'
}

// 激活码管理API
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

export const activationCodeAPI = {
  // 创建激活码
  createActivationCode: (data) => {
    return callServerAPI('/api/activation-code', {
      method: 'POST',
      body: JSON.stringify(data)
    })
  },

  // 获取激活码列表
  getActivationCodes: (params = {}) => {
    const queryString = new URLSearchParams(params).toString()
    return callServerAPI(`/api/activation-code?${queryString}`)
  },

  // 获取激活码详情
  getActivationCodeDetail: (id) => {
    return callServerAPI(`/api/activation-code/${id}`)
  },

  // 更新激活码
  updateActivationCode: (id, data) => {
    return callServerAPI(`/api/activation-code/${id}`, {
      method: 'PUT',
      body: JSON.stringify(data)
    })
  },

  // 删除激活码
  deleteActivationCode: (id) => {
    return callServerAPI(`/api/activation-code/${id}`, {
      method: 'DELETE'
    })
  },

  // 验证激活码（小程序端使用）
  verifyActivationCode: (code) => {
    return callServerAPI('/api/activation-code/verify', {
      method: 'POST',
      body: JSON.stringify({ code })
    })
  },

  // 获取用户已激活的科目（小程序端使用）
  getUserActivatedSubjects: () => {
    return callServerAPI('/api/activation-code/user/subjects')
  }
}
