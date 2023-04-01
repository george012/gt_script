function Parse-Json {
    param (
        [string]$Json,
        [string]$Key
    )
    $ParsedJson = $Json | ConvertFrom-Json
    return $ParsedJson.$Key
}

function Get-RepoVersion {
    param (
        [string]$Repo
    )
    $LatestReleaseInfo = Invoke-RestMethod -Uri "https://api.github.com/repos/$Repo/releases/latest"
    return $LatestReleaseInfo.tag_name
}

function Check-NeedBuild {
    param (
        [string]$RemoteVersion,
        [string]$ThisVersion
    )
    $NeedBuild = "no"
    if ($ThisVersion[0] -ne 'v') {
        $NeedBuild = "yes"
        return $NeedBuild
    }

    $RemoteVersionNoV = $RemoteVersion.Substring(1)
    $ThisVersionNoV = $ThisVersion.Substring(1)

    $SortedVersions = @($RemoteVersionNoV, $ThisVersionNoV) | Sort-Object { [Version]$_ }

    if ($RemoteVersionNoV -ne $SortedVersions[0]) {
        $NeedBuild = "yes"
    }
    return $NeedBuild
}

function Get-RepoLatestUploadUrl {
    param (
        [string]$Repo
    )
    $LatestReleaseInfo = Invoke-RestMethod -Uri "https://api.github.com/repos/$Repo/releases/latest"
    return $LatestReleaseInfo.upload_url
}

function Check-FileExistFromRepoLatest {
    param (
        [string]$Repo,
        [string]$FileName
    )
    $Response = Invoke-RestMethod -Uri "https://api.github.com/repos/$Repo/releases/latest"
    $AssetNames = $Response.assets.name

    $AssetExists = "no"
    foreach ($Name in $AssetNames) {
        if ($Name -eq $FileName) {
            $AssetExists = "yes"
            break
        }
    }
    return $AssetExists
}

# 示例：检查文件是否存在于指定仓库的最新版本中
$FileExists = Check-FileExistFromRepoLatest -Repo "george012/libhv-build" -FileName "libhv_linux_x64_arm64.zip"
Write-Output $FileExists
