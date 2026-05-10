# ==============================================
# 一键安装 Pwsh_config
# ==============================================

Write-Host "==> 一键安装 Pwsh_config 开始..." -ForegroundColor Cyan

# 1) 设置执行策略（允许脚本运行）
Write-Host "设置执行策略为 RemoteSigned ..."
Try {
    Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
} Catch {
    Write-Warning "未能修改执行策略，请以管理员身份运行 PowerShell"
}

# 2) 确保 Scoop 安装目录环境变量
$env:SCOOP = "$env:USERPROFILE\scoop"
Write-Host "SCOOP 安装路径设为： $env:SCOOP"

# 3) 安装 Scoop（如果未安装）
If (!(Get-Command scoop -ErrorAction SilentlyContinue)) {
    Write-Host "安装 Scoop 包管理器 ..."
    Invoke-RestMethod -Uri 'https://get.scoop.sh' | Invoke-Expression
} Else {
    Write-Host "Scoop 已存在，跳过安装"
}

# 4) 添加 Scoop bucket 并更新
scoop bucket add extras
scoop update

# 5) 安装基础工具
$pkgs = @(
    "git",
    "scoop-completion",
    "posh-git",
    "posh-docker",
    "ripgrep",
    "neovim",
    "pwsh",
    "starship"
)
Write-Host "开始安装软件包：" $pkgs
scoop install $pkgs

# 6) 配置 Starship 自动载入
If (Test-Path "$env:USERPROFILE\.config\starship.toml" -eq $false) {
    Write-Host "创建 Starship 配置目录..."
    New-Item -ItemType Directory -Force -Path "$env:USERPROFILE\.config" | Out-Null
}

# 7) 克隆配置仓库
$repoUrl  = "https://github.com/Eralala/Pwsh_config.git"
$cloneDir = "$env:TEMP\Pwsh_config"
If (Test-Path $cloneDir) { Remove-Item -Recurse -Force $cloneDir }
Write-Host "克隆配置仓库: $repoUrl"
git clone $repoUrl $cloneDir

# 8) 同步配置文件
Write-Host "同步 PowerShell 配置..."
Copy-Item -Force "$cloneDir\Microsoft.PowerShell_profile.ps1" "$PROFILE"

Write-Host "同步 Starship 配置..."
Copy-Item -Force "$cloneDir\starship.toml" "$env:USERPROFILE\.config\starship.toml"

# 9) 清理临时目录
Remove-Item -Recurse -Force $cloneDir

Write-Host ""
Write-Host "🎉 安装与配置完成！" -ForegroundColor Green
Write-Host "重启 PowerShell 以使配置生效" -ForegroundColor Yellow
