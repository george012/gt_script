<!-- TOC -->

- [1. 关闭ipv6](#1-关闭ipv6)
- [2. use`optimize_network`51200 concurrent](#2-useoptimize_network51200-concurrent)
- [3. use`install_docker`](#3-useinstall_docker)
- [4. use`install_redis`](#4-useinstall_redis)

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
