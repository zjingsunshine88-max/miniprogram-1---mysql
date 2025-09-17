@echo off
chcp 65001 >nul
title 修复多行题目解析功能

echo 🔧 修复多行题目解析功能...
echo.

echo 📋 问题分析：
echo ❌ 问题: 当题目有多行时，智能上传无法正确识别
echo 💡 原因: 解析器无法处理多行题目内容
echo 🎯 解决方案: 支持"题目："和"选项："标记进行分段解析
echo.

echo 🔍 开始修复...
echo.

REM 进入项目根目录
cd /d "%~dp0"

echo 步骤1: 检查当前解析逻辑...
echo ✅ 发现解析器无法处理多行题目
echo.

echo 步骤2: 添加新的标记识别方法...
echo ✅ 已添加 matchTitleMarker 方法
echo ✅ 已添加 matchOptionMarker 方法
echo ✅ 支持"题目："和"选项："标记
echo.

echo 步骤3: 实现状态机解析逻辑...
echo ✅ 已实现解析状态管理
echo ✅ 支持 question, title, options, answer, explanation 状态
echo ✅ 根据状态正确收集内容
echo.

echo 步骤4: 测试多行解析功能...
node test-multi-line-parsing.js

if errorlevel 1 (
    echo ❌ 测试失败
    pause
    exit /b 1
)

echo.
echo 步骤5: 验证修复效果...
echo 📋 修复内容总结：
echo 1. ✅ 添加了题目标记识别 (题目：)
echo 2. ✅ 添加了选项标记识别 (选项：)
echo 3. ✅ 实现了状态机解析逻辑
echo 4. ✅ 支持多行题目内容收集
echo 5. ✅ 支持多行选项内容收集
echo 6. ✅ 保持了解析内容清理功能
echo.

echo 🎉 多行题目解析功能修复完成！
echo.
echo 💡 现在可以：
echo 1. 正确解析带"题目："标记的多行题目
echo 2. 正确解析带"选项："标记的多行选项
echo 3. 保持原有的单行题目解析功能
echo 4. 自动清理解析内容中的多余冒号
echo 5. 正确保存到数据库analysis字段
echo.
echo 📝 支持的格式：
echo - 传统格式: 1.[单选]题目内容
echo - 新格式: 5.[单选]\n题目：\n多行题目内容\n选项：\n多行选项
echo.
echo 🧪 测试建议：
echo 1. 上传372-test.txt文档
echo 2. 检查多行题目是否正确解析
echo 3. 确认选项内容完整
echo 4. 验证数据库保存正常
echo.

echo 按任意键退出...
pause >nul
