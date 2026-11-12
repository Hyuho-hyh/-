# HGhub Windows 安装与构建说明

GitHub 仓库中的部分图标以 `scripts/windows-assets.zip.b64` 合并存储。GitHub Actions 会自动还原；如果从 GitHub 下载源码后在本机构建，先在项目根目录执行 `powershell -NoProfile -ExecutionPolicy Bypass -File scripts/restore-binary-assets.ps1`。此前提供的完整源码 ZIP 已包含全部图标。

适用文件：你提供的 `study-materials-fork-main.zip`，包内版本为 1.2.1。

## 先分清两个文件

- 本次整理的 `HGhub-Windows-build-kit.zip` 是**源码与构建配置**，还不是安装包。
- GitHub 构建成功后下载的 `HGhub-Windows-x64.zip` 才包含安装 EXE 和可直接运行的 `HGhub.exe`。

你的源码有 Windows 打包配置，可以按 Tauri 客户端方式构建，无需服务器、宝塔、域名或数据库。当前检查环境已有 Microsoft Edge WebView2 Runtime，但未在命令路径及常见安装位置找到 Rust 工具链，因此本次没有进行实际 Windows 编译，也没有验证第三方接口或播放功能。

## 方式一：用 GitHub Actions 生成安装包

此方式在 GitHub 的 Windows 构建机上编译，无需先给本机安装 Rust 和 Visual Studio C++ 开发环境。

### 1. 准备源码

解压 `HGhub-Windows-build-kit.zip`。找到 `package.json` 所在的文件夹，这一层就是项目根目录。

本包保留原应用源码、锁文件和许可证，用一个仅手动触发的 Windows 工作流替换原有的多平台工作流，避免构建安卓时要求签名密钥，也避免触发原有的自动发布任务。没有修改应用功能。

### 2. 上传到自己的 GitHub 仓库

在 GitHub 新建一个**空仓库**，先不要自动添加 README、许可证或 `.gitignore`。

在解压后的项目根目录打开终端，执行以下命令。将远程地址替换成你自己的仓库地址：

```powershell
git init -b main
git add .
git commit -m "Prepare Windows build"
git remote add origin https://github.com/YOUR_USERNAME/YOUR_REPOSITORY.git
git push -u origin main
```

推送时按 Git 的提示登录自己的 GitHub 账号。若提交时报没有配置作者信息，可先在该项目内执行以下两行，再重试提交与推送：

```powershell
git config user.name "你的名字"
git config user.email "你的GitHub邮箱或GitHub提供的noreply邮箱"
```

上传后核对：仓库首页应直接看到 `package.json`、`src`、`src-tauri`、`.github`；不要把整个项目再套一层目录上传。工作流必须位于默认分支的 `.github/workflows/windows.yml`。

如果使用图形化 Git 工具，效果应与上述命令相同，并确保 `.github` 文件夹也被提交。

### 3. 手动构建

1. 打开 GitHub 仓库的 **Actions** 页面。
2. 如果仓库提示启用 Actions，先启用。
3. 在左侧选择 **Windows installer**。
4. 点击 **Run workflow**，选择 `main`，再点击确认运行。
5. 等待 **Build Windows x64** 成功。首次运行需要下载并编译依赖，耗时取决于 GitHub 构建机及网络。

### 4. 下载和安装

打开成功运行的详情页，在 **Artifacts** 区域下载 **HGhub-Windows-x64**。下载制品需要登录有该仓库读取权限的 GitHub 账号。

解压后有：

- 文件名中含 `setup` 的 EXE：Windows 安装程序，优先使用。
- `HGhub.exe`：可直接运行的程序，依赖 WebView2 Runtime。
- `LICENSE.txt`：原项目许可证与署名。
- `WINDOWS-INSTALL.txt`：安装说明。

本工作流将制品保存 14 天；请及时下载。它不会自动创建公开 Release。

## 方式二：在本机编译

先安装：

1. Node.js 22。
2. pnpm 10；已有 npm 时可执行 `npm install -g pnpm@10`。
3. Rust 1.90 或更高版本，使用 MSVC 工具链。
4. Microsoft Visual Studio C++ Build Tools，勾选“使用 C++ 的桌面开发”，包含 C++ 编译器和 Windows SDK。
5. Microsoft Edge WebView2 Runtime。

安装后重新打开终端，在项目根目录执行：

```powershell
node --version
pnpm --version
rustc --version
cargo --version
pnpm install --frozen-lockfile
pnpm app:dev
```

先验证桌面窗口能够启动。检查完成后关闭开发程序，执行：

```powershell
pnpm tauri build --bundles nsis
```

构建成功后：

- 安装包目录：`src-tauri/target/release/bundle/nsis/`。
- 主程序：`src-tauri/target/release/huangguo-client.exe`。

`pnpm dev` 只启动前端开发服务器；实际应用功能需要 `pnpm app:dev` 启动的 Tauri 环境。

## 验证范围与依赖

本次完成了项目结构、JSON 配置、图标引用和 Windows 构建流程检查；尚未执行依赖安装、Rust 编译、安装包运行或第三方数据源连通性测试，不能将本构建包视为已经通过运行验证的发行版。

应用的数据、图片和视频来自第三方服务。构建成功不能保证这些服务持续可用，包内也不包含独立的内容服务端。包内 `LICENSE` 标注为 PolyForm Noncommercial 1.0.0，具体条款以原文件为准。

参考官方文档：

- Tauri Windows 环境准备：https://v2.tauri.app/start/prerequisites/#windows
- GitHub 手动运行工作流：https://docs.github.com/en/actions/how-tos/manage-workflow-runs/manually-run-a-workflow
- GitHub 下载构建制品：https://docs.github.com/en/actions/how-tos/manage-workflow-runs/download-workflow-artifacts
