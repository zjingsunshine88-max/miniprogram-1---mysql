// 获取服务器URL - 使用相对路径通过nginx代理
const getServerUrl = () => {
  // 在生产环境中使用相对路径，让nginx代理处理API请求
  if (import.meta.env.PROD) {
    return ''; // 使用相对路径，nginx会代理到主域名
  }
  // 开发环境使用完整URL
  return import.meta.env.VITE_SERVER_URL || 'https://practice.insightdata.top'
}

// 科目管理API
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

export const subjectAPI = {
  // 获取科目列表
  getSubjects: (params = {}) => {
    const queryString = new URLSearchParams(params).toString()
    return callServerAPI(`/api/subject?${queryString}`)
  },

  // 创建科目
  createSubject: (data) => {
    return callServerAPI('/api/subject', {
      method: 'POST',
      body: JSON.stringify(data)
    })
  },

  // 获取科目详情
  getSubjectDetail: (id) => {
    return callServerAPI(`/api/subject/${id}`)
  },

  // 更新科目
  updateSubject: (id, data) => {
    return callServerAPI(`/api/subject/${id}`, {
      method: 'PUT',
      body: JSON.stringify(data)
    })
  },

  // 删除科目
  deleteSubject: (id) => {
    return callServerAPI(`/api/subject/${id}`, {
      method: 'DELETE'
    })
  }
}
