#!/bin/sh
###
# @Author: 梅继高
# @Date: 2022-05-11 13:24:28
 # @LastEditTime: 2022-05-27 00:52:00
 # @LastEditors: 梅继高
# @Description:
 # @FilePath: /JGSourceBase/JGSIntegrityCheck/JGSIntegrityCheckRecordResourcesHash.sh
# Copyright © 2022 MeiJiGao. All rights reserved.
###

#  JGSIntegrityResourcesHashRecord.sh
#  JGSourceBase
#
#  Created by 梅继高 on 2022/5/11.
#  Copyright © 2022 MeiJiGao. All rights reserved.

# 脚本用于进行iOS APP应用完整性校验
# 记录方案：
# 1、记录 .app 目录文件 hash, Info.plist 独立处理；包括循环递归处理子目录文件
# 2、记录 Info.plist key-value内容，替换plist文件xml标签，形成JSON文件
# 3、记录内容写入校验文件

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
ResourcesHashFileName="JGSApplicationIntegrityCheckFileHashFile"
ResourcesHashBase64Salt="JGSIntegrityCheck"

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
    "${ResourcesHashFileName}" # 校验记录文件
    "_CodeSignature"           # 通用签名文件
    "Assets.car"               # Assets文件，应用商店下载时商店对改文件做删减、优化
    "Frameworks"               # 依赖Frameworks包文件
    "PlugIns"                  # 扩展插件
    "embedded.mobileprovision" # 打包描述文件，上传商店商店会重签名打包导致文件变化
    "Info.plist"               # 根目录Info.plist商店包上传会增删改，独立记录文件内容，子目录不做任何记录处理
)

########## 方法定义 ##########
# 用户脚本过程实现具体功能
function appendContent2File() {
    local content="${1}"
    local file="${2}"
    # 考虑到plist文件处理为JSON数据时，需要移除容器最后元素结尾多余的逗号分隔符
    # 需要文件文本内容不换行，因此此处使用printf
    printf "${content}" >>"${file}"
}

function coverContent2File() {
    local content="${1}"
    local file="${2}"
    # 全文覆盖请使用echo，文本结束会输出换行
    # 使用shell脚本处理才不会遗漏最后一行
    echo "${content}" >"${file}"
}

function recordInfoPlistJSON() {

    ########## Info.plist处理逻辑 ##########
    # 根据plist文件特性，移除非必要标签、替换XML文件标签为JSON分隔符，构成标准JSON
    # ⚠️ 考虑key、value中可能存在英文引号情况，针对key、value均采用base64加密处理
    # ⚠️ 考虑不规范情况下key、value中可能存在换行情况，针对key、value处理分别匹配XML中的左右标签
    # 处理过程如下：
    # 1. 读取 Info.plist 文件内容为字符串
    # 2. 去除plist文件头 ?xml, !DOCTYPE, 及 <plist>, </plist> 标签
    # 3. 替换Dict、Array左右标签
    #   3.1 左标签直接替换为 "{" 或 "["，不需要添加其他分隔符号
    #   3.2 根节点的右标签直接替换，不需要添加其他分隔符号
    #   3.3 子节点右标签替换需要添加逗号","分隔符，对于容器结束元素可能存在分隔符多余情况，替换完成后统一处理
    # 4. 以上完成容器左右标签替换，接下来进行key、value的替换
    # 5. 逐行遍历处理经过上述步骤处理后的文本内容，每处理一段完整内容就追加写入临时文件，分别处理
    #   5.1 <key>...</key>
    #   5.2 <string>...</string>
    #   5.3 <integer>...</integer>
    #   5.4 <true/>, <false/>
    #   ⚠️ 首次写入临时文件前为避免文件残留，追加写入内容前先覆盖写空内容
    #   ⚠️ 替换过程如果左右标签在一行文本中，则直接 Base64 处理
    #   ⚠️ 如左右标签中间内容存在换行、空行情况，则识别到左标签时开始记录内容
    #   ⚠️ 中间未识别右标签，则逐行追加内容
    #   ⚠️ 识别到右标签时，完成标签内容记录，进行 Base64 处理
    # 6. 经以上步骤处理之后，基本形成完成的JSON数据，但是针对容器结尾元素存在多余逗号分隔符","问题，需进行替换
    #   6.1 替换 ",]" 为 "]"
    #   6.2 替换 ",}" 为 "}"
    # 7. 完成以上步骤后，Info.plist 文件处理完成，需要读取临时文件内容，之后删除临时文件

    local plistPath="${ProductDir}/${InfoPlistFile}"
    local tmpPlistJson="${ProductDir}/${ResourcesHashFileName}.${InfoPlistFile}.json"
    # rm -f "${tmpPlistJson}" # 清理异常过程残留文件内容
    coverContent2File "" "${tmpPlistJson}" # 写空数据，避免异常过程残留文件内容

    # 先替换整体内容中Array、Dict节点左右括号
    local fileContent=$(
        cat "${plistPath}" |          # 读取plist文件XML内容
            sed "/^<?xml.*$/d" |      # 删除plist文件头
            sed "/^<!DOCTYPE.*$/d" |  # 删除plist文件头
            sed "/^<plist.*$/d" |     # 删除<plist标签
            sed "/^<\/plist>/d" |     # 删除</plist>标签
            sed "s/<dict>$/{/g" |     # Dict根节点、子节点左标签
            sed "s/^<\/dict>$/}/g" |  # Dict根节点右标签
            sed "s/<\/dict>$/},/g" |  # Dict子节点右标签
            sed "s/<array>$/[/g" |    # Array根节点、子节点左标签，Array根节点做通用支持，项目中Info.plist一般不存在Array根节点
            sed "s/^<\/array>$/]/g" | # Array根节点右标签，Array根节点做通用支持，项目中Info.plist一般不存在Array根节点
            sed "s/<\/array>$/],/g"   # Array子节点右标签
    )

    # 为避免key、value中存在换行、英文引号等特殊情况
    # 对key、value进行逐行遍历拼接完整key、value并进行base64处理
    local tmpKeyValue=""
    # read方式需要文件文本内容以空行结束，否则遍历不到最后一行，因此此处使用echo而非printf
    echo "${fileContent}" | while read fileLine; do

        local readLine="${fileLine}"

        # Dict, Array节点标签替换内容
        if [[ "${readLine}" =~ "{" || "${readLine}" =~ "[" || "${readLine}" =~ "}" || "${readLine}" =~ "]" ]]; then
            tmpKeyValue=""
            appendContent2File "${readLine}" "${tmpPlistJson}"
            continue
        fi

        if [[ "${readLine}" == "" ]]; then
            # 空行
            # echo "empty line: ${readLine}"
            if [[ "${tmpKeyValue}" != "" ]]; then
                # echo "empty line pre: ${tmpKeyValue}"
                tmpKeyValue="${tmpKeyValue}\n"
            fi
            continue
        fi

        # <key>...</key>
        if [[ "${readLine}" =~ "key>" ]]; then

            if [[ "${readLine}" =~ "<key>" && "${readLine}" =~ "</key>" ]]; then

                local keyLine=$(
                    printf "${readLine}" |
                        sed "s/^<key>\(.*\)<\/key>$/\1/g" |
                        base64
                )

                tmpKeyValue=""
                appendContent2File "\"${keyLine}\":" "${tmpPlistJson}"

            elif [[ "${readLine}" =~ "</key>" ]]; then

                local keyLine=$(
                    printf "${tmpKeyValue}\n${readLine}" |
                        sed "s/\(.*\)<\/key>$/\1/g" |
                        base64
                )

                tmpKeyValue=""
                appendContent2File "\"${keyLine}\":" "${tmpPlistJson}"

            else

                local keyLine=$(
                    printf "${readLine}" |
                        sed "s/^<key>\(.*\)$/\1/g"
                )
                tmpKeyValue="${keyLine}"
                # echo "only left: ${readLine}, tmp => <${tmpKeyValue}>"

            fi
            continue
        fi

        # <string>...</string>
        if [[ "${readLine}" =~ "string>" ]]; then

            if [[ "${readLine}" =~ "<string>" && "${readLine}" =~ "</string>" ]]; then

                local valueLine=$(
                    printf "${readLine}" |
                        sed "s/^<string>\(.*\)<\/string>$/\1/g" |
                        base64
                )

                tmpKeyValue=""
                appendContent2File "\"${valueLine}\"," "${tmpPlistJson}"

            elif [[ "${readLine}" =~ "</string>" ]]; then

                local valueLine=$(
                    printf "${tmpKeyValue}\n${readLine}" |
                        sed "s/\(.*\)<\/string>$/\1/g" |
                        base64
                )

                tmpKeyValue=""
                appendContent2File "\"${valueLine}\"," "${tmpPlistJson}"

            else

                local valueLine=$(
                    printf "${readLine}" |
                        sed "s/^<string>\(.*\)$/\1/g"
                )
                tmpKeyValue="${valueLine}"
                # echo "only left: ${readLine}, tmp => ${tmpKeyValue}"
            fi
            continue
        fi

        # <integer>...</integer>
        if [[ "${readLine}" =~ "integer>" ]]; then

            if [[ "${readLine}" =~ "<integer>" && "${readLine}" =~ "</integer>" ]]; then

                local valueLine=$(
                    printf "${readLine}" |
                        sed "s/^<integer>\(.*\)<\/integer>$/\1/g" |
                        base64
                )

                tmpKeyValue=""
                appendContent2File "\"${valueLine}\"," "${tmpPlistJson}"

            elif [[ "${readLine}" =~ "</integer>" ]]; then

                local valueLine=$(
                    printf "${tmpKeyValue}${readLine}" |
                        sed "s/\(.*\)<\/integer>$/\1/g" |
                        base64
                )

                tmpKeyValue=""
                appendContent2File "\"${valueLine}\"," "${tmpPlistJson}"

            else

                local valueLine=$(
                    printf "${readLine}" |
                        sed "s/^<integer>\(.*\)$/\1/g"
                )
                tmpKeyValue="${valueLine}"
                # echo "only left: ${readLine}, tmp => ${tmpKeyValue}"
            fi
            continue
        fi

        # <true/> <false/>
        # bool处理为数字，iOS系统bool经脚本转换后为字符串数据，转换为数字后便于统一处理
        if [[ "${readLine}" =~ "<true/>" || "${readLine}" =~ "<false/>" ]]; then
            # bool值标签
            local valueLine=$(
                printf "${readLine}" |
                    sed "s/<true\/>/1/g" |
                    sed "s/<false\/>/0/g" |
                    base64
            )

            tmpKeyValue=""
            appendContent2File "\"${valueLine}\"," "${tmpPlistJson}"
            continue
        fi

        # 无标签情况
        if [[ "${tmpKeyValue}" != "" ]]; then
            tmpKeyValue="${tmpKeyValue}\n${readLine}"
        fi
    done

    # 删除数组、字典最后元素后的","
    sed -i '' 's/,]/]/g' "${tmpPlistJson}"
    sed -i '' 's/,}/}/g' "${tmpPlistJson}"

    # 读取临时文件内容，并删除临时文件
    printf "$(cat ${tmpPlistJson})"
    rm -f "${tmpPlistJson}"
}

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

            local resHash=$(shasum -a 256 "${realPath}" | cut -d ' ' -f1)
            local fileKey=$(printf "${relativePath}" | base64)
            local resline="\"${fileKey}\":\"${resHash}\","
            printf "${resline}"
        fi
    done
}

# 文件 Hash 记录脚本入口方法
function recordAPPResourceHashToCheckFile() {

    local directoryBeforeScript=$(pwd)
    cd "${ProductDir}"

    # 根目录Info.plist文件内容
    local plistName="Info.plist"
    local plistPath="${ProductDir}/${plistName}"
    local plistContent=$(printf "$(recordInfoPlistJSON "${plistPath}")" | base64)
    local plistKey=$(printf "${plistName}" | base64)
    local plistLine="\"${plistKey}\":\"${plistContent}\""

    # 其他所有资源文件Hash记录，仅包含多行 Key-Value 内容及行末逗号","
    local allResContent=$(recordResourceFilesHashInDir ".")

    # 拼接原始JSON，并Base64编码后翻转
    local JSONContent="{${allResContent}${plistLine}}"
    local JSONBase64=$(printf "${JSONContent}" | base64 | rev)

    # 校验内容收尾加盐后Base64编码
    local saltBase64=$(printf "${ResourcesHashBase64Salt}" | base64)
    local checkContent=$(printf "${saltBase64}${JSONBase64}${saltBase64}" | base64)

    # 覆盖写入记录文件
    local recordFilePath="${ProductDir}/${ResourcesHashFileName}"
    coverContent2File "${checkContent}" "${recordFilePath}" # 覆盖数据，避免异常过程残留文件内容

    cd "${directoryBeforeScript}"
}

echo "应用完整性校验资源文件Hash记录：Begin >>" $(date "+%Y%m%d %H:%M:%S")
recordAPPResourceHashToCheckFile
echo "应用完整性校验资源文件Hash记录：End >>" $(date "+%Y%m%d %H:%M:%S")
