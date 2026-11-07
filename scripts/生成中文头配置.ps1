# ============================================================================
#  生成中文头配置.ps1 —— 补齐 Chinese++ 发行包缺的两样东西
#
#  为什么需要：
#    ZIP 不保留硬链接，所以发行包里只剩 chinese++.exe / lld-link.exe 两个真身，
#    其余 9 个名字（clang.exe、clang-cl.exe、lld.exe…）丢了；
#    另外 bin\<driver>.cfg（记录 5 条中文头 -isystem 路径）也没生成 ——
#    结果是用户直接写 #包含 <C标准输入输出> 会报"找不到文件"，只有手工加 -I 才行。
#
#  这个脚本做两件事，幂等，可反复跑：
#    1) 用硬链接（失败则复制）把 9 个别名补回来
#    2) 生成 <driver>.cfg，内容是**绝对路径**（cfg 里相对路径不可靠，
#       反斜杠会被当转义，所以用正斜杠 + 引号包住）
#
#  用法：powershell -File 生成中文头配置.ps1 [-包根 <目录>]
# ============================================================================
param([string]$包根 = '', [ValidateSet('system','bundled')][string]$模式 = 'system')

$ErrorActionPreference = 'Continue'
if (-not $包根) { $包根 = $PSScriptRoot }
if (-not (Test-Path (Join-Path $包根 'bin'))) { $包根 = Split-Path $PSScriptRoot -Parent }
$bin = Join-Path $包根 'bin'
if (-not (Test-Path $bin)) { Write-Host ('找不到 bin：' + $bin); exit 1 }

Write-Host ('包根：' + $包根)

# ---------------------------------------------------------------- 1) 别名
Write-Host '--- 1) 补齐二进制别名（硬链接，失败则复制）'
$families = [ordered]@{
	'chinese++.exe' = @('clang.exe', 'clang++.exe', 'clang-cl.exe', 'clang-cpp.exe')
	'lld-link.exe'  = @('lld.exe', 'ld.lld.exe', 'wasm-ld.exe')
	'llvm-ar.exe'   = @('llvm-lib.exe', 'llvm-ranlib.exe')
	'llvm-rc.exe'   = @()
}
$linked = 0; $copied = 0; $kept = 0
foreach ($真身 in $families.Keys) {
	$target = Join-Path $bin $真身
	if (-not (Test-Path $target)) { Write-Host ('  跳过（缺真身）：' + $真身); continue }
	foreach ($别名 in $families[$真身]) {
		$p = Join-Path $bin $别名
		if (Test-Path $p) { $kept++; continue }
		try {
			New-Item -ItemType HardLink -Path $p -Target $target -ErrorAction Stop | Out-Null
			$linked++
		} catch {
			try { Copy-Item $target $p -ErrorAction Stop; $copied++ }
			catch { Write-Host ('  失败：' + $别名 + ' -> ' + $_.Exception.Message) }
		}
	}
}
Write-Host ('  新建硬链接 {0} 个、复制 {1} 个、已存在 {2} 个' -f $linked, $copied, $kept)

# ---------------------------------------------------------------- 2) cfg
Write-Host '--- 2) 生成 <driver>.cfg（中文头搜索路径）'
$zh = Join-Path $包根 'zhstdlib'
$目录 = @($zh, (Join-Path $zh '标准库'), (Join-Path $zh '别名'), (Join-Path $zh 'C运行库'), (Join-Path $zh 'windows系统'))
$存在 = $目录 | Where-Object { Test-Path -LiteralPath $_ }
if (-not $存在) { Write-Host ('  [警告] 没找到 zhstdlib：' + $zh); exit 1 }

$行 = New-Object System.Collections.Generic.List[string]
foreach ($d in $存在) {
	$行.Add('-isystem')
	$行.Add('"' + ($d -replace '\\', '/') + '"')
}
# bundled 模式：C++ 标准库头也必须从"包内"取，否则 <vector> 会跑到本机 VS 那边，
# 而"不需要装 Visual Studio"这句话就不成立了（verify.ps1 的第 3c 段就是查这个）。
$stl = Join-Path $包根 'lib\stl'
if ($模式 -eq 'bundled' -and (Test-Path -LiteralPath $stl) -and (Test-Path -LiteralPath (Join-Path $stl 'vector'))) {
	$行.Insert(0, '-nostdinc++')
	$行.Add('-isystem')
	$行.Add('"' + ($stl -replace '\\', '/') + '"')
}
$内容 = ($行 -join "`r`n") + "`r`n"

# clang 读的是 <可执行文件名>.cfg，所以每个别名都要有一份
$drivers = @('chinese++', 'clang', 'clang++', 'clang-cl', 'clang-cpp')
$写了 = 0
foreach ($d in $drivers) {
	$cfg = Join-Path $bin ($d + '.cfg')
	[System.IO.File]::WriteAllText($cfg, $内容, (New-Object System.Text.UTF8Encoding($false)))
	$写了++
}
Write-Host ('  写入 {0} 份 cfg（{1} 条 include 路径）' -f $写了, $存在.Count)

# 记录当前用的是哪套底座（bundled = 包内 STL；system = 本机 VS）
$tcTxt = Join-Path $bin 'toolchain.txt'
$现行 = ''
if (Test-Path $tcTxt) { $现行 = [System.IO.File]::ReadAllText($tcTxt) }
if (-not ([regex]::IsMatch($现行, 'mode\s*=\s*(bundled|system)'))) {
	# verify.ps1 用正则 mode\s*=\s*(\w+) 读这个文件，格式必须按它的来
	[System.IO.File]::WriteAllText($tcTxt, ("mode = " + $模式 + "`r`n"), (New-Object System.Text.UTF8Encoding($false)))
	Write-Host ('  写入 bin\toolchain.txt（mode = ' + $模式 + '）')
}

# ---------------------------------------------------------------- 3) 自检
Write-Host '--- 3) 自检：不带 -I 能不能找到中文头'
$cpp = Join-Path $bin 'chinese++.exe'
$tmp = Join-Path $env:TEMP ('cdzc-zhcfg-' + [guid]::NewGuid().ToString('N').Substring(0, 8))
New-Item -ItemType Directory -Force $tmp | Out-Null
$测试 = Join-Path $tmp '测试.cpp'
[System.IO.File]::WriteAllText($测试, "#包含 <C标准输入输出>`n整数 主函数() { 标准::格式化输出(`"zhcfg ok`"); 返回 0; }", (New-Object System.Text.UTF8Encoding($false)))
Push-Location $tmp
$out = (& $cpp -std=c++20 '测试.cpp' -o '测试.exe' 2>&1 | Out-String)
$码 = $LASTEXITCODE
Pop-Location
if ($码 -eq 0) {
	Write-Host '  [通过] 不带 -I 也能编译中文头'
} else {
	Write-Host '  [失败] 仍然找不到中文头：'
	($out -split "`r?`n" | Where-Object { $_ -match 'error|错误|找不到' } | Select-Object -First 3) | ForEach-Object { Write-Host ('    ' + $_.Trim()) }
}
Remove-Item -LiteralPath $tmp -Recurse -Force -ErrorAction SilentlyContinue
