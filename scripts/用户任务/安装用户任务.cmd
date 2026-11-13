@echo off
chcp 65001 >nul
rem 把用户级任务装进编辑器（开哪个文件夹都有「C++：编译并运行当前文件」）
set "目标=%APPDATA%\中文大战代码\User\tasks.json"
if not exist "%APPDATA%\中文大战代码\User" mkdir "%APPDATA%\中文大战代码\User"
if exist "%目标%" copy /y "%目标%" "%目标%.bak" >nul
copy /y "%~dp0tasks.json" "%目标%" >nul
if errorlevel 1 (echo 安装失败 & pause & exit /b 1)
echo 已安装用户级任务 —— 重启编辑器后，打开任意文件点「运行任务」即可看到 C++ 等任务。
pause