<!-- TOC -->

- [1. Tip](#1-tip)
- [2. 关闭ipv6](#2-关闭ipv6)
- [3. use`optimize_network`51200 concurrent](#3-useoptimize_network51200-concurrent)
- [4. use`install_docker`](#4-useinstall_docker)
- [5. use`install_redis`](#5-useinstall_redis)
- [6. use`github_repo_version_scan`（仅仅支持Github）](#6-usegithub_repo_version_scan仅仅支持github)
  - [6.1. 自动监测两个同步库是否需要更新](#61-自动监测两个同步库是否需要更新)
  - [6.2. 获取指定库的latest版本名称](#62-获取指定库的latest版本名称)
    - [6.2.1. Simple:](#621-simple)
  - [6.3. 获取指定库的latest版本upload\_url](#63-获取指定库的latest版本upload_url)
    - [6.3.1. Simple:](#631-simple)
  - [6.4. 检查latest版本assets中是否存在指定文件](#64-检查latest版本assets中是否存在指定文件)
    - [6.4.1. Simple--Linux:](#641-simple--linux)
    - [6.4.2. Simple--Windows](#642-simple--windows)
- [7. `Nginx` install to `Ubuntu`](#7-nginx-install-to-ubuntu)
- [7. `Ubuntu-20.0.4 LTS` Setup](#7-ubuntu-2004-lts-setup)
- [8. `auto_ssl` usege](#8-auto_ssl-usege)

<!-- /TOC -->

# 1. Tip
* 2. 仅支持`public` Gtihub Repo

# 2. 关闭ipv6
```
ipv6的现有软件兼容性考虑
```

# 3. use`optimize_network`51200 concurrent
* Optimized to carry 51200 concurrency(优化至承载51200并发)
```
wget --no-check-certificate https://raw.githubusercontent.com/george012/gt_script/master/optimize_network.sh && chmod a+x ./optimize_network.sh && ./optimize_network.sh
```

# 4. use`install_docker`
```
wget --no-check-certificate https://raw.githubusercontent.com/george012/gt_script/master/install_docker.sh && chmod a+x ./install_docker.sh && ./install_docker.sh
```

# 5. use`install_redis`
```
wget --no-check-certificate https://raw.githubusercontent.com/george012/gt_script/master/install_redis.sh && chmod a+x ./install_redis.sh && ./install_redis.sh
```

# 6. use`github_repo_version_scan`（仅仅支持Github）
## 6.1. 自动监测两个同步库是否需要更新
*   plase edit `$CURRENT_REPO_URI` `$REMOTE_REPO_URI`

```
wget --no-check-certificate https://raw.githubusercontent.com/george012/gt_script/master/github_repo_version_scan.sh && chmod a+x ./github_repo_version_scan.sh && ./github_repo_version_scan.sh --check_need_update $CURRENT_REPO_URI $REMOTE_REPO_URI
```

## 6.2. 获取指定库的latest版本名称
```
wget --no-check-certificate https://raw.githubusercontent.com/george012/gt_script/master/github_repo_version_scan.sh && chmod a+x ./github_repo_version_scan.sh && ./github_repo_version_scan.sh --get_latest_version $REMOTE_REPO_URI
```
### 6.2.1. Simple:
*   simple: `$CURRENT_REPO_URI` = `github.com/currenttuser/current_repo`
*   simple: `$CURRENT_REPO_URI` = `github.com/remoteuser/remote_repo`
```
wget --no-check-certificate https://raw.githubusercontent.com/george012/gt_script/master/github_repo_version_scan.sh && chmod a+x ./github_repo_version_scan.sh && ./github_repo_version_scan.sh --check_need_update github.com/currenttuser/current_repo github.com/remoteuser/remote_repo
```

## 6.3. 获取指定库的latest版本upload_url
### 6.3.1. Simple:
*   simple: `$CURRENT_REPO_URI` = `github.com/currenttuser/current_repo`
```
wget --no-check-certificate https://raw.githubusercontent.com/george012/gt_script/master/github_repo_version_scan.sh && chmod a+x ./github_repo_version_scan.sh && ./github_repo_version_scan.sh --get_latest_upload_url github.com/currenttuser/current_repo
```

## 6.4. 检查latest版本assets中是否存在指定文件
### 6.4.1. Simple--Linux:
```
wget --no-check-certificate https://raw.githubusercontent.com/george012/gt_script/master/github_repo_version_scan.sh && chmod a+x ./github_repo_version_scan.sh && ./github_repo_version_scan.sh --check_file_exist_from_repo_latest github.com/currenttuser/current_repo testfile.zip
```
### 6.4.2. Simple--Windows
```
Invoke-WebRequest -Uri https://raw.githubusercontent.com/george012/gt_script/master/github_repo_version_scan.ps1 -OutFile github_repo_version_scan.ps1
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
$file_exist = Check-FileExistFromRepoLatest -Repo "github.com/$env:GITHUB_REPOSITORY" -FileName "$env:over_file_name"
echo "file_exist=$file_exist" | Out-File -FilePath $env:GITHUB_ENV -Encoding utf8 -Append
```

# 7. `Nginx` install to `Ubuntu`
```
wget --no-check-certificate https://raw.githubusercontent.com/george012/gt_script/master/install_nginx.sh && chmod a+x ./install_nginx.sh && ./install_nginx.sh
```

# 7. `Ubuntu-20.0.4 LTS` Setup
```
wget --no-check-certificate https://raw.githubusercontent.com/george012/gt_script/master/setup_ubuntu20.sh && chmod a+x ./setup_ubuntu20.sh && ./setup_ubuntu20.sh
```

# 8. `auto_ssl` usege
```
wget --no-check-certificate https://raw.githubusercontent.com/george012/gt_script/master/auto_ssl.sh && chmod a+x ./auto_ssl.sh && ./auto_ssl.sh
```