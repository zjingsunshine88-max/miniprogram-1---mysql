@echo off
chcp 65001 >nul
echo ========================================
echo Force Fix API URL Configuration
echo ========================================
echo.

echo [STEP 1] Check current API configuration
echo ========================================
echo [INFO] Checking admin API configuration...

if exist "admin\src\api\admin.js" (
    echo [OK] admin.js exists
    echo [INFO] Current API URL configuration:
    findstr /n "VITE_SERVER_URL\|practice.insightdate.top\|223.93.139.87" "admin\src\api\admin.js"
) else (
    echo [ERROR] admin.js not found
)

echo.
echo [STEP 2] Check environment files
echo ========================================
echo [INFO] Checking environment configuration files...

if exist "admin\.env" (
    echo [OK] .env exists
    echo [INFO] .env content:
    type admin\.env
) else (
    echo [WARNING] .env not found
)

if exist "admin\.env.local" (
    echo [OK] .env.local exists
    echo [INFO] .env.local content:
    type admin\.env.local
) else (
    echo [WARNING] .env.local not found
)

if exist "admin\.env.production" (
    echo [OK] .env.production exists
    echo [INFO] .env.production content:
    type admin\.env.production
) else (
    echo [WARNING] .env.production not found
)

if exist "admin\env.production" (
    echo [OK] env.production exists
    echo [INFO] env.production content:
    type admin\env.production
) else (
    echo [WARNING] env.production not found
)

echo.
echo [STEP 3] Create/Update environment files
echo ========================================
echo [INFO] Creating/updating environment files...

:: Create .env file
(
echo # API Configuration
echo VITE_SERVER_URL=https://practice.insightdate.top
echo VITE_API_BASE_URL=https://practice.insightdate.top/api
echo.
echo # Build Configuration
echo VITE_BUILD_MODE=production
echo VITE_APP_TITLE=刷题小程序后台管理系统
) > "admin\.env"

echo [OK] Created .env file

:: Create .env.production file
(
echo # Production API Configuration
echo VITE_SERVER_URL=https://practice.insightdate.top
echo VITE_API_BASE_URL=https://practice.insightdate.top/api
echo.
echo # Production Build Configuration
echo VITE_BUILD_MODE=production
echo VITE_APP_TITLE=刷题小程序后台管理系统
) > "admin\.env.production"

echo [OK] Created .env.production file

:: Create .env.local file
(
echo # Local API Configuration
echo VITE_SERVER_URL=https://practice.insightdate.top
echo VITE_API_BASE_URL=https://practice.insightdate.top/api
) > "admin\.env.local"

echo [OK] Created .env.local file

echo.
echo [STEP 4] Update API configuration files
echo ========================================
echo [INFO] Updating API configuration files...

:: Update admin.js with hardcoded URL
(
echo // 获取token
echo const getToken = () =^> {
echo   return localStorage.getItem('token'^)
echo }
echo.
echo // 服务器API基础URL - 强制使用新地址
echo const getServerUrl = () =^> {
echo   return 'https://practice.insightdate.top'
echo }
echo.
echo // 调用服务器API
echo const callServerAPI = async (endpoint, options = {}^) =^> {
echo   const token = getToken(^)
echo   
echo   try {
echo     console.log('API调用:', `$%{getServerUrl(^)}$%{endpoint}`^)
echo     const response = await fetch(`$%{getServerUrl(^)}$%{endpoint}`, {
echo       method: options.method || 'GET',
echo       headers: {
echo         'Content-Type': 'application/json',
echo         'X-Requested-With': 'XMLHttpRequest',
echo         ...(token ^&^& { 'Authorization': `Bearer $%{token}` }^),
echo         ...options.headers
echo       },
echo       credentials: 'include',
echo       ...options
echo     }^)
echo.
echo     // 检查响应状态
echo     if (!response.ok^) {
echo       const errorData = await response.json(^).catch(() =^> ({}^)^)
echo       throw new Error(errorData.message || `HTTP $%{response.status}: $%{response.statusText}`^)
echo     }
echo.
echo     // 如果是blob响应，直接返回
echo     if (options.responseType === 'blob'^) {
echo       return response.blob(^)
echo     }
echo.
echo     const data = await response.json(^)
echo     
echo     // 检查业务逻辑错误
echo     if (data.code ^&^& data.code !== 200^) {
echo       throw new Error(data.message || '请求失败'^)
echo     }
echo     
echo     return data
echo   } catch (error^) {
echo     console.error('服务器API调用失败:', error^)
echo     throw error
echo   }
echo }
echo.
echo // 管理员相关API
echo export const adminAPI = {
echo   // 管理员登录
echo   login: (credentials^) =^> {
echo     return callServerAPI('/api/user/admin-login', {
echo       method: 'POST',
echo       body: JSON.stringify(credentials^)
echo     }^)
echo   },
echo.
echo   // 获取统计数据
echo   getStats: (^) =^> {
echo     return callServerAPI('/api/admin/stats'^)
echo   },
echo.
echo   // 获取用户列表
echo   getUsers: (params = {}^) =^> {
echo     const queryString = new URLSearchParams(params^).toString(^)
echo     return callServerAPI(`/api/user/stats?$%{queryString}`^)
echo   },
echo.
echo   // 获取题目列表
echo   getQuestions: (params = {}^) =^> {
echo     const queryString = new URLSearchParams(params^).toString(^)
echo     return callServerAPI(`/api/question/list?$%{queryString}`^)
echo   },
echo.
echo   // 添加题目
echo   addQuestion: (question^) =^> {
echo     return callServerAPI('/api/question/import', {
echo       method: 'POST',
echo       body: JSON.stringify({ questions: [question] }^)
echo     }^)
echo   },
echo.
echo   // 更新题目
echo   updateQuestion: (id, question^) =^> {
echo     return callServerAPI(`/api/question/detail/$%{id}`, {
echo       method: 'PUT',
echo       body: JSON.stringify(question^)
echo     }^)
echo   },
echo.
echo   // 删除题目
echo   deleteQuestion: (id^) =^> {
echo     return callServerAPI(`/api/question/detail/$%{id}`, {
echo       method: 'DELETE'
echo     }^)
echo   },
echo.
echo   // 批量删除题目
echo   batchDeleteQuestions: (questionIds^) =^> {
echo     return callServerAPI('/api/question/batch-delete', {
echo       method: 'POST',
echo       body: JSON.stringify({ questionIds }^)
echo     }^)
echo   },
echo.
echo   // 批量导入题目
echo   importQuestions: (questions^) =^> {
echo     return callServerAPI('/api/question/import', {
echo       method: 'POST',
echo       body: JSON.stringify({ questions }^)
echo     }^)
echo   },
echo.
echo   // 删除题库
echo   deleteQuestionBank: (subject^) =^> {
echo     return callServerAPI('/api/question/delete-bank', {
echo       method: 'POST',
echo       body: JSON.stringify({ subject }^)
echo     }^)
echo   },
echo.
echo   // 导出题库
echo   exportQuestionBank: (questionBankId, format = 'excel'^) =^> {
echo     return callServerAPI(`/api/question-bank/$%{questionBankId}/export?format=$%{format}`, {
echo       method: 'GET',
echo       responseType: 'blob'
echo     }^)
echo   }
echo }
echo.
echo export default adminAPI
) > "admin\src\api\admin.js"

echo [OK] Updated admin.js with hardcoded API URL

echo.
echo [STEP 5] Clean build and rebuild
echo ========================================
echo [INFO] Cleaning and rebuilding admin project...

cd admin

:: Clean previous build
if exist "dist" (
    echo [INFO] Cleaning previous build...
    rmdir /s /q "dist"
    echo [OK] Previous build cleaned
)

:: Clean node_modules and reinstall
echo [INFO] Cleaning node_modules...
if exist "node_modules" (
    rmdir /s /q "node_modules"
    echo [OK] node_modules cleaned
)

echo [INFO] Installing dependencies...
call npm install
if %errorlevel% neq 0 (
    echo [ERROR] Failed to install dependencies
    cd ..
    pause
    exit /b 1
)

echo [INFO] Building admin project...
call npm run build
if %errorlevel% neq 0 (
    echo [ERROR] Failed to build admin project
    cd ..
    pause
    exit /b 1
)

echo [OK] Admin project built successfully
cd ..

echo.
echo [STEP 6] Deploy updated files
echo ========================================
echo [INFO] Deploying updated files to C:\admin...

if exist "admin\dist" (
    if exist "C:\admin" (
        echo [INFO] Clearing C:\admin directory...
        del /q "C:\admin\*" >nul 2>&1
        for /d %%d in ("C:\admin\*"^) do rmdir /s /q "%%d" >nul 2>&1
    ) else (
        echo [INFO] Creating C:\admin directory...
        mkdir "C:\admin"
    )
    
    echo [INFO] Copying new files to C:\admin...
    xcopy "admin\dist\*" "C:\admin\" /E /Y /Q
    if %errorlevel% equ 0 (
        echo [OK] Files deployed successfully
    ) else (
        echo [ERROR] Failed to deploy files
    )
) else (
    echo [ERROR] admin\dist directory not found
)

echo.
echo [STEP 7] Verify deployment
echo ========================================
if exist "C:\admin\index.html" (
    echo [OK] Deployment successful: C:\admin\index.html exists
) else (
    echo [ERROR] Deployment failed: C:\admin\index.html not found
)

echo.
echo ========================================
echo Force Fix Complete
echo ========================================
echo.
echo Changes made:
echo 1. Created/updated all environment files (.env, .env.production, .env.local^)
echo 2. Updated admin.js with hardcoded API URL: https://practice.insightdate.top
echo 3. Added console.log to track API calls
echo 4. Cleaned and rebuilt the entire project
echo 5. Deployed updated files to C:\admin
echo.
echo Next steps:
echo 1. Clear browser cache completely (Ctrl+Shift+Delete^)
echo 2. Close and reopen browser
echo 3. Reload the admin page
echo 4. Check browser developer tools console for API call logs
echo 5. Verify API calls now use https://practice.insightdate.top/api
echo.
echo Press any key to exit...
pause >nul
