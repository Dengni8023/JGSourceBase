#!/bin/sh
###
 # @Author: 梅继高
 # @Date: 2022-06-08 18:16:38
 # @LastEditTime: 2022-10-28 14:57:03
 # @LastEditors: 梅继高
 # @Description: 
 # @FilePath: /JGSourceBase/JGSScripts/JGSModifyConfigBeforeCompile.sh
 # Copyright © 2022 MeiJiGao. All rights reserved.
### 

# 修改 JGSourceBase.xcconfig 中 Version/Build 版本信息，会改变工程源码

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
# xcodebuild -alltargets clean

SHELL_ROOT=$(cd "$(dirname "$0")"; pwd) # 脚本所在目录
echo "脚本所在目录: $SHELL_ROOT"

# gitTag/tagDate 获取与 podspec 文件头部逻辑保持一致

# 使用 git 命令获取最新 tag
# gitTag = `git describe --abbrev=0 --tags 2>/dev/null`.strip
gitTag=`git describe --abbrev=0 --tags`
if [ "$?" -ne 0 ]; then
    gitTag="0.0.1"
fi

# 使用 git 命令获取 tag 对应的创建日期
tagDate=`git log -1 --pretty=format:%ad --date=format:%Y%m%d "${gitTag}"`
if [ "$?" -ne 0 ]; then
    tagDate=$(date "+%Y%m%d %H:%M:%S")
fi

# JGSourceBase.xcconfig 路径
ConfigFile="${PROJECT_DIR}/${TARGET_NAME}/JGSourceBase.xcconfig"
if [[ ! -f ${ConfigFile} ]]; then
    exit
fi

echo "Modify JGSourceBase.xcconfig"
sed -i '' 's/^\(JGSVersion = \).*/\1'"${gitTag}"'/'  "${ConfigFile}"
sed -i '' 's/^\(JGSBuild = \).*/\1'"${tagDate}"'/'  "${ConfigFile}"

# 此处不完整语句 Xcode 调试时会输出错误日志
# 用于 Xcode 调试显示错误日志信息，便于通过查看脚本输出调试脚本
# if
