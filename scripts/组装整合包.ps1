#
 ============================================================================
#  组装整合包.ps1 —— 从各条线的"源头产物"重新组装整合包
#
#  为什么要有这个脚本：
#    整合包之前是手工一步步拼出来的（拷工具链、写示例、放文档），
#    一旦某一步的东西丢了/被误删，只能靠记忆复原。现在改成**可重跑**：
#    任何时候执行它，整合包都会回到一个已知的、完整的状态。
#
#  数据来源（全部只读，不改动各条线的仓库）：
#    Chinese++         E:\Chinese++\dist\Chinese++-0.3-win64
#    ChinesePython     E:\ChinesePython\Python\PCbuild\amd64 + Lib
#    ChineseJava       E:\ChineseJava-发行版\jdk（去掉 jmods / demo / src.zip）
#    ChineseTypeScript E:\ChineseTypeScript\dist\ChineseTypeScript-0.2.4-win64
#    游戏引擎          E:\godot\Godot_v4.7.2-stable_win64\中文大战代码.exe
#    编辑器            由 构建.ps1 负责（它会把产物同步进 editor\）
#
#  用法：pwsh -File 组装整合包.ps1 [-SkipEditor]
#        -SkipEditor  不动 editor\（只重建工具链/示例/文档/引擎）
# ============================================================================
param([switch]$SkipEditor)

$ErrorActionPreference = 'Stop'
$enc = New-Object System.Text.UTF8Encoding($false)
$gbk = [System.Text.Encoding]::GetEncoding(936)
$根 = 'E:\ChineseVSCode\整合包\中文大战代码-0.2'
$tc = Join-Path $根 'toolchains'

function 步([string]$s) { Write-Host ('=== ' + $s + ' ===') }
function 大小([string]$p) {
	if (-not (Test-Path -LiteralPath $p)) { return 0 }
	$f = Get-ChildItem $p -Recurse -File -Force -ErrorAction SilentlyContinue
	return [math]::Round((($f | Measure-Object Length -Sum).Sum / 1MB), 1)
}

New-Item -ItemType Directory -Force $根, $tc | Out-Null

# ---------------------------------------------------------------- 1) Chinese++
步 '1/7 Chinese++'
$cppSrc = Get-ChildItem 'E:\Chinese++\dist' -Directory -Filter 'Chinese++-*-win64' -ErrorAction SilentlyContinue |
    Sort-Object { [version]($_.Name -replace '^Chinese\+\+-', '' -replace '-win64$', '') } |
    Select-Object -Last 1 | ForEach-Object { $_.FullName }
if (Test-Path -LiteralPath $cppSrc) {
	robocopy $cppSrc (Join-Path $tc 'cpp') /MIR /NFL /NDL /NJH /NJS /NP | Out-Null
	# 补齐发行包缺的东西：9 个别名（ZIP 不保留硬链接）+ bin\<driver>.cfg（中文头搜索路径）
	# cfg 必须由 make_zhcfg.ps1 生成（0.4 起 cfg 含 -include 兼容头与 nodefaultlib，
	# 旧的 生成中文头配置.ps1 只有 13 行，缺这些，会编译失败）
	$mk = Join-Path $tc 'cpp\tools\make_zhcfg.ps1'
	if (-not (Test-Path -LiteralPath $mk)) { $mk = Join-Path $PSScriptRoot '..\..\Chinese++\tools\make_zhcfg.ps1' }
	& pwsh -NoProfile -File $mk -Mode bundled -ZhRoot (Join-Path $tc 'cpp') -BinDir (Join-Path $tc 'cpp\bin') | Out-Null
	Write-Host ('  ' + (大小 (Join-Path $tc 'cpp')) + ' MB')
} else { Write-Host '  !! 缺来源：' + $cppSrc; exit 1 }

# ---------------------------------------------------------------- 2) ChinesePython
步 '2/7 ChinesePython'
$pySrc = 'E:\ChinesePython\Python'
if (Test-Path -LiteralPath $pySrc) {
	robocopy (Join-Path $pySrc 'PCbuild\amd64') (Join-Path $tc 'python\PCbuild\amd64') /MIR /NFL /NDL /NJH /NJS /NP | Out-Null
	robocopy (Join-Path $pySrc 'Lib') (Join-Path $tc 'python\Lib') /MIR /XD test __pycache__ /NFL /NDL /NJH /NJS /NP | Out-Null
	Write-Host ('  ' + (大小 (Join-Path $tc 'python')) + ' MB')
} else { Write-Host '  !! 缺来源：' + $pySrc; exit 1 }

# ---------------------------------------------------------------- 3) ChineseJava
步 '3/7 ChineseJava'
$javaSrc = 'E:\ChineseJava-发行版\jdk'
if (Test-Path -LiteralPath $javaSrc) {
	robocopy $javaSrc (Join-Path $tc 'java\runtime') /MIR /XD jmods demo /XF src.zip /NFL /NDL /NJH /NJS /NP | Out-Null
	Write-Host ('  ' + (大小 (Join-Path $tc 'java')) + ' MB')
} else { Write-Host '  !! 缺来源：' + $javaSrc; exit 1 }

# ---------------------------------------------------------------- 4) ChineseTypeScript
步 '4/7 ChineseTypeScript'
$tsSrc = 'E:\ChineseTypeScript\dist\ChineseTypeScript-0.2.4-win64'
if (Test-Path -LiteralPath $tsSrc) {
	robocopy $tsSrc (Join-Path $tc 'typescript') /MIR /NFL /NDL /NJH /NJS /NP | Out-Null
	# TS 的中文成员名是按名字全局替换的，写错名字会静默产错结果 —— 随包发一份陷阱表
	Copy-Item (Join-Path $PSScriptRoot '..\整合包\中文大战代码-0.2\toolchains\typescript\中文成员名-陷阱与正确写法.md') (Join-Path $tc 'typescript\中文成员名-陷阱与正确写法.md') -Force -ErrorAction SilentlyContinue
	Write-Host ('  ' + (大小 (Join-Path $tc 'typescript')) + ' MB')
} else { Write-Host '  !! 缺来源：' + $tsSrc; exit 1 }

# ---------------------------------------------------------------- 5) 游戏引擎
步 '5/7 游戏引擎（魔改 Godot）'
$engDir = Join-Path $根 'engine'
New-Item -ItemType Directory -Force $engDir | Out-Null
$engExe = 'E:\godot\Godot_v4.7.2-stable_win64\中文大战代码.exe'
if (Test-Path -LiteralPath $engExe) {
	Copy-Item -LiteralPath $engExe -Destination (Join-Path $engDir '中文大战代码.exe') -Force
	$console = 'E:\godot\Godot_v4.7.2-stable_win64\中文大战代码_console.exe'
	if (Test-Path -LiteralPath $console) { Copy-Item -LiteralPath $console -Destination (Join-Path $engDir '中文大战代码_console.exe') -Force }
	Write-Host ('  ' + (大小 $engDir) + ' MB')
} else { Write-Host '  !! 缺引擎：' + $engExe }

# 引擎 → 编辑器的桥接脚本（每次重写，保证与包内布局一致）
$ps1 = @'
param([Parameter(ValueFromRemainingArguments = $true)] $参数)

# 中文大战代码：引擎把脚本交回编辑器。
# Godot 调用形如：  "D:\proj\x.gd" --line 42      编辑器要的是：--goto "D:\proj\x.gd:42"
Remove-Item Env:\ELECTRON_RUN_AS_NODE -ErrorAction SilentlyContinue

$文件 = $null; $行号 = $null
for ($i = 0; $i -lt $参数.Count; $i++) {
    $a = [string]$参数[$i]
    if ($a -eq '--line' -or $a -eq '-l') { if ($i + 1 -lt $参数.Count) { $行号 = [string]$参数[$i + 1]; $i++ }; continue }
    if ($a -eq '--column' -or $a -eq '-c') { if ($i + 1 -lt $参数.Count) { $i++ }; continue }
    if ($null -eq $文件 -and -not $a.StartsWith('-')) { $文件 = $a }
}

$候选 = @(
    (Join-Path $PSScriptRoot '..\editor\中文大战代码.exe'),
    (Join-Path $env:LOCALAPPDATA '中文大战代码\editor\中文大战代码.exe')
)
$编辑器 = $候选 | Where-Object { Test-Path -LiteralPath $_ } | Select-Object -First 1 | ForEach-Object { (Get-Item -LiteralPath $_).FullName }
if (-not $编辑器) { exit 1 }

if ($null -eq $文件) { Start-Process -FilePath $编辑器; exit 0 }
if ($null -ne $行号) { Start-Process -FilePath $编辑器 -ArgumentList ('--goto "{0}:{1}"' -f $文件, $行号) }
else { Start-Process -FilePath $编辑器 -ArgumentList ('"{0}"' -f $文件) }
exit 0
'@
[System.IO.File]::WriteAllText((Join-Path $engDir 'cdzc-open.ps1'), ($ps1 -replace "`r?`n", "`r`n"), (New-Object System.Text.UTF8Encoding($true)))
$cmdShim = @'
@echo off
rem ASCII-only shim: hand off to PowerShell (it handles Unicode paths).
setlocal
powershell -NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File "%~dp0cdzc-open.ps1" %*
exit /b %ERRORLEVEL%
'@
[System.IO.File]::WriteAllText((Join-Path $engDir '打开编辑器.cmd'), ($cmdShim -replace "`r?`n", "`r`n"), $gbk)

# ---------------------------------------------------------------- 6) 示例工程
步 '6/7 示例工程'
$ex = Join-Path $根 'examples'
New-Item -ItemType Directory -Force (Join-Path $ex 'cpp'), (Join-Path $ex 'python'), (Join-Path $ex 'java'), (Join-Path $ex 'typescript'), (Join-Path $ex '.vscode') | Out-Null

[System.IO.File]::WriteAllText((Join-Path $ex 'cpp\你好.cpp'), @'
// 中文 C++ 示例：中文关键字 + 中文标准库
#包含 <C标准输入输出>

整数 斐波那契(整数 n) {
    如果 (n <= 1) { 返回 n; }
    返回 斐波那契(n - 1) + 斐波那契(n - 2);
}

整数 主函数() {
    标准::格式化输出("你好，中文大战代码！\n");
    对于 (整数 甲 = 0; 甲 < 10; 甲++) {
        标准::格式化输出("斐波那契(%d) = %d\n", 甲, 斐波那契(甲));
    }
    返回 0;
}
'@, $enc)

[System.IO.File]::WriteAllText((Join-Path $ex 'python\你好.py'), @'
# -*- coding: utf-8 -*-
"""中文大战代码 · ChinesePython 示例

中文关键字与英文是并列的，一个文件里可以混写。
"""

导入 sys


定义 斐波那契(第几项):
    如果 第几项 <= 1:
        返回 第几项
    返回 斐波那契(第几项 - 1) + 斐波那契(第几项 - 2)


定义 主函数():
    print("你好，中文大战代码！")
    print("Python 版本：", sys.version.split()[0])
    数列 = []
    对于 i 属于 范围(10):
        数列.追加(斐波那契(i))
    print("斐波那契前 10 项：", 数列)

    尝试:
        结果 = 10 / 0
    捕获 除零错误 as 错:
        print("故意出错，被捕获了：", 错)


主函数()
'@, $enc)

[System.IO.File]::WriteAllText((Join-Path $ex 'java\你好.java'), @'
/** 中文大战代码 · ChineseJava 示例
 *
 *  编译：javac 你好.java      运行：java 你好
 *  中文关键字与英文并列；标准库名保持英文（System.out.println）。
 */
公开 类型 你好 {

    公开 静态 空型 main(String[] 参数) {
        System.out.println("你好，中文大战代码！");
        整数 甲 = 3;
        整数 乙 = 4;
        System.out.println("甲 + 乙 = " + 加(甲, 乙));
        对于 (整数 i = 0; i < 3; i++) {
            System.out.println("第 " + i + " 次循环");
        }
    }

    静态 整数 加(整数 甲, 整数 乙) {
        返回 甲 + 乙;
    }
}
'@, $enc)

[System.IO.File]::WriteAllText((Join-Path $ex 'typescript\你好.ts'), @'
// 中文 TypeScript 示例（ChineseTypeScript）
// 编译：chtsc 你好.ts --target es2020      运行：node 你好.js
//
// 注意两个循环关键字不是一回事（词表如此，实测确认）：
//   遍历  → for...of  拿到的是**元素**
//   属于  → for...in  拿到的是**下标（字符串）**，值*2 会得到 0/2/4 这种错结果
// 所以遍历数组请用 `遍历`。

常量 问候: 字符串 = "你好，中文大战代码！";

函数 斐波那契(第几项: 数字): 数字 {
    如果 (第几项 <= 1) {
        返回 第几项;
    }
    返回 斐波那契(第几项 - 1) + 斐波那契(第几项 - 2);
}

接口 学生 {
    名字: 字符串;
    分数: 数字;
}

函数 描述(学生: 学生): 字符串 {
    如果 (学生.分数 >= 60) {
        返回 学生.名字 + "：及格";
    }
    返回 学生.名字 + "：不及格";
}

常量 数列: 数字[] = [0, 1, 2, 3, 4];

控制台.日志(问候);
对于 (常量 第几项 遍历 数列) {
    控制台.日志("斐波那契(" + 第几项 + ") = " + 斐波那契(第几项));
}
控制台.日志(描述({ 名字: "小明", 分数: 82 }));
控制台.日志(描述({ 名字: "小红", 分数: 55 }));
'@, $enc)

$tasks = @'
{
  "version": "2.0.0",
  "tasks": [
    {
      "label": "C++：编译并运行",
      "type": "shell",
      "command": "chinese++ -std=c++20 -D_CRT_SECURE_NO_WARNINGS \"${file}\" -o \"${fileDirname}/你好.exe\" && \"${fileDirname}/你好.exe\"",
      "group": { "kind": "build", "isDefault": true },
      "problemMatcher": { "pattern": { "regexp": "^(.*?):(\\d+):(\\d+):\\s+(error|warning|note):\\s+(.*)$", "file": 1, "line": 2, "column": 3, "severity": 4, "message": 5 } }
    },
    {
      "label": "Python：运行",
      "type": "shell",
      "command": "python \"${file}\"",
      "group": "build",
      "problemMatcher": []
    },
    {
      "label": "Java：编译并运行",
      "type": "shell",
      "command": "javac \"${file}\" && java -cp \"${fileDirname}\" \"${fileBasenameNoExtension}\"",
      "group": "build",
      "problemMatcher": { "pattern": { "regexp": "^(.*?):(\\d+):\\s+(error|warning):\\s+(.*)$", "file": 1, "line": 2, "severity": 3, "message": 4 } }
    },
    {
      "label": "TypeScript：编译并运行",
      "type": "shell",
      "command": "chtsc \"${file}\" --target es2020 && node \"${fileDirname}\\${fileBasenameNoExtension}.js\"",
      "group": "build",
      "problemMatcher": { "pattern": { "regexp": "^(.*?)\\((\\d+),(\\d+)\\):\\s+(error|warning)\\s+(\\w+):\\s+(.*)$", "file": 1, "line": 2, "column": 3, "severity": 4, "message": 6 } }
    }
  ]
}
'@
[System.IO.File]::WriteAllText((Join-Path $ex '.vscode\tasks.json'), ($tasks -replace "`r?`n", "`n"), $enc)

# 用户级任务：装到 %APPDATA%\中文大战代码\User\tasks.json 后，开任意文件夹/单文件都能在「运行任务」里看到
$用户任务源 = Join-Path $PSScriptRoot '用户任务'
if (Test-Path -LiteralPath $用户任务源) {
    robocopy $用户任务源 (Join-Path $根 '用户任务') /MIR /NFL /NDL /NJH /NJS /NP | Out-Null
    Write-Host ('  用户任务模板：' + ((Get-ChildItem (Join-Path $根 '用户任务') -File | ForEach-Object { $_.Name }) -join ' / '))
}
# 自检：tasks.json 必须是合法 JSON（非法时 VS Code 的「运行任务」列表会是空的）
try { $tasks | ConvertFrom-Json | Out-Null } catch { throw ('tasks.json 非法：' + $_) }
Write-Host ('  ' + (大小 $ex) + ' MB')

# ---------------------------------------------------------------- 7) 启动器与文档
步 '7/7 启动器与文档'
$launcher = @'
@echo off
chcp 65001 >nul
rem ============================================================================
rem  中文大战代码 —— 启动器
rem  只为**本进程**注入四门工具链的路径，不改系统环境。
rem  编辑器里的终端与任务会继承这些变量。
rem  （本文件存为 UTF-8，首行切 65001 代码页，否则中文路径会被读乱。）
rem ============================================================================
setlocal
set "ROOT=%~dp0"
set "CDZC_ROOT=%ROOT:~0,-1%"
set "PATH=%ROOT%toolchains\cpp\bin;%ROOT%toolchains\python\PCbuild\amd64;%ROOT%toolchains\java\runtime\bin;%ROOT%toolchains\typescript\bin;%ROOT%toolchains\typescript\node;%PATH%"
set "PYTHONHOME=%ROOT%toolchains\python"
rem ---- 用户级任务：按【本包实际位置】生成/更新，开任意文件夹/单文件都能「运行任务」----
set "TASKS=%APPDATA%\中文大战代码\User\tasks.json"
if not exist "%APPDATA%\中文大战代码\User" mkdir "%APPDATA%\中文大战代码\User"
set "ROOTF=%ROOT:\=/%"
> "%TASKS%" (
echo {
echo   "version": "2.0.0",
echo   "tasks": [
echo     { "label": "C++：编译并运行当前文件", "type": "shell", "command": "\"%ROOTF%toolchains/cpp/bin/chinese++.exe\" -std=c++2c -D_CRT_SECURE_NO_WARNINGS \"${file}\" -o \"${fileDirname}/${fileBasenameNoExtension}.exe\" ^&^& \"${fileDirname}/${fileBasenameNoExtension}.exe\"", "group": { "kind": "build", "isDefault": true } },
echo     { "label": "Python：运行当前文件", "type": "shell", "command": "\"%ROOTF%toolchains/python/PCbuild/amd64/python.exe\" \"${file}\"" },
echo     { "label": "Java：编译并运行当前文件", "type": "shell", "command": "\"%ROOTF%toolchains/java/runtime/bin/javac.exe\" \"${file}\" ^&^& \"%ROOTF%toolchains/java/runtime/bin/java.exe\" -cp \"${fileDirname}\" \"${fileBasenameNoExtension}\"" },
echo     { "label": "TypeScript：编译并运行当前文件", "type": "shell", "command": "\"%ROOTF%toolchains/typescript/bin/chtsc.exe\" \"${file}\" --target es2020 ^&^& \"%ROOTF%toolchains/typescript/node/node.exe\" \"${fileDirname}/${fileBasenameNoExtension}.js\"" }
echo   ]
echo }
)
  if not exist "%APPDATA%\中文大战代码\User" mkdir "%APPDATA%\中文大战代码\User"
  copy /y "%ROOT%用户任务\tasks.json" "%用户任务%" >nul
)

set "EXE=%ROOT%editor\中文大战代码.exe"
if not exist "%EXE%" (
  echo 找不到 editor\中文大战代码.exe，包可能不完整。
  pause
  exit /b 1
)
start "" "%EXE%" %*
exit /b 0
'@
[System.IO.File]::WriteAllText((Join-Path $根 '启动.cmd'), ($launcher -replace "`r?`n", "`r`n"), (New-Object System.Text.UTF8Encoding($false)))

[System.IO.File]::WriteAllText((Join-Path $根 '分发授权.md'), @'
# 分发授权记录

| 项 | 内容 |
|---|---|
| 项目 | ChinesePython |
| 授权内容 | 随「中文大战代码 0.2」整合包一并分发 |
| 授权依据 | ChinesePython 著作权人于 2026-10-10 在协作对话中明确表示「允许」 |
| 授权范围 | 本整合包内 `toolchains\python\` 下的运行时（含中文标准库与报错资源），保持原样 |
| 与 ChinesePython LICENSE 的关系 | 其 `LICENSE-SCOPE.md` 规定原创部分「禁止重新打包再发布」；本授权系著作权人对其自身许可的豁免，仅适用于本整合包 |
| 若日后撤回 | 从包中删除 `toolchains\python\` 即可，不影响其余组件 |

> 这不是法律意见，只是把授权事实记录下来，避免以后有人看到 `LICENSE-SCOPE.md`
> 以为这个包越权。
'@, $enc)

$说明 = @'
# 中文大战代码 0.2

**不是创新的汉语编程，却是最强的汉语编程。**

一个品牌，两个程序：

```
editor\中文大战代码.exe    代码编辑器
engine\中文大战代码.exe    游戏引擎（魔改 Godot 4.7.2）
```

## 里面有什么

```
editor\                     编辑器（界面全中文，四门语言开箱可用）
toolchains\cpp\             Chinese++：C/C++ 中文关键字 + 中文报错 + clangd
toolchains\python\          ChinesePython 3.14.7：中文关键字 + 中文报错 + 中文标准库
toolchains\java\runtime\    ChineseJava：OpenJDK（只汉化关键字，标准库名保持英文）
toolchains\typescript\      ChineseTypeScript 0.2.4：chtsc + 自带 node
engine\                     游戏引擎（魔改 Godot）：内嵌 ChinesePython，可用中文写游戏逻辑
examples\                   cpp / python / java / typescript 四份可直接跑的示例
启动.cmd                    启动器（给本进程注入工具链路径）
```

## 怎么用

1. 双击 **启动.cmd**，或直接 `editor\中文大战代码.exe`；
2. 打开 `examples\` 下任一文件夹，按 **Ctrl+Shift+B** 编译并运行当前文件；
3. 右下角状态栏有 **「游戏引擎」** 按钮：点一下用引擎打开当前项目；命令面板还有「在引擎中运行当前项目」。

## 四门语言的写法（都实测过）

**C++**（`examples\cpp\你好.cpp`）
```cpp
#包含 <C标准输入输出>
整数 主函数() { 标准::格式化输出("你好\n"); 返回 0; }
```

**Python**（`examples\python\你好.py`）
```python
定义 斐波那契(第几项):
    如果 第几项 <= 1: 返回 第几项
    返回 斐波那契(第几项 - 1) + 斐波那契(第几项 - 2)
```

**Java**（`examples\java\你好.java`，只汉化关键字）
```java
公开 类型 你好 { 公开 静态 空型 main(String[] 参数) { System.out.println("你好"); } }
```

**TypeScript**（`examples\typescript\你好.ts`）
```ts
常量 问候: 字符串 = "你好";
控制台.日志(问候);
```

## 独立性声明（品牌与徽标）

- 本项目是**独立项目**，与 **Standard C++ Foundation / CppCon** 无任何隶属或背书关系。
- 本项目**不使用**、也不会使用 C++ 官方徽标的任何**修改版或衍生版**（包括"中文风"变体）。
  我方主图标是**自己设计的**（红底「中」字），与 C++ 官方徽标无关。
- 经 Standard C++ Foundation 书面确认：原封不动的官方徽标可以**放在自己图标旁边**展示，
  前提是不暗示背书；我方当前**不采用**这一做法。
- 本项目与 Microsoft、GitHub、Oracle、Eclipse Foundation、Python Software Foundation 等
  亦无隶属关系；文中出现的产品名仅用于指代被集成的上游技术。

## 许可与出处

- 编辑器基于 VS Code（MIT）；本项目修改部分归本项目。
- Chinese++：见 `toolchains\cpp\LICENSE*`。
- **ChinesePython**：原创部分采用自定义许可（禁止重新打包再发布），
  本包分发**已获著作权人明确授权**，凭据见 `分发授权.md`。
- **ChineseJava**：见 `toolchains\java\runtime\legal\`。
- **游戏引擎**基于 Godot（MIT），修改部分归本项目。
'@
[System.IO.File]::WriteAllText((Join-Path $根 '说明.md'), ($说明 -replace "`r?`n", "`n"), $enc)

# 引擎目录说明
$engMd = @'
# engine\ —— 中文大战代码（游戏引擎）

`中文大战代码.exe` 就是魔改 Godot（`4.7.2.stable.custom_build`），
与 `editor\` 里的代码编辑器同名同品牌。

- `中文大战代码_console.exe`：带控制台输出版本，调试用；
- `cdzc-open.ps1` / `打开编辑器.cmd`：**引擎 → 编辑器**的桥接脚本。
  在引擎的「外部编辑器」设置里指向 `打开编辑器.cmd`，flags 用 `{file} --line {line}`，
  引擎就会用中文大战代码打开当前脚本并定位到行。

**编辑器 → 引擎**：编辑器状态栏「游戏引擎」按钮（扩展 `cdzcgodot`），
会自动找安装目录下的 `engine\中文大战代码.exe`，找不到才回落设置项。
'@
[System.IO.File]::WriteAllText((Join-Path $engDir '说明.md'), ($engMd -replace "`r?`n", "`n"), $enc)

# ---------------------------------------------------------------- 汇总
Write-Host ''
Write-Host '=== 组装结果 ==='
foreach ($d in 'editor', 'toolchains\cpp', 'toolchains\python', 'toolchains\java', 'toolchains\typescript', 'engine', 'examples') {
	Write-Host ('  {0,-24} {1,8:N1} MB' -f $d, (大小 (Join-Path $根 $d)))
}
$全部 = Get-ChildItem $根 -Recurse -File -Force -ErrorAction SilentlyContinue
Write-Host ('  合计 ' + [math]::Round((($全部 | Measure-Object Length -Sum).Sum / 1MB), 1) + ' MB / ' + @($全部).Count + ' 文件')
if ($SkipEditor) { Write-Host '  （按参数跳过 editor\ 同步，构建.ps1 会负责它）' }
