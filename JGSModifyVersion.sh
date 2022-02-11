###
 # @Author: 梅继高
 # @Date: 2022-02-11 11:09:12
 # @LastEditTime: 2022-02-11 12:59:31
 # @LastEditors: 梅继高
 # @Description: 
 # @FilePath: /JGSourceBase/JGSModifyVersion.sh
 # Copyright © 2021 MeiJigao. All rights reserved.
### 

#!/bin/sh

# 如果任何语句的执行结果不是true则退出
# set -o errexit
set -e

# bash 返回从右到左第一个以非0状态退出的管道命令的返回值，如果所有命令都成功执行时才返回0
set -o pipefail

# 执行的语句结果不是true和0，bash将无法执行到检查的代码
# 执行检查
command
if [ "$?" -ne 0 ]; then
    echo "command failed"
    exit 1
fi

InfoPlist=${PROJECT_DIR}/${TARGET_NAME}/Info.plist # Info.plist路径
echo ${InfoPlist}

# Build
# Build=$(date "+%Y%m%d%H%M") # 构建时间
Build=$(date "+%Y%m%d") # 构建时间
/usr/libexec/PlistBuddy -c "Set :CFBundleVersion ${Build}" ${InfoPlist}

# Version
# 查找 JGSourceBase.podspec 文件中 spec.version 的值
SpecFile=${PROJECT_DIR}/${PROJECT_NAME}.spec
if [[ ! -f ${SpecFile} ]]; then
    SpecFile=${PROJECT_DIR}/../JGSourceBase.podspec
fi

if [[ ! -f ${SpecFile} ]]; then
    exit
fi

# spec.version = 所在行内容
echo "SpecFile: ${SpecFile}"
SpecVersion=`sed -n '/^[ ]*spec.version[ ]*=[ ]*\"[0-9.]*\"$/p' ${SpecFile}`
echo "${SpecVersion}"
# 行内容获取版本号
Version=`echo ${SpecVersion} | sed 's/^[ ]*spec.version[ ]*=[ ]*\"\([0-9.]*\)\"$/\1/'`
echo "${Version}"
/usr/libexec/PlistBuddy -c "Set :CFBundleShortVersionString ${Version}" ${InfoPlist}

# 此处不完整语句 Xcode 调试时会输出错误日志
# 用于 Xcode 调试显示错误日志信息，便于通过查看脚本输出调试脚本
# if
