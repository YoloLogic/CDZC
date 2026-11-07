<p align="center">
  <img src="banner.svg" width="100%" alt="中文大战代码 · CDZC">
</p>

| [🏠 首页](Home) | [💾 安装](安装与卸载) | [🖥️ 编辑器](代码编辑器) | [🎮 引擎](游戏引擎) | [🧰 工具链](四门工具链) | [⚠️ 已知问题](已知问题) |
|:---:|:---:|:---:|:---:|:---:|:---:|

<p align="center"><b>欢迎来到 中文大战代码 官方文档</b></p>

<p align="center"><sub>
一个品牌，两个程序：<b>代码编辑器</b> + <b>游戏引擎</b>，并自带四门汉语编程工具链。<br>
独立项目，与 Microsoft、GitHub、Oracle、Eclipse Foundation、Python Software Foundation、Standard C++ Foundation 均无隶属或背书关系。
</sub></p>

---

<p align="center">
<b>不 是 创 新 的 汉 语 编 程 ， 却 是 最 强 的 汉 语 编 程</b>
</p>

<p align="center">
  <a href="https://github.com/YoloLogic/CDZC/releases"><img src="https://img.shields.io/badge/%E4%B8%8B%E8%BD%BD-CZDZ--0.1--Setup.exe-C81E22?style=for-the-badge" alt="下载"></a>
  <a href="安装与卸载"><img src="https://img.shields.io/badge/%E5%AE%89%E8%A3%85-%E4%B8%A4%E5%88%86%E9%92%9F-2ea44f?style=for-the-badge" alt="安装"></a>
  <a href="已知问题"><img src="https://img.shields.io/badge/%E5%B7%B2%E7%9F%A5%E9%97%AE%E9%A2%98-10%20%E6%9D%A1-orange?style=for-the-badge" alt="已知问题"></a>
</p>

---

## 🧩 两个程序，一个名字

| | |
|:---:|:---:|
| <a href="代码编辑器"><img src="icons/编辑器.svg" width="72"><br><b>中文大战代码 · 代码编辑器</b></a><br><sub><code>editor\中文大战代码.exe</code></sub> | <a href="游戏引擎"><img src="icons/引擎.svg" width="72"><br><b>中文大战代码 · 游戏引擎</b></a><br><sub><code>engine\中文大战代码.exe</code></sub> |
| VS Code 1.142 分支，界面**源码级中文**（不是语言包） | 魔改 Godot 4.7.2（<code>custom_build</code>），界面中文，**自带 ChinesePython** |

> [!TIP]
> 两个程序互相唤起：编辑器右下角「游戏引擎」按钮 → 进引擎；引擎打开脚本 → 回编辑器并定位到行。

---

## 🔔 最近更新

<table>
<tr>
<td align="center" width="33%">
  <a href="https://github.com/YoloLogic/CDZC/releases"><img src="icons/下载.svg" width="64"><br><b>0.1 安装包</b></a><br><sub>373.6 MB · SHA256 已公布</sub>
</td>
<td align="center" width="33%">
  <a href="游戏引擎"><img src="icons/引擎.svg" width="64"><br><b>引擎自带 ChinesePython</b></a><br><sub><code>python314.dll</code> + <code>Lib</code> 走磁盘</sub>
</td>
<td align="center" width="33%">
  <a href="游戏引擎"><img src="icons/编辑器.svg" width="64"><br><b>引擎内置编辑器改成本产品</b></a><br><sub>改 Godot 源码，默认外部编辑器</sub>
</td>
</tr>
</table>

---

## 🧭 导航

### 产品

| | | | | | |
|:---:|:---:|:---:|:---:|:---:|:---:|
| <a href="代码编辑器"><img src="icons/编辑器.svg" width="60"><br><b>编辑器</b></a><br><sub>全中文</sub> | <a href="游戏引擎"><img src="icons/引擎.svg" width="60"><br><b>游戏引擎</b></a><br><sub>魔改 Godot</sub> | <a href="四门工具链"><img src="icons/编译.svg" width="60"><br><b>四门工具链</b></a><br><sub>C++/Py/Java/TS</sub> | <a href="安装与卸载"><img src="icons/安装.svg" width="60"><br><b>安装卸载</b></a><br><sub>一键干净</sub> | <a href="下载与校验"><img src="icons/下载.svg" width="60"><br><b>下载校验</b></a><br><sub>SHA256</sub> | <a href="已知问题"><img src="icons/报错.svg" width="60"><br><b>已知问题</b></a><br><sub>三类分开看</sub> |

### 文档

| | | | | | |
|:---:|:---:|:---:|:---:|:---:|:---:|
| <a href="https://github.com/YoloLogic/ChinesePlusPlus/wiki"><img src="icons/关键.svg" width="60"><br><b>Chinese++</b></a><br><sub>编译器文档</sub> | <a href="四门工具链"><img src="icons/标准库.svg" width="60"><br><b>示例工程</b></a><br><sub>Ctrl+Shift+B</sub> | <a href="四门工具链"><img src="icons/自检.svg" width="60"><br><b>自检</b></a><br><sub>29 项</sub> | <a href="已知问题"><img src="icons/诊断.svg" width="60"><br><b>设计边界</b></a><br><sub>不是 bug</sub> | <a href="代码编辑器"><img src="icons/仓库.svg" width="60"><br><b>内置扩展</b></a><br><sub>4 个</sub> | <a href="https://github.com/YoloLogic/CDZC"><img src="icons/边界.svg" width="60"><br><b>源码仓库</b></a><br><sub>GitHub</sub> |

---

## ⚡ 装完就能写

`cpp
#包含 <C标准输入输出>

整数 主函数() {
    标准::格式化输出("你好，中文大战代码！\n");
    返回 0;
}
`

`powershell
chinese++ -std=c++20 你好.cpp -o 你好.exe
.\你好.exe
`

> [!IMPORTANT]
> **C++ 需要本机的 Visual Studio Build Tools / Windows SDK**（当前 mode = system）。
> Python / Java / TypeScript 三条线不需要额外依赖。

---

<details>
<summary><b>🗂️ 包内布局 / 环境要求 / 卸载</b></summary>

`	ext
<安装目录>\
├─ editor\中文大战代码.exe          代码编辑器
├─ engine\中文大战代码.exe          游戏引擎（魔改 Godot）
├─ engine\addons\py4godot\          引擎自带 ChinesePython
├─ toolchains\cpp\                  Chinese++
├─ toolchains\python\               ChinesePython 3.14.7
├─ toolchains\java\runtime\         ChineseJava（只汉化关键字）
├─ toolchains\typescript\           ChineseTypeScript
├─ examples\                        四份可直接跑的示例
└─ 启动.cmd                         启动器（给本进程注入工具链 PATH）
`

| 项 | 要求 |
|---|---|
| 系统 | Windows 10/11 x64 |
| C++ | **Visual Studio Build Tools / Windows SDK** |
| Python/Java/TS | 无额外依赖 |

卸载：从「应用和功能」或开始菜单的「卸载 中文大战代码」。
**卸载后**目录、桌面快捷方式、开始菜单、应用列表登记项、以及写进 PATH 的 5 条工具链条目**全部清理干净**。

</details>