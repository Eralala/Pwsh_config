# PowerShell & Starship 配置同步

这是我的个人windows终端配置。  
通过本仓库，你可以在任意电脑上快速同步我的配置，获得统一的终端体验。

---

## 🛠 仓库内容

- `Microsoft.PowerShell_profile.ps1`  
  PowerShell 配置文件，用于设置别名、函数、环境变量等。
  
- `starship.toml`  
  Starship 提示符配置文件，用于美化终端提示符。

---

## ⚡ 配置同步流程

### 1. 准备环境

1. 安装 **Scoop**          
  ```bash
    Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
    $env:SCOOP = "安装路径"
    Invoke-RestMethod -Uri https://get.scoop.sh | Invoke-Expression
  ```
2. 安装 **Git**  
 ```bash
   scoop bucket add main
   scoop install main/git
 ```
4. 安装自动补全
  ```bash
     scoop bucket add extras && scoop install scoop-completion
     scoop install posh-git && scoop install posh-docker（docker补全）
     scoop install ripgrep（grep）
  ```
6. 安装 **neovim**
  ```bash
    scoop install main/neovim       
  ```
8. 安装 **PowerShell 7**
  ```bash
     scoop install main/pwsh
  ```   
10. 安装 **Starship**
  ```bash
     scoop install main/starship  
  ```
---
### 2. 同步配置

1. `code $PROFILE` 后复制PowerShell 配置文件内容
2. `code ~/.config/starship.toml` 后复制Starship 配置文件内容  

配置同步完成！
