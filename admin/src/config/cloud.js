// 云函数配置
export const cloudConfig = {
  // 云开发环境ID
  envId: import.meta.env.VITE_CLOUD_ENV_ID || 'cloudbase-5guq06yfe657e091',
  
  // 云函数HTTP触发器URL
  functionUrl: import.meta.env.VITE_CLOUD_FUNCTION_URL || 'https://cloudbase-5guq06yfe657e091.service.tcloudbase.com/question-bank-api',
  
  // API超时时间（毫秒）
  timeout: 30000,
  
  // 是否启用调试模式
  debug: import.meta.env.DEV
}

// 获取云函数URL
export const getCloudFunctionUrl = () => {
  return cloudConfig.functionUrl
}

// 获取环境ID
export const getEnvId = () => {
  return cloudConfig.envId
}

// 获取调试模式
export const isDebugMode = () => {
  return cloudConfig.debug
}
