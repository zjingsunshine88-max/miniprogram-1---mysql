# Nginx环境变量配置指南

## 概述

本指南介绍如何将nginx配置到Windows系统环境变量中，这样就可以在任何目录下直接使用nginx命令。

## 快速配置

### 方法1: 使用批处理脚本（推荐）
```bash
# 以管理员身份运行
setup-nginx-path.bat
```

### 方法2: 使用PowerShell脚本
```powershell
# 以管理员身份运行
.\setup-nginx-path.ps1

# 指定nginx路径
.\setup-nginx-path.ps1 -NginxPath "C:\nginx"

# 强制更新PATH
.\setup-nginx-path.ps1 -Force
```

## 手动配置方法

### 1. 找到nginx安装路径
nginx通常安装在以下位置之一：
- `C:\nginx`
- `C:\Program Files\nginx`
- `C:\Program Files (x86)\nginx`
- `D:\nginx`
- `E:\nginx`

### 2. 手动添加到环境变量

#### 方法A: 通过系统设置
1. 右键"此电脑" → "属性"
2. 点击"高级系统设置"
3. 点击"环境变量"
4. 在"系统变量"中找到"Path"，点击"编辑"
5. 点击"新建"，输入nginx的安装路径
6. 点击"确定"保存

#### 方法B: 通过命令行
```cmd
# 以管理员身份运行cmd
setx PATH "%PATH%;C:\nginx" /M
```

#### 方法C: 通过PowerShell
```powershell
# 以管理员身份运行PowerShell
[Environment]::SetEnvironmentVariable("PATH", "$env:PATH;C:\nginx", "Machine")
```

## 验证配置

配置完成后，打开新的命令行窗口，运行以下命令验证：

```bash
# 查看nginx版本
nginx -v

# 测试配置文件
nginx -t

# 查看nginx帮助
nginx -h
```

## 常用nginx命令

```bash
# 启动nginx
nginx

# 停止nginx
nginx -s stop

# 重新加载配置
nginx -s reload

# 重新打开日志文件
nginx -s reopen

# 测试配置文件
nginx -t

# 查看版本
nginx -v

# 查看版本和配置信息
nginx -V
```

## 故障排除

### 1. 命令不可用
如果配置后nginx命令仍然不可用：

1. **重启命令行窗口**
2. **重启系统**（推荐）
3. **检查PATH环境变量**：
   ```cmd
   echo %PATH%
   ```

### 2. 权限问题
如果遇到权限问题：
- 确保以管理员身份运行配置脚本
- 检查nginx安装目录的访问权限

### 3. 路径问题
如果nginx不在常见位置：
- 使用PowerShell脚本的 `-NginxPath` 参数指定路径
- 或手动添加到环境变量

### 4. 验证nginx安装
```bash
# 检查nginx.exe是否存在
dir C:\nginx\nginx.exe

# 直接运行nginx
C:\nginx\nginx.exe -v
```

## 高级配置

### 1. 创建nginx服务
```cmd
# 以管理员身份运行
sc create nginx binPath= "C:\nginx\nginx.exe" start= auto
```

### 2. 设置nginx开机自启
```cmd
# 启动服务
net start nginx

# 停止服务
net stop nginx
```

### 3. 配置nginx配置文件路径
```bash
# 使用指定配置文件启动
nginx -c "C:\path\to\nginx.conf"

# 测试指定配置文件
nginx -t -c "C:\path\to\nginx.conf"
```

## 注意事项

1. **管理员权限**: 配置系统环境变量需要管理员权限
2. **重启生效**: 环境变量更改后需要重启命令行或系统才能生效
3. **路径格式**: Windows路径使用反斜杠 `\`，但在某些情况下可能需要正斜杠 `/`
4. **防火墙**: 确保防火墙允许nginx访问网络
5. **端口占用**: 确保80和443端口未被其他程序占用

## 卸载配置

如果需要从环境变量中移除nginx路径：

```powershell
# 获取当前PATH
$currentPath = [Environment]::GetEnvironmentVariable("PATH", "Machine")

# 移除nginx路径
$newPath = $currentPath -replace ";C:\\nginx", ""
$newPath = $newPath -replace "C:\\nginx;", ""
$newPath = $newPath -replace "C:\\nginx", ""

# 更新PATH
[Environment]::SetEnvironmentVariable("PATH", $newPath, "Machine")
```

## 联系支持

如果遇到问题，请检查：
1. nginx是否正确安装
2. 是否以管理员身份运行
3. 环境变量是否正确设置
4. 系统是否需要重启
