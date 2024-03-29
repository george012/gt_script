#!/bin/bash

set -e

REPO_USER=ACTION_BOT
PAT=""
REPO_SUFFIX=""
SAVE_DIR=""
APPOINT_RELEASE_NAME=""
APPOINT_ASSETS_FILE_NAME=""


get_repo_version_with_repo_suffix(){
    repo_version=$(echo $(curl --silent -u $REPO_USER:$PAT https://api.github.com/repos/$1/releases/latest) | jq -r '.name')
    echo $repo_version | tr -d '\r' | tr -d '\n'
}

function check_repo_need_update() {
    target_repo_version=$(get_repo_version_with_repo_suffix "$REPO_SUFFIX")
    remote_repo_version=$(get_repo_version_with_repo_suffix "$1")

    if [ "$(printf '%s\n' "$target_repo_version" "$remote_repo_version" | sort -Vr | head -n1)" = "$target_repo_version" ]; then
        echo "no"
    else
        echo "yes"
    fi
}

function get_repo_assign_version_with_repo_suffix(){
    repo_version=$(echo $(curl --silent -u $REPO_USER:$PAT https://api.github.com/repos/$1/releases/tags/$2) | jq -r '.name')
    echo $repo_version | tr -d '\r' | tr -d '\n'
}

function check_assign_version_repo_need_update() {
    target_repo_version=$(get_repo_assign_version_with_repo_suffix "$REPO_SUFFIX" "$2")
    remote_repo_version=$(get_repo_assign_version_with_repo_suffix "$1" "$2")

    if [ "$(printf '%s\n' "$target_repo_version" "$remote_repo_version" | sort -Vr | head -n1)" = "$target_repo_version" ]; then
        echo "no"
    else
        echo "yes"
    fi
}

function get_latest_releases_name() {
    remote_version=$(echo $(curl --silent -u $REPO_USER:$PAT https://api.github.com/repos/$REPO_SUFFIX/releases/latest) | jq -r '.name')
    echo $remote_version | tr -d '\r' | tr -d '\n'
}

function get_releases_upload_url() {
    upload_url=$(echo $(curl --silent -u $REPO_USER:$PAT https://api.github.com/repos/$REPO_SUFFIX/releases/tags/$APPOINT_RELEASE_NAME) | jq -r '.upload_url')
    echo $upload_url | tr -d '\r' | tr -d '\n'
}

function download_private_repo_asstes() {

    resInfo=$(curl --silent -u $REPO_USER:$PAT https://api.github.com/repos/$REPO_SUFFIX/releases/tags/$APPOINT_RELEASE_NAME)
    
    mkdir -p $SAVE_DIR

    echo "$resInfo" | jq -c '.assets[]' | while read asset; do
        asset_name=$(echo "$asset" | jq -r '.name')
        asset_id=$(echo "$asset" | jq -r '.id')
    
        if [ "$APPOINT_ASSETS_FILE_NAME" == "all" ]; then
            echo "Download Assets With $asset_name ID is: $asset_id"
            curl -H "Authorization: token $PAT" \
                -H 'Accept: application/octet-stream' \
                -LJO https://api.github.com/repos/$REPO_SUFFIX/releases/assets/$asset_id
            mv $asset_name $SAVE_DIR
        else
            if [ "$APPOINT_ASSETS_FILE_NAME" == "$asset_name" ]; then
                echo "Download Assets With $asset_name ID is: $asset_id"
                curl -H "Authorization: token $PAT" \
                    -H 'Accept: application/octet-stream' \
                    -LJO https://api.github.com/repos/$REPO_SUFFIX/releases/assets/$asset_id
                mv $asset_name $SAVE_DIR
            fi
        fi
    done
}

handle_input(){
    if [[ -z "$1" ]]; then
        echo "must input Function Name"
        return 1
    fi
    if [[ -z "$2" ]]; then
        echo "must input Github PAT"
        return 1
    fi
    if [[ -z "$3" ]]; then
        echo "must input REPO_SUFFIX, Simple With {owner}/{repo}"
        return 1
    fi

    PAT=$2
    REPO_SUFFIX=$3

    if [[ $1 == "-download_private_repo_asstes" ]]; then
        if [[ -z "$4" ]]; then
            echo "must Target Release Name"
            return 1
        fi
        if [[ -z "$5" ]]; then
            echo "must input Target Assets File Name"
            return 1
        fi
        if [[ -z "$6" ]]; then
            echo "must input Save With Dir"
            return 1
        fi

        APPOINT_RELEASE_NAME=$4
        APPOINT_ASSETS_FILE_NAME=$5
        SAVE_DIR=$6
        download_private_repo_asstes
    elif [[ $1 == "-get_latest_releases_name" ]]; then
        echo $(get_latest_releases_name)
    elif [[ $1 == "-get_releases_upload_url" ]]; then
        if [[ -z "$4" ]]; then
            echo "must Target Release Name"
            return 1
        fi
        APPOINT_RELEASE_NAME=$4
        echo $(get_releases_upload_url)
    elif [[ $1 == "-check_repo_need_update" ]]; then
        if [[ -z "$4" ]]; then
            echo "must Remote REPO_SUFFIX"
            return 1
        fi
        echo $(check_repo_need_update "$4")
    elif [[ $1 == "-check_repo_assign_version_need_update" ]]; then
        if [[ -z "$5" ]]; then
            echo "must Remote REPO_Version"
            return 1
        fi
        echo $(check_assign_version_repo_need_update "$4" "$5")
    fi
}

handle_input "$@"