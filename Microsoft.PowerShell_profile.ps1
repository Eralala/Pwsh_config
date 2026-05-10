# == set_proxy== 
function Set-Proxy {
    param(
        [int]$Port = 7897  # 默认端口
    )
    $proxyAddress = "http://127.0.0.1:$Port"
    $env:http_proxy  = $proxyAddress
    $env:https_proxy = $proxyAddress
    Write-Host "Proxy enabled: $proxyAddress"
}

function Unset-Proxy {
    Remove-Item Env:http_proxy -ErrorAction SilentlyContinue
    Remove-Item Env:https_proxy -ErrorAction SilentlyContinue
    Write-Host "Proxy disabled"
}
# $env:SCOOP = "E:\scoop"


# == starship(prompt) ==
$env:STARSHIP_CONFIG="$HOME\.config\starship.toml"
Invoke-Expression (&starship init powershell)


# ==set_complete==
Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete
# scoop bucket add extras && scoop install scoop-completion
Import-Module posh-git  # scoop install posh-git && scoop install posh-docker
Import-Module "$($(Get-Item $(Get-Command scoop.ps1).Path).Directory.Parent.FullName)\modules\scoop-completion"
# uv
(& uv generate-shell-completion powershell) | Out-String | Invoke-Expression


# ==set_color==
# PowerShell 7+
Set-PSReadLineOption -Colors @{ 
    # Parameter color when input
    Parameter = "#ff9e64" 
    Selection = "`e[1;35m"
    Type          = [ConsoleColor]::Yellow    # Type name
    Variable      = [ConsoleColor]::Magenta   # Variable name
    Operator = "white" 
    # Default = "`e[1;35m"
}


#==set_alias==
Set-Alias enable Set-Proxy
Set-Alias disable Unset-Proxy
Set-Alias rm Remove-Item
function which { param($name); scoop which $name }
function cat { param($name); scoop cat $name }
Set-Alias vim nvim
Set-Alias vi nvim
# scoop install ripgrep
Set-Alias g rg
Set-Alias c cls
Set-Alias note notepad
# rewrite ls
Remove-Item Alias:ls
function ls {
    $items = Get-ChildItem 
    # Helper function: convert bytes to readable units
    function Format-Size($bytes) {
        if ($bytes -ge 1TB) { "{0:0.0}T" -f ($bytes / 1TB) }
        elseif ($bytes -ge 1GB) { "{0:0.0}G" -f ($bytes / 1GB) }
        elseif ($bytes -ge 1MB) { "{0:0.0}M" -f ($bytes / 1MB) }
        elseif ($bytes -ge 1KB) { "{0:0.0}K" -f ($bytes / 1KB) }
        else { "$bytes" }
    }

    # Calculate total file size (ignoring folders)
    $totalBytes = ($items | Where-Object { -not $_.PSIsContainer } | Measure-Object Length -Sum).Sum
    Write-Host ("total file {0}" -f (Format-Size $totalBytes)) -ForegroundColor White

    # Calculate the number of commands in the pipeline
    $isPipe = ($MyInvocation.PipelineLength -gt 1)
        
    foreach ($item in $items) {
        # 1. Permissions
        $mode = $item.Mode
        # 2. Username
        $user = [Environment]::UserName
        # 3. File size
        $size = if ($item.PSIsContainer) { "-" } else { Format-Size $item.Length }
        # 4. Modification time
        $time = $item.LastWriteTime.ToString("MMM dd HH:mm", [System.Globalization.CultureInfo]::GetCultureInfo("en-US"))
        # 5. File name
        $name = $item.Name
        # 6. Set color
        $color = if ($item.PSIsContainer) { "Blue" } else { "White" }
        # Output
        $line = "{0} {1,2} {2,5} {3} {4}" -f $mode, $user, $size, $time, $name

        if( $isPipe ){
            # There is a pipe behind → Output plain text
            Write-Output $line
        }
        else{
            # Output the previous column in white
            Write-Host ("{0} {1,2} {2,5} {3}" -f $mode, $user, $size, $time) -ForegroundColor White -NoNewline

            # Output the file/folder name, folder in blue, file in white
            if ($item.PSIsContainer) {
                Write-Host (" {0}" -f $item.Name) -ForegroundColor Blue
            } else {
                Write-Host (" {0}" -f $item.Name) -ForegroundColor White
            }
        }
    }
}
# rewrite la
function la {
    $items = Get-ChildItem -Force
    # Helper function: convert bytes to readable units
    function Format-Size($bytes) {
        if ($bytes -ge 1TB) { "{0:0.0}T" -f ($bytes / 1TB) }
        elseif ($bytes -ge 1GB) { "{0:0.0}G" -f ($bytes / 1GB) }
        elseif ($bytes -ge 1MB) { "{0:0.0}M" -f ($bytes / 1MB) }
        elseif ($bytes -ge 1KB) { "{0:0.0}K" -f ($bytes / 1KB) }
        else { "$bytes" }
    }

    # Calculate total file size (ignoring folders)
    $totalBytes = ($items | Where-Object { -not $_.PSIsContainer } | Measure-Object Length -Sum).Sum
    Write-Host ("total file {0}" -f (Format-Size $totalBytes)) -ForegroundColor White

    # Calculate the number of commands in the pipeline
    $isPipe = ($MyInvocation.PipelineLength -gt 1)
        
    foreach ($item in $items) {
        # 1. Permissions
        $mode = $item.Mode
        # 2. Username
        $user = [Environment]::UserName
        # 3. File size
        $size = if ($item.PSIsContainer) { "-" } else { Format-Size $item.Length }
        # 4. Modification time
        $time = $item.LastWriteTime.ToString("MMM dd HH:mm", [System.Globalization.CultureInfo]::GetCultureInfo("en-US"))
        # 5. File name
        $name = $item.Name
        # 6. Set color
        $color = if ($item.PSIsContainer) { "Blue" } else { "White" }
        # Output
        $line = "{0} {1,2} {2,6} {3} {4}" -f $mode, $user, $size, $time, $name

        if( $isPipe ){
            # There is a pipe behind → Output plain text
            Write-Output $line
        }
        else{
            # Output the previous column in white
            Write-Host ("{0} {1,2} {2,5} {3}" -f $mode, $user, $size, $time) -ForegroundColor White -NoNewline

            # Output the file/folder name, folder in blue, file in white
            if ($item.PSIsContainer) {
                Write-Host (" {0}" -f $item.Name) -ForegroundColor Blue
            } else {
                Write-Host (" {0}" -f $item.Name) -ForegroundColor White
            }
        }
    }
}
# copy alias
function cp {
    param(
        [Parameter(Mandatory=$true)] [string]$src,
        [Parameter(Mandatory=$true)] [string]$dst
    )
    Copy-Item -Path $src -Destination $dst -Recurse -Force
}

# ==install micromamba==
# $env:MAMBA_EXE="E:\Apps\micromamba\micromamba.exe"
# $env:MAMBA_ROOT_PREFIX="E:\Apps\micromamba\mamba"
Set-Alias mm micromamba
function ma { micromamba activate @args }
function me { micromamba deactivate }