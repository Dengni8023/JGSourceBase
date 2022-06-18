#!/bin/sh
###
 # @Author: 梅继高
 # @Date: 2022-04-15 13:20:34
 # @LastEditTime: 2022-06-08 18:18:48
 # @LastEditors: 梅继高
 # @Description: 
 # @FilePath: /JGSourceBase/JGSScripts/JGSModifyVersionBeforeCompile.sh
 # Copyright © 2022 MeiJiGao. All rights reserved.
###

# 修改 Info.plist 中 Version/Build 版本信息，会改变工程源码

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

# 清除
xcodebuild -alltargets clean

SHELL_ROOT=$(cd "$(dirname "$0")"; pwd) # 脚本所在目录
echo "脚本所在目录: $SHELL_ROOT"

# 根据 JGSourceBase.podspec 文件中 spec.version 的值设置工程 Version
SpecFile=${SHELL_ROOT}/../JGSourceBase.podspec
if [[ ! -f ${SpecFile} ]]; then
    exit
fi

echo "SpecFile: ${SpecFile}"

# spec.version = 所在行内容，获取 spec.version
SpecVersion=$(sed -n '/^[ ]*spec.version[ ]*=[ ]*\"[0-9.]*\"$/p' ${SpecFile})
JGSVersion=$(echo ${SpecVersion} | sed 's/^[ ]*spec.version[ ]*=[ ]*\"\([0-9.]*\)\"$/\1/')
echo "spec.version: <${SpecVersion}> -> <${JGSVersion}>"

# JGSBuild => 所在行，获取 JGSBuild
SpecBuild=$(sed -n '/^[ ]*\"JGSBuild\"[ ]*=>[ ]*[\"].*\",$/p' ${SpecFile})
JGSBuild=$(echo ${SpecBuild} | sed 's/^[ ]*\"JGSBuild\"[ ]*=>[ ]*\"\(.*\)\",$/\1/')
echo "JGSBuild: <${SpecBuild}> -> <${JGSBuild}>"

# Info.plist路径
InfoPlist="${PROJECT_DIR}/${TARGET_NAME}/Info.plist"
if [[ ! -f ${InfoPlist} ]]; then
    exit
fi

PlistLINES=$(/usr/libexec/PlistBuddy ${InfoPlist} -c print | grep = | tr -d ' ')
HasField=false
for PLIST_ITEMS in $PlistLINES; do
    if [[ ${PLIST_ITEMS} =~ ^(CFBundleShortVersionString=)(.*)$ ]]; then
        echo "CFBundleShortVersionString: ${PLIST_ITEMS}"
        HasField=true
        break
    fi
done

echo "Modify Info.plist Version: ${Version}"
if [[ "${HasField}" == true ]]; then
    /usr/libexec/PlistBuddy -c "Set :CFBundleShortVersionString ${JGSVersion}" ${InfoPlist}
else
    /usr/libexec/PlistBuddy -c "Add :CFBundleShortVersionString string ${JGSVersion}" ${InfoPlist}
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

echo "Modify Info.plist Build: ${JGSBuild}"
if [[ "${HasField}" == true ]]; then
    /usr/libexec/PlistBuddy -c "Set :CFBundleVersion ${JGSBuild}" ${InfoPlist}
else
    /usr/libexec/PlistBuddy -c "Add :CFBundleVersion string ${JGSBuild}" ${InfoPlist}
fi

echo "Modify JGSourceBase.xcconfig"

# 此处不完整语句 Xcode 调试时会输出错误日志
# 用于 Xcode 调试显示错误日志信息，便于通过查看脚本输出调试脚本
# if