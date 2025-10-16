@echo off
chcp 65001 >nul
echo 🔍 测试路径解析
echo ================

echo 运行路径解析测试...
node test-path-resolution.js

echo.
echo 测试完成！
echo 如果所有测试都通过，说明路径配置正确。
echo 请重启API服务后测试题目上传功能。
pause
