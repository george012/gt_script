<!-- TOC -->

- [1. 关闭ipv6](#1-关闭ipv6)
- [2. use`optimize_network`51200 concurrent](#2-useoptimize_network51200-concurrent)
- [3. use`install_docker`](#3-useinstall_docker)
- [4. use`install_redis`](#4-useinstall_redis)
- [4. use`get_github_repo_version_manager`（仅仅支持Github）](#4-useget_github_repo_version_manager仅仅支持github)
  - [Simple:](#simple)

<!-- /TOC -->

# 1. 关闭ipv6
```
ipv6的现有软件兼容性考虑
```

# 2. use`optimize_network`51200 concurrent
* Optimized to carry 51200 concurrency(优化至承载51200并发)
```
wget --no-check-certificate https://raw.githubusercontent.com/george012/gt_script/master/optimize_network.sh && chmod a+x ./optimize_network.sh && ./optimize_network.sh
```

# 3. use`install_docker`
```
wget --no-check-certificate https://raw.githubusercontent.com/george012/gt_script/master/install_docker.sh && chmod a+x ./install_docker.sh && ./install_docker.sh
```

# 4. use`install_redis`
```
wget --no-check-certificate https://raw.githubusercontent.com/george012/gt_script/master/install_redis.sh && chmod a+x ./install_redis.sh && ./install_redis.sh
```

# 4. use`get_github_repo_version_manager`（仅仅支持Github）
*   plase edit `$CURRENT_REPO_URI` `$REMOTE_REPO_URI`

```
wget --no-check-certificate https://raw.githubusercontent.com/george012/gt_script/master/install_redis.sh && chmod a+x ./install_redis.sh && ./install_redis.sh $CURRENT_REPO_URI $REMOTE_REPO_URI
```

## Simple:
*   simple: `$CURRENT_REPO_URI` = `github.com/currenttuser/current_repo`
*   simple: `$CURRENT_REPO_URI` = `github.com/remoteuser/remote_repo`
```
wget --no-check-certificate https://raw.githubusercontent.com/george012/gt_script/master/get_github_repo_version_manager.sh && chmod a+x ./get_github_repo_version_manager.sh && ./get_github_repo_version_manager.sh github.com/currenttuser/current_repo github.com/remoteuser/remote_repo
```