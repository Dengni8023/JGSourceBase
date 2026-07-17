#  
#
#  Created by Mei JiGao on 2026/6/26.
#  

# 修改 JGSourceBase.xcconfig 中 Version/Build 版本信息，会改变工程源码

# 如果任何语句的执行结果不是true则退出，后续脚本不继续执行
# 退出可能无提示，如执行不存在的命令导致异常退出
 set -o errexit
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

SHELL_ROOT=$(cd "$(dirname "$0")"; pwd) # 脚本所在目录
echo "脚本所在目录: $SHELL_ROOT"

# ${TARGET_NAME}.xcconfig 路径
ConfigFile="${PROJECT_DIR}/${PROJECT_NAME}/Target.xcconfig/${TARGET_NAME}.xcconfig"
echo "ConfigFile: ${ConfigFile}"
if [[ ! -f ${ConfigFile} ]]; then
    echo "Could not found ${TARGET_NAME}.xcconfig"
    exit
fi

# 根据 ${TARGET_NAME} 文件夹下文件最后修改时间生成相关配置信息
# 文件夹的最后更新时间与文件夹下所有文件的最后一次修改时间一致
ResourceDate=`stat -f "%Sm" -t "%Y%m%d.%H%M" "${PROJECT_DIR}/${TARGET_NAME}"`

# 构建时间
BuildDate=$(date "+%Y-%m-%d %H:%M:%S")
echo "
-------- Modify ${TARGET_NAME}.xcconfig --------
JGSDResourceDate: ${ResourceDate}
JGSDBuildDate: ${BuildDate}
-------- Modify ${TARGET_NAME}.xcconfig --------
"
sed -i '' 's/^\(JGSDResourceDate = \).*/\1'"${ResourceDate}"'/'  "${ConfigFile}"
sed -i '' 's/^\(JGSDBuildDate = \).*/\1'"${BuildDate}"'/'  "${ConfigFile}"

if [[ ${TARGET_NAME} == "JGSourceBaseDemo" ]]; then
    # 复制文件到Pods、SPM工程
    SrcDir="${PROJECT_DIR}/${TARGET_NAME}"
    PodsDstDir="${PROJECT_DIR}/../JGSourceBasePods/JGSourceBasePods"
    SPMDstDir="${PROJECT_DIR}/../JGSourceBaseSPM/JGSourceBaseSPM"
    CopyFiles=(
        "${SrcDir}/Classes"
        "${SrcDir}/Resources"
        "${SrcDir}/AppDelegate.swift"
        "${SrcDir}/Assets.xcassets"
        "${SrcDir}/Demo-Bridging-Header.h"
        "${SrcDir}/Info.plist"
        "${SrcDir}/OCViewController.h"
        "${SrcDir}/OCViewController.m"
        "${SrcDir}/SceneDelegate.swift"
        "${SrcDir}/ViewController.swift"
    )
    for file in "${CopyFiles[@]}"
    do
        echo "file: ${file}"
        cp -fr "${file}" "${PodsDstDir}"
        cp -fr "${file}" "${SPMDstDir}"
    done
fi
