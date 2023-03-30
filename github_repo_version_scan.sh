#!/bin/bash
set -e
SCRIPT_NAME=$(basename $0)

pre_config(){
    apt update && wait && apt install unzip zip wget logrotate
}

parse_json(){
    echo "${1//\"/}" | tr -d '\n' | tr -d '\r' | sed "s/.*$2:\([^,}]*\).*/\1/"
}

get_repo_version(){
    local REMOTE_REPO_VERSION=""
    local LATEST_RELEASE_INFO=$(curl --silent https://api.github.com/repos/$1/releases/latest)
    if ! echo "$LATEST_RELEASE_INFO" | grep -q "Not Found"; then
        REMOTE_REPO_VERSION=$(parse_json "$LATEST_RELEASE_INFO" "tag_name")
    fi
    echo $REMOTE_REPO_VERSION | tr -d '\r\n'
}

check_need_build(){
    remote_version=$2
    this_version=$1
    if [[ ${this_version:0:1} != "v" ]]; then
        echo "true" | tr -d '\r\n'
        return
    fi

    remote_version_no_v=${remote_version:1}
    this_version_no_v=${this_version:1}
    sorted_versions=$(echo -e "$remote_version_no_v\n$this_version_no_v" | sort -V)

    small_version=$(echo "$sorted_versions" | head -n1)
    if [ "$remote_version_no_v" != "$small_version" ]; then
        echo "true" | tr -d '\r\n'
        return
    fi
    echo "false" | tr -d '\r\n'
}

handle_input(){
    if [[ $1 == "--check_need_update" ]]; then
        local current_repo_rul=$2
        local remote_repo_url=$3


        if [[ $current_repo_rul == "" ]] || [[ $current_repo_rul == " " ]] || [[ $remote_repo_url == "" ]] || [[ $remote_repo_url == " " ]]; then
            echo "{\"code\":-1,\"msg\":\"Input Prarms Error：Prarms Cannot Be Empty\"}"
            return
        fi

        if [[ $(echo "$current_repo_rul" | cut -d'/' -f1) != "github.com" ]] || [[ $(echo "$remote_repo_url" | cut -d'/' -f1) != "github.com" ]]; then
            echo "{\"code\":-1,\"msg\":\"This Script Only github.com is supported\"}"
            return
        fi

        local current_repo_suffix=$(echo "$current_repo_rul" | cut -d'/' -f2-)
        local remote_repo_suffix=$(echo "$remote_repo_url" | cut -d'/' -f2-)

        local current_repo_latest_version=$(get_repo_version "$current_repo_suffix")
        if [[ $current_repo_latest_version == "" ]] || [[ $current_repo_latest_version == " " ]]; then
            echo "true" | tr -d '\r\n'
            return
        fi

        local remote_repo_latest_version=$(get_repo_version "$remote_repo_suffix")

        check_need_build "$current_repo_latest_version" "$remote_repo_latest_version"
    elif [[ $1 == "--get_latest_version" ]]; then
        local latest_version=$(get_repo_version "$2")
        echo $latest_version
    else
        echo "{\"code\":-1,\"msg\":\"Methods not yet supported\"}"
    fi
}

handle_input "$@"