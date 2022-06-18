#!/bin/sh
###
 # @Author: 梅继高
 # @Date: 2022-04-15 13:20:30
 # @LastEditTime: 2022-06-08 18:13:02
 # @LastEditors: 梅继高
 # @Description: 
 # @FilePath: /JGSourceBase/JGSourceBaseDemo/JGSDemoScripts/JGSDemoModifyBuildAfterCompile.sh
 # Copyright © 2022 MeiJiGao. All rights reserved.
###

# 修改输出物目录下 Info.plist 中 Build 版本信息，不会改变工程源码
# 脚本之行需要入参指定打包输出物扩展名，支持 .app .framework

# 如果任何语句的执行结果不是true则退出，后续脚本不继续执行
# 退出可能无提示，如执行不存在的命令导致异常退出
# set -o errexit
# set -e

# bash 返回从右到左第一个以非0状态退出的管道命令的返回值，如果所有命令都成功执行时才返回0
set -o pipefail

# 执行的语句结果不是true和0，bash将无法执行到检查的代码
# 执行检查
command
if [ "$?" -ne 0 ]; then
    echo "command failed"
    exit 1
fi

ProductExt=$1
SupportExt=(app appex framework bundle)
if [[ ${SupportExt[@]/${ProductExt}/} != ${SupportExt[@]} ]]; then
    ProductExt=$1
else
    echo "打包输出物扩展名 "${ProductExt}" 错误，须传参: app/framework"
    exit
fi

# Info.plist路径
InfoPlist="${BUILT_PRODUCTS_DIR}/${PRODUCT_NAME}.${ProductExt}/Info.plist"
if [[ ! -f ${InfoPlist} ]]; then
    exit
fi

# Build=$(date "+%Y%m%d%H%M") # 构建时间
Build=$(date "+%Y%m%d") # 构建时间

git=$(which git)
if [[ ${git}'' == '' ]]; then
    git=$(sh /etc/profile; which git)
fi

if [[ ${git}'' != '' ]]; then
    latestHash=$(git rev-list HEAD -n1)
    if [[ ${latestHash}'' == '' ]]; then
        git=$(sh /etc/profile; which git)
        latestHash=$("${git}" rev-list HEAD -n1)
    fi
    if [[ ${latestHash}'' != '' ]]; then
        latestHash="${latestHash:0:7}"
        echo "latestHash: ${latestHash}"
        Build="${Build}.${latestHash}"
    fi
fi

PlistLINES=$(/usr/libexec/PlistBuddy ${InfoPlist} -c print | grep = | tr -d ' ')
HasField=false
for PLIST_ITEMS in $PlistLINES; do
    if [[ ${PLIST_ITEMS} =~ ^(CFBundleVersion=)(.*)$ ]]; then
        echo "CFBundleVersion: ${PLIST_ITEMS}"
        HasField=true
        break
    fi
done

if [[ "${HasField}" == true ]]; then
    /usr/libexec/PlistBuddy -c "Set :CFBundleVersion ${Build}" ${InfoPlist}
else
    /usr/libexec/PlistBuddy -c "Add :CFBundleVersion string ${Build}" ${InfoPlist}
fi

# 此处不完整语句 Xcode 调试时会输出错误日志
# 用于 Xcode 调试显示错误日志信息，便于通过查看脚本输出调试脚本
# if
