@echo off
chcp 65001 >nul
echo ========================================
echo Enable Same Domain Proxy Solution
echo ========================================
echo.

echo [STEP 1] Stop nginx
echo ========================================
echo [INFO] Stopping nginx...
taskkill /f /im nginx.exe >nul 2>&1
timeout /t 2 /nobreak >nul

echo.
echo [STEP 2] Backup current configuration
echo ========================================
echo [INFO] Backing up current configuration...
if exist "C:\nginx\conf.d\admin-ssl.conf" (
    copy "C:\nginx\conf.d\admin-ssl.conf" "C:\nginx\conf.d\admin-ssl.conf.backup" >nul
    echo [OK] Backed up admin-ssl.conf
) else (
    echo [WARNING] admin-ssl.conf not found
)

echo.
echo [STEP 3] Create same domain proxy configuration
echo ========================================
echo [INFO] Creating same domain proxy configuration...

(
echo # Same domain proxy configuration - eliminates CORS issues
echo server {
echo     listen 80;
echo     server_name admin.practice.insightdate.top;
echo     return 301 https://$server_name:8443$request_uri;
echo }
echo.
echo server {
echo     listen 8443 ssl;
echo     server_name admin.practice.insightdate.top;
echo.
echo     ssl_certificate C:/certificates/admin.practice.insightdata.top.pem;
echo     ssl_certificate_key C:/certificates/admin.practice.insightdata.top.key;
echo.
echo     ssl_protocols TLSv1.2 TLSv1.3;
echo     ssl_ciphers HIGH:!aNULL:!MD5;
echo     ssl_prefer_server_ciphers off;
echo.
echo     # Security headers
echo     add_header X-Frame-Options "SAMEORIGIN" always;
echo     add_header X-Content-Type-Options "nosniff" always;
echo     add_header X-XSS-Protection "1; mode=block" always;
echo     add_header Referrer-Policy "strict-origin-when-cross-origin" always;
echo     add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
echo.
echo     root C:/admin;
echo     index index.html;
echo.
echo     # Serve admin frontend files
echo     location / {
echo         try_files $uri $uri/ /index.html;
echo         
echo         # Cache static assets
echo         location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg|woff|woff2|ttf|eot)$ {
echo             expires 1y;
echo             add_header Cache-Control "public, immutable";
echo             add_header X-Content-Type-Options "nosniff" always;
echo         }
echo         
echo         # Don't cache HTML files
echo         location ~* \.html$ {
echo             expires -1;
echo             add_header Cache-Control "no-cache, no-store, must-revalidate";
echo             add_header Pragma "no-cache";
echo         }
echo     }
echo.
echo     # Proxy API requests to practice.insightdate.top
echo     location /api/ {
echo         proxy_pass https://practice.insightdate.top/api/;
echo         proxy_set_header Host $host;
echo         proxy_set_header X-Real-IP $remote_addr;
echo         proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
echo         proxy_set_header X-Forwarded-Proto $scheme;
echo         proxy_set_header X-Forwarded-Host $host;
echo         proxy_set_header X-Forwarded-Port $server_port;
echo.
echo         # SSL settings for upstream
echo         proxy_ssl_verify off;
echo         proxy_ssl_server_name on;
echo         proxy_ssl_protocols TLSv1.2 TLSv1.3;
echo.
echo         # Timeout settings
echo         proxy_connect_timeout 30s;
echo         proxy_send_timeout 30s;
echo         proxy_read_timeout 30s;
echo.
echo         # Buffer settings
echo         proxy_buffering on;
echo         proxy_buffer_size 4k;
echo         proxy_buffers 8 4k;
echo.
echo         # Handle errors
echo         proxy_intercept_errors on;
echo         error_page 502 503 504 /50x.html;
echo     }
echo.
echo     # Health check endpoint
echo     location /health {
echo         return 200 "OK";
echo         add_header Content-Type text/plain;
echo     }
echo.
echo     # Error pages
echo     location = /50x.html {
echo         root C:/admin;
echo         internal;
echo     }
echo }
) > "C:\nginx\conf.d\admin-ssl.conf"

echo [OK] Created same domain proxy configuration

echo.
echo [STEP 4] Update admin API configuration
echo ========================================
echo [INFO] Updating admin API configuration to use same domain...

:: Update admin.js to use same domain
(
echo // 获取token
echo const getToken = () =^> {
echo   return localStorage.getItem('token'^)
echo }
echo.
echo // 服务器API基础URL - 使用同域代理
echo const getServerUrl = () =^> {
echo   return window.location.origin
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

echo [OK] Updated admin.js to use same domain

echo.
echo [STEP 5] Rebuild and deploy admin
echo ========================================
echo [INFO] Rebuilding admin project...

cd admin
if exist "dist" (
    rmdir /s /q "dist"
    echo [OK] Cleaned previous build
)

call npm run build
if %errorlevel% neq 0 (
    echo [ERROR] Failed to build admin project
    cd ..
    pause
    exit /b 1
)

echo [OK] Admin project built successfully
cd ..

echo [INFO] Deploying to C:\admin...
if exist "C:\admin" (
    del /q "C:\admin\*" >nul 2>&1
    for /d %%d in ("C:\admin\*"^) do rmdir /s /q "%%d" >nul 2>&1
) else (
    mkdir "C:\admin"
)

xcopy "admin\dist\*" "C:\admin\" /E /Y /Q
if %errorlevel% equ 0 (
    echo [OK] Files deployed successfully
) else (
    echo [ERROR] Failed to deploy files
)

echo.
echo [STEP 6] Test and start nginx
echo ========================================
echo [INFO] Testing nginx configuration...
cd /d C:\nginx
C:\nginx\nginx.exe -t
if %errorlevel% equ 0 (
    echo [OK] nginx configuration test passed
) else (
    echo [ERROR] nginx configuration test failed
    echo [INFO] Check error details above
)
cd /d "%~dp0"

echo [INFO] Starting nginx...
cd /d C:\nginx
start "Nginx Server" nginx.exe
timeout /t 3 /nobreak >nul
cd /d "%~dp0"

echo [INFO] Checking nginx status...
tasklist /fi "imagename eq nginx.exe" | find "nginx.exe" >nul 2>&1
if %errorlevel% equ 0 (
    echo [OK] nginx is running
) else (
    echo [ERROR] nginx failed to start
)

echo.
echo [STEP 7] Check ports
echo ========================================
netstat -an | find ":8443 " >nul 2>&1
if %errorlevel% equ 0 (
    echo [OK] Port 8443 is listening
) else (
    echo [ERROR] Port 8443 is not listening
)

echo.
echo ========================================
echo Same Domain Proxy Setup Complete
echo ========================================
echo.
echo Changes made:
echo 1. Updated nginx configuration to proxy API requests
echo 2. Updated admin.js to use window.location.origin
echo 3. Rebuilt and deployed admin project
echo 4. Started nginx with new configuration
echo.
echo How it works:
echo - Admin frontend: https://admin.practice.insightdate.top:8443/
echo - API requests: https://admin.practice.insightdate.top:8443/api/*
echo - nginx proxies /api/* to https://practice.insightdate.top/api/*
echo - No CORS issues because everything appears on same domain
echo.
echo Next steps:
echo 1. Clear browser cache (Ctrl+F5)
echo 2. Reload the admin page
echo 3. Test login functionality
echo 4. Check browser developer tools - API calls should now be same domain
echo.
echo Press any key to exit...
pause >nul
