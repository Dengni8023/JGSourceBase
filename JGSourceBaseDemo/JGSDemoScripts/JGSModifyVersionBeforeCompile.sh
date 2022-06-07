#!/bin/sh
###
 # @Author: 梅继高
 # @Date: 2022-04-15 13:20:34
 # @LastEditTime: 2022-05-31 14:41:24
 # @LastEditors: 梅继高
 # @Description: 
 # @FilePath: /JGSourceBase/JGSourceBaseDemo/JGSDemoScripts/JGSModifyVersionBeforeCompile.sh
 # Copyright © 2022 MeiJiGao. All rights reserved.
### 

# 修改 Info.plist 中 Version 版本信息，会改变工程源码

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

# 根据 JGSourceBase.podspec 文件中 spec.version 的值设置工程 Version
SpecFile=${PROJECT_DIR}/../JGSourceBase.podspec
echo "SpecFile: ${SpecFile}"

if [[ ! -f ${SpecFile} ]]; then
    exit
fi

# spec.version = 所在行内容
echo "SpecFile: ${SpecFile}"
SpecVersion=$(sed -n '/^[ ]*spec.version[ ]*=[ ]*\"[0-9.]*\"$/p' ${SpecFile})
echo "${SpecVersion}"

# spec.version 行内容获取版本号
Version=$(echo ${SpecVersion} | sed 's/^[ ]*spec.version[ ]*=[ ]*\"\([0-9.]*\)\"$/\1/')
echo "${Version}"

# Info.plist路径
InfoPlist="${PROJECT_DIR}/${TARGET_NAME}/Info.plist"
if [[ ! -f ${InfoPlist} ]]; then
    exit
fi

PlistLINES=$(/usr/libexec/PlistBuddy ${InfoPlist} -c print | grep = | tr -d ' ')
HasBundleVersion=false
for PLIST_ITEMS in $PlistLINES; do
    if [[ ${PLIST_ITEMS} =~ ^(CFBundleShortVersionString=)(.*)$ ]]; then
        echo "CFBundleShortVersionString: ${PLIST_ITEMS}"
        HasBundleVersion=true
        break
    fi
done

if [[ HasBundleVersion ]]; then
    /usr/libexec/PlistBuddy -c "Set :CFBundleShortVersionString ${Version}" ${InfoPlist}
else
    /usr/libexec/PlistBuddy -c "Add :CFBundleShortVersionString string ${Version}" ${InfoPlist}
fi

# 此处不完整语句 Xcode 调试时会输出错误日志
# 用于 Xcode 调试显示错误日志信息，便于通过查看脚本输出调试脚本
# if
