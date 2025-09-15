#!/bin/sh
###
 # @Author: 梅继高
 # @Date: 2022-06-08 18:16:38
 # @LastEditTime: 2025-09-15 15:28:45
 # @LastEditors: Dengni8023
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

# JGSourceBase.xcconfig 路径
ConfigFile="${PROJECT_DIR}/JGSourceBase/JGSourceBase.xcconfig"
if [[ ! -d ${ConfigFile} ]]; then
    ConfigFile="${PROJECT_DIR}/../JGSourceBase/JGSourceBase.xcconfig"
fi
ConfigFile="${ConfigFile}/JGSourceBase.xcconfig"
echo "JGSourceBase.xcconfig: ${ConfigFile}"
if [[ ! -f ${ConfigFile} ]]; then
    echo "Could not found JGSourceBase.xcconfig"
    exit
fi

# lastGitTag/lastTagDate 获取与 podspec 文件头部逻辑保持一致
# 使用 git 命令获取最新 tag
# lastGitTag = `git describe --abbrev=0 --tags 2>/dev/null`.strip
lastGitTag=`git describe --abbrev=0 --tags`
if [ "$?" -ne 0 ]; then
    lastGitTag="0.0.1"
fi

# 使用 git 命令获取 tag 对应的创建日期
lastTagDate=`git log -1 --pretty=format:%ad --date=format:%Y%m%d "${lastGitTag}"`
if [ "$?" -ne 0 ]; then
    lastTagDate=$(date "+%Y%m%d %H:%M:%S")
fi

# 获取最后一次 commit 对应的日期
lastCommitDate=`git show --pretty=format:%ad --date=format:%Y%m%d | head -1`
lastCommitTime=`git show --pretty=format:%ad --date=format:%Y%m%d.%H%M%S | head -1`

# 获取最后一次提交的 commit Id, --short 指定获取短 ID
lastCommitID=`git rev-parse --short HEAD`
# lastCommitID=`git rev-parse HEAD`

# ⚠️ 执行脚本时，项目已经读取了 xcconfig 文件配置
# 因此针对 xcconfig 文件的修改，本次运行不生效
echo "
------------ Modify JGSourceBase.xcconfig ------------
lastGitTag: ${lastGitTag}
lastTagDate: ${lastTagDate}
lastCommitDate: ${lastCommitDate}
lastCommitTime: ${lastCommitTime}
lastCommitID: ${lastCommitID}
------------ Modify JGSourceBase.xcconfig ------------
"
# lastCommitTime="${lastTagDate}.${lastCommitDate}.${lastCommitID}"
sed -i '' 's/^\(JGSVersion = \).*/\1'"${lastGitTag}"'/'  "${ConfigFile}"
sed -i '' 's/^\(JGSBuild = \).*/\1'"${lastTagDate}"'/'  "${ConfigFile}"
sed -i '' 's/^\(JGSLastCommitDate = \).*/\1'"${lastCommitDate}"'/'  "${ConfigFile}"
sed -i '' 's/^\(JGSLastCommitTime = \).*/\1'"${lastCommitTime}"'/'  "${ConfigFile}"
sed -i '' 's/^\(JGSLastCommitID = \).*/\1'"${lastCommitID}"'/'  "${ConfigFile}"

# 此处不完整语句 Xcode 调试时会输出错误日志
# 用于 Xcode 调试显示错误日志信息，便于通过查看脚本输出调试脚本
# if
