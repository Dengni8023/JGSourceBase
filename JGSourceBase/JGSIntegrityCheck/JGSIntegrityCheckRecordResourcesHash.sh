#!/bin/sh
###
 # @Author: 梅继高
 # @Date: 2022-05-11 13:24:28
 # @LastEditTime: 2024-10-12 12:56:31
 # @LastEditors: Dengni8023 (Mei JiGao: 94583664@qq.com)
 # @Description:
 # @FilePath: /JGSourceBase/JGSourceBase/JGSIntegrityCheck/JGSIntegrityCheckRecordResourcesHash.sh
 # Copyright © 2022 MeiJiGao. All rights reserved.
###

#  JGSIntegrityResourcesHashRecord.sh
#  JGSourceBase
#
#  Created by 梅继高 on 2022/5/11.
#  Copyright © 2022 MeiJiGao. All rights reserved.

# 脚本用于进行iOS APP应用完整性校验
# 记录方案：
# 1、记录 .app 目录下文件 hash, Info.plist 独立处理；包括循环递归处理子目录文件
# 2、Info.plist内容转换为JSON文件内容
# 3、记录内容做加密混淆处理后写入校验文件

# 如果任何语句的执行结果不是true则退出，后续脚本不继续执行
# 退出可能无提示，如执行不存在的命令导致异常退出
# set -o errexit
# set -e

# bash 返回从右到左第一个以非0状态退出的管道命令的返回值，如果所有命令都成功执行时才返回0
# set -o pipefail

# 执行的语句结果不是true和0，bash将无法执行到检查的代码
# 执行检查
# command
# if [ $? -ne 0 ]; then
#     echo "command failed"
#     exit 1
# fi

########## 常量参数 ##########
ProductDir="${BUILT_PRODUCTS_DIR}/${PRODUCT_NAME}.app" # app包路径
ResourcesHashFileName="JGSAppIntegrityCheckFile"

# 通常情况 Info.plist 文件名为 "Info.plist"，可能存在被修改情况
# 被修改时需要外部传入文件名
InfoPlistFile="Info.plist"
if [[ "${1}" != "" ]]; then
    InfoPlistFile="${1}"
fi

########## 黑名单配置 ##########
# 资源文件hash记录默认记录根目录所有文件以及子目录特定后缀文件

# 默认忽略文件/文件夹
# 考虑忽略文件的灵活性，脚本中默认忽略部分文件，其他文件一律记录文件Hash
# Hash校验时配置忽略文件
ResExcludeFiles=(
    "${PRODUCT_NAME}"          # Target二进制文件
    "${ResourcesHashFileName}.json" # 校验记录文件
    "_CodeSignature"           # 通用签名文件
    "Assets.car"               # Assets文件，应用商店下载时商店对改文件做删减、优化
    "Frameworks"               # 依赖Frameworks包文件
    "PlugIns"                  # 扩展插件
    "embedded.mobileprovision" # 打包描述文件，上传商店商店会重签名打包导致文件变化
    "${InfoPlistFile}"         # 根目录Info.plist商店包上传会增删改，独立记录文件内容，子目录不做任何记录处理
)

########## 方法定义 ##########
FileResHashJSON="" # 使用全局变量记录，以便通过echo、print调试脚本
function recordResourceFilesHashInDir() {

    ########## 资源文件Hash记录逻辑 ##########
    # 读取本目录下所有文件，非文件夹文件记录文件 SHA256，文件夹则递归处理子目录文件
    # 文件Hash记录使用 Key-Value 形式记录到记录文件，其中：
    # Key：文件相对 .app 目录的相对路径
    # Value：文件 SHA256 码
    # 注意：
    # ⚠️ 脚本默认配置的黑名单文件不记录 Hash
    # ⚠️ 黑名单未区分子目录，仅按照文件/文件夹名称匹配
    # ⚠️ 为便于后续拼接JSON，每行 Key-Value 结束包含逗号","，格式为："Key":"Value",

    local relativeDir=$1
    local isSubPath=$([ "${relativeDir}" == "." ] && echo false || echo true)
    for entry in $(ls "${relativeDir}"); do

        local isBlack=false
        local relativePath=$([ "${relativeDir}" == "." ] && echo "${entry}" || echo "${relativeDir}/${entry}")
        local realPath="${ProductDir}/${relativePath}"
        for blackFile in "${ResExcludeFiles[@]}"; do
            if [[ "${blackFile}" == "${entry}" || "${blackFile}" == "${relativePath}" ]]; then
                isBlack=true
                break
            fi
        done

        if [[ "${isBlack}" == true ]]; then
            # echo "黑名单文件: ${relativePath}"
            continue
        fi

        if [[ -d ${realPath} ]]; then

            # 处理子目录
            recordResourceFilesHashInDir "${relativePath}"
            
        elif [[ -f ${realPath} ]]; then
            # 为避免文件名存在特殊字符，文件名进行base64编码
            local resHash=$(shasum -a 256 "${realPath}" | cut -d ' ' -f1)
            local resKey=$(printf "${relativePath}" | base64)
            local resline="\"${resKey}\":\"${resHash}\","
            # echo "${relativePath}: ${resline}"
            FileResHashJSON="${FileResHashJSON}${resline}"
        fi
    done
}

# 文件 Hash 记录脚本入口方法
function recordAPPResourceHashToCheckFile() {

    local directoryBeforeScript=$(pwd)
    cd "${ProductDir}"
    
    # 非Info.plist资源文件Hash记录，仅包含多行 Key-Value 内容及行末逗号","
    recordResourceFilesHashInDir "."
    
    # 根目录Info.plist文件内容转JSON
    local plistContent="{}"
    local plistPath="${ProductDir}/${InfoPlistFile}"
    if [[ -f ${plistPath} ]]; then
        local tmpPlistJson="${ProductDir}/${ResourcesHashFileName}-plist.json"
        plutil -convert json -o "${tmpPlistJson}" "${plistPath}"
        plistContent=$(cat "${tmpPlistJson}")
        rm -fr "${tmpPlistJson}" # 清理临时文件
    fi
    # echo "${InfoPlistFile}: ${plistContent}"
    # 资源文件文件名有base64编码，此处保持一致
    local plistKey=$(printf "${InfoPlistFile}" | base64)
    local plistLine="\"${plistKey}\":${plistContent}"
    
    # 拼接完整JSON结构，Base64编码后翻转
    local allResContent="{${FileResHashJSON}${plistLine}}"
    allResContent=$(printf "${allResContent}" | base64 | rev)
    
    # 校验内容首尾加盐后Base64编码
    local saltBase=$(printf "${ResourcesHashFileName}" | base64)
    local saltRev=$(printf "${saltBase}" | rev)
    # echo "saltBase-1: ${saltBase}"
    # echo "saltRev-1: ${saltRev}"
    saltBase=$(printf "${saltBase}" | sha256sum | cut -d ' ' -f1 | tr "[:lower:]" "[:upper:]")
    saltRev=$(printf "${saltRev}" | sha256sum | cut -d ' ' -f1 | tr "[:lower:]" "[:upper:]")
    # echo "saltBase-2: ${saltBase}"
    # echo "saltRev-2: ${saltRev}"
    local checkContent=$(printf "${saltBase}${allResContent}${saltRev}" | base64)

    # > 覆盖写入文件
    # >> 追加写入文件
    # 覆盖数据，避免异常过程残留文件内容
    # 全文覆盖请使用echo，文本结束会输出换行
    local recordFilePath="${ProductDir}/${ResourcesHashFileName}.json"
    echo "${checkContent}" > "${recordFilePath}"
    
    cd "${directoryBeforeScript}"
}

echo "应用完整性校验资源文件Hash记录：Begin >>" $(date "+%Y%m%d %H:%M:%S")
recordAPPResourceHashToCheckFile
echo "应用完整性校验资源文件Hash记录：End >>" $(date "+%Y%m%d %H:%M:%S")
