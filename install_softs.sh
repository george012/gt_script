#!/bin/bash
set -e

SCRIPT_NAME=$(basename $0)
PROJECT_NAME=install_softs

install_redis(){
    wget --no-check-certificate https://raw.githubusercontent.com/george012/gt_script/master/install_redis.sh && chmod a+x ./install_redis.sh && ./install_redis.sh
}

install_docker(){
    wget --no-check-certificate https://raw.githubusercontent.com/george012/gt_script/master/install_docker.sh && chmod a+x ./install_docker.sh && ./install_docker.sh
}

install_nginx(){
    wget --no-check-certificate https://raw.githubusercontent.com/george012/gt_script/master/install_nginx.sh && chmod a+x ./install_nginx.sh && ./install_nginx.sh
}

echo "============================ ${PROJECT_NAME} ============================"
echo "  1、install Docker"
echo "  2、install Redis"
echo "  3、install nginx"
echo "======================================================================"
read -p "$(echo -e "请选择[1-3]：")" choose
case $choose in
1)
    install_redis && wait && rm -rf $SCRIPT_NAME
    ;;
2)
    install_docker && wait && rm -rf $SCRIPT_NAME
    ;;
2)
    install_nginx && wait && rm -rf $SCRIPT_NAME
    ;;
*)
    echo "输入错误，请重新输入！"
    ;;
esac