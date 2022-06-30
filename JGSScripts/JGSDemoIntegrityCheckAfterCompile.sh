#!/bin/sh
###
 # @Author: 梅继高
 # @Date: 2022-05-31 13:45:50
 # @LastEditTime: 2022-06-17 14:25:56
 # @LastEditors: 梅继高
 # @Description: 
 # @FilePath: /JGSourceBase/JGSourceBaseDemo/JGSDemoScripts/JGSDemoIntegrityCheckAfterCompile.sh
 # Copyright © 2022 MeiJiGao. All rights reserved.
###

# 执行 JGSIntegrity 提供的应用完整性校验资源文件记录脚本

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

echo "AfterCompile: 执行应用完整性校验-记录资源文件Hash脚本"

# bundle中shell脚本文件路径
JGSBundleDir="${BUILT_PRODUCTS_DIR}"
if [[ "${TARGET_NAME}" == "JGSourceBaseDemo" ]]; then
    JGSBundleDir="${BUILT_PRODUCTS_DIR}/JGSourceBase"
fi
ShellPath="${JGSBundleDir}/JGSourceBase.bundle/JGSIntegrityCheckRecordResourcesHash.sh"
# echo "${ShellPath}"
if [[ -f "${ShellPath}" ]]; then
    chmod +x ${ShellPath} # 脚本执行权限
    ${ShellPath} # 执行脚本
fi

# 此处不完整语句 Xcode 调试时会输出错误日志
# 用于 Xcode 调试显示错误日志信息，便于通过查看脚本输出调试脚本
# if
