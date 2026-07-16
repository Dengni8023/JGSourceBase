#!/bin/sh
###
 # @Author: 梅继高
 # @Date: 2022-06-23 10:15:23
 # @LastEditTime: 2026-06-17 22:49:19
 # @LastEditors: Dengni8023
 # @Description: 
 # @FilePath: /JGSourceBase_spm/PodInstall.sh
 # Copyright © 2022 MeiJiGao. All rights reserved.
### 

WriteLogFile=false
function installPodsInDir() {
    podfileDir=$1
    InstallLog="PodInstallLog"
    if [[ "${podfileDir}" != "" ]]; then
        cd "./${podfileDir}"
    fi
    InstallLog="${InstallLog}.log"
    
    rm -fr Pods
    rm -fr "${InstallLog}"
    if [[ ${WriteLogFile} == true ]]; then
        pod install >> "${InstallLog}" # 输出日志文件
    else
        pod install # 不输出日志文件
    fi

    while [ $? -ne 0 ]; do
        echo "\n\n\nRetry: \"\$pod install\"\n\n\n"
        rm -fr "${InstallLog}"
        if [[ ${WriteLogFile} == true ]]; then
            pod install >> "${InstallLog}" # 输出日志文件
        else
            pod install # 不输出日志文件
        fi
    done
}

# echo "execute 'pod install' in root directory"
installPodsInDir "."
# echo "\n\n\n"
# echo "execute 'pod install' in 'JGSourceBaseDemo'"
# installPodsInDir "JGSourceBaseDemo"
