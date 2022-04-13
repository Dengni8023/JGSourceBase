#!/bin/sh
###
 # @Author: 梅继高
 # @Date: 2022-04-13 21:29:56
 # @LastEditTime: 2022-04-13 21:35:53
 # @LastEditors: 梅继高
 # @Description: 
 # @FilePath: /JGSourceBase/JGSCopyResources.sh
 # Copyright © 2021 MeiJiGao. All rights reserved.
### 

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

# 本脚本用于 JGSourceBase.framework 向framework 包拷贝资源文件
# 拷贝 JGSDevice 资源文件
JGSDeviceRes=${PROJECT_DIR}/JGSDevice/Resources/iOSDeviceList.json
cp -f ${JGSDeviceRes} ${BUILT_PRODUCTS_DIR}/${TARGET_NAME}.framework

# 此处不完整语句 Xcode 调试时会输出错误日志
# 用于 Xcode 调试显示错误日志信息，便于通过查看脚本输出调试脚本
# if
