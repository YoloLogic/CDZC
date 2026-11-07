# 中文大战代码 · CDZC（Chinese Dazhan Code）

> **不是创新的汉语编程，却是最强的汉语编程。**

一个品牌，两个程序：**代码编辑器** + **游戏引擎**。开箱即可用中文写 C/C++、Python、Java、TypeScript，
以及在引擎里用 GDScript 的中文标识符 / ChinesePython 写游戏逻辑。

## 文档

- **Wiki（推荐）**：https://github.com/YoloLogic/CDZC/wiki
- 仓库内文档：[wiki/](wiki) · [docs/](docs)

## 下载

到 [Releases](../../releases) 下载 **[`CDZC-0.1-Setup.exe`](../../releases/download/v0.1/CDZC-0.1-Setup.exe)**（373.6 MB）。

- Windows 10/11 x64
- 安装包会问：装到哪、要不要桌面快捷方式、要不要加 PATH、要不要右键菜单
- 自带卸载程序，卸载会清干净（目录、快捷方式、开始菜单、应用列表、PATH 条目）

## 里面有什么

```
editor\中文大战代码.exe     代码编辑器（VS Code 1.142 分支，界面全中文）
engine\中文大战代码.exe     游戏引擎（魔改 Godot 4.7.2）
engine\addons\py4godot\     引擎自带的 ChinesePython（GDExtension）
toolchains\cpp\             Chinese++：C/C++ 中文关键字 + 中文报错 + clangd
toolchains\python\          ChinesePython 3.14.7：中文关键字 + 中文报错 + 中文标准库
toolchains\java\runtime\    ChineseJava：OpenJDK（只汉化关键字，标准库名保持英文）
toolchains\typescript\      ChineseTypeScript 0.2.4：chtsc + 自带 node
examples\                   cpp / python / java / typescript 四份可直接跑的示例
```

## 四门语言长什么样

```cpp
// C++
#包含 <C标准输入输出>
整数 主函数() { 标准::格式化输出("你好\n"); 返回 0; }
```

```python
# Python
定义 斐波那契(第几项):
    如果 第几项 <= 1: 返回 第几项
    返回 斐波那契(第几项 - 1) + 斐波那契(第几项 - 2)
```

```java
// Java（只汉化关键字，标准库名保持英文）
公开 类型 你好 { 公开 静态 空型 main(String[] 参数) { System.out.println("你好"); } }
```

```ts
// TypeScript
常量 问候: 字符串 = "你好";
控制台.日志(问候);            // 注意：遍历数组要用 `遍历`（for-of），`属于` 是 for-in
```

## 环境要求

| 语言 | 需要什么 |
|---|---|
| Python / Java / TypeScript | **不需要**额外依赖，装完即用 |
| **C++** | 需要本机的 **Visual Studio Build Tools / Windows SDK**（MSVC STL + UCRT）。当前发行版用 `mode = system`：不依赖 VS 的自足底座还没做完 |

## 已知问题

见 [docs/已知问题.md](docs/已知问题.md)。里面有按 P0/P1/P2 排的待修项、复现命令与归属，
以及一张「**不是 bug 的有意设计边界**」清单（例如 Java 的库类型名保持英文、诊断前缀保持英文）。

## 文档

- [产品说明](docs/产品说明.md)
- [分发授权](docs/分发授权.md) —— ChinesePython 随包分发已获著作权人授权
- [已知问题](docs/已知问题.md)

## 独立性声明

本项目是**独立项目**，与 Standard C++ Foundation / CppCon、Microsoft、GitHub、Oracle、
Eclipse Foundation、Python Software Foundation 均无隶属或背书关系。
主图标是**自己设计的**（红底「中」字），不使用任何 C++ 官方徽标的修改版或衍生版。
文中出现的产品名仅用于指代被集成的上游技术。

## 许可

- 编辑器基于 VS Code（MIT），修改部分归本项目；
- 引擎基于 Godot（MIT），修改部分归本项目；
- Chinese++ 见 `toolchains\cpp\LICENSE*`；
- ChineseJava 见 `toolchains\java\runtime\legal\`；
- **ChinesePython** 原创部分采用自定义许可（禁止重新打包再发布），本发行包分发已获授权，
  凭据见 [docs/分发授权.md](docs/分发授权.md)。