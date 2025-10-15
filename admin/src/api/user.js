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
    throw error
  }
}

// 获取用户列表
export function getUserList(params) {
  const queryString = new URLSearchParams(params).toString()
  return callServerAPI(`/api/user/list?${queryString}`)
}

// 创建用户
export function createUser(data) {
  return callServerAPI('/api/user/create', {
    method: 'POST',
    body: JSON.stringify(data)
  })
}

// 更新用户
export function updateUser(id, data) {
  return callServerAPI(`/api/user/${id}`, {
    method: 'PUT',
    body: JSON.stringify(data)
  })
}

// 删除用户
export function deleteUser(id) {
  return callServerAPI(`/api/user/${id}`, {
    method: 'DELETE'
  })
}

// 重置用户密码
export function resetUserPassword(id, password) {
  return callServerAPI(`/api/user/${id}/reset-password`, {
    method: 'POST',
    body: JSON.stringify({ password })
  })
}
