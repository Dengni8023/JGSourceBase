#!/bin/sh

#  AggregateXCFramework.sh
#  
#
#  Created by Mei JiGao on 2026/6/16.
#  

echo ""

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

echo "ACTION=${ACTION}"
if [ "${ACTION}" != "build" ]; then
    exit
fi

# 要build的target名
Workspace="../${PROJECT_NAME}.xcworkspace"
echo "Workspace: ${Workspace}"

Project="${PROJECT_NAME}.xcodeproj"
echo "Project: ${Project}"

Scheme="${PROJECT_NAME}"
echo "Scheme: ${Scheme}"

# build之前clean一下
echo "build前清理Target"
xcodebuild -project "${Project}" clean -alltargets

# 真机build
echo "build真机设备架构包"
xcodebuild build \
-workspace "${Workspace}" \
-scheme ${Scheme} \
-configuration Release \
-sdk iphoneos \
OBJROOT="${OBJROOT}/DependentBuilds" \
BUILD_ROOT="${BUILD_ROOT}" \
BUILD_LIBRARY_FOR_DISTRIBUTION=YES \
SKIP_INSTALL=NO

# 模拟器build
echo "build模拟器架构包"
xcodebuild build \
-workspace "${Workspace}" \
-scheme ${Scheme} \
-configuration Release \
-sdk iphonesimulator \
OBJROOT="${OBJROOT}/DependentBuilds" \
BUILD_ROOT="${BUILD_ROOT}" \
BUILD_LIBRARY_FOR_DISTRIBUTION=YES \
SKIP_INSTALL=NO

# build相关常、变量定义
buildRootDir="${BUILT_PRODUCTS_DIR}/.." # build产出物文件夹路径
libOsDir="${buildRootDir}/Release-iphoneos" # build真机包路径
libSimDir="${buildRootDir}/Release-iphonesimulator" # build模拟器包路径
libOutputName="${Scheme}.framework" # 库名

Plist="${libOsDir}/${libOutputName}/Info.plist" # 构建framework中Info.plist路径
Version=$(/usr/libexec/PlistBuddy -c "Print :CFBundleShortVersionString" "${Plist}") # Version
Build=$(/usr/libexec/PlistBuddy -c "Print :CFBundleVersion" "${Plist}") # build

buildOutputDirName="${Scheme}" # 文件夹名称
buildOutputZipName="${Scheme}-${Version}-${Build}.zip" # zip文件名
buildOutputDir="${buildRootDir}/${buildOutputDirName}" # 聚合架构包输出文件夹路径

# 移除并重建输出目录
rm -fr "${buildRootDir}/${Scheme}-"* # 所有历史构建文件目录
rm -fr "${buildOutputDir}" # 本次构建文件目录
mkdir -p "${buildOutputDir}"

# ============================================================
# ============================================================
# ==================构建.xcFramework聚合架构包==================
# ============================================================
# ============================================================

# xcframework目录
XCOutputDir="${buildOutputDir}/${Scheme}.xcframework"

# .a包创建xcframework，需要分别为每个library指定headers
#xcodebuild -create-xcframework \
#-library "${libOsDir}/${libOutputName}" \
#-headers "${buildOutputDir}/Headers" \
#-library "${libSimDir}/${libOutputName}" \
#-headers "${buildOutputDir}/Headers" \
#-output "${XCOutputDir}"

echo "os: ${libOsDir}/${libOutputName}"
echo "sim: ${libSimDir}/${libOutputName}"

# .framework创建xcframework
xcodebuild -create-xcframework \
-framework "${libOsDir}/${libOutputName}" \
-framework "${libSimDir}/${libOutputName}" \
-output "${XCOutputDir}"

# cp 参数详解
# a：此参数常用于复制目录，它能保留源文件的链接和属性，并递归复制目录下的所有内容，其作用等同于dpR参数组合。
# d：在复制过程中保留源文件的链接，这里所说的链接类似于Windows系统中的快捷方式。
# f：此参数会使cp命令在覆盖已存在的目标文件时不给出任何提示。
# i：与-f参数相反，cp命令在覆盖目标文件之前会给出提示，要求用户确认是否覆盖，只有当用户回答"y"时，目标文件才会被覆盖。
# p：除了复制文件内容外，该参数还会将源文件的修改时间和访问权限一同复制到新文件中。
# r：当源文件是一个目录时，此参数将递归复制该目录下的所有子目录和文件。
# l：此参数使cp命令仅生成链接文件，而不实际复制文件内容。

echo "拷贝说明文件"
# 拷贝说明文件
DocSrc="${PROJECT_DIR}/.."
DocDest="${buildOutputDir}/Docs"
mkdir -p "${DocDest}/Resources"
cp -fr "${DocSrc}/README.md" "${DocDest}"
cp -fr "${DocSrc}/ChangeLog".* "${DocDest}"
#cp -a "${DocSrc}/MarkDownRes"/*.png "${DocDest}/MarkDownRes"

# # 清理中间产物
# echo "清理中间产物"
# rm -fr "${libOsDir}"
# rm -fr "${libSimDir}"

# 打开目标文件夹
echo "zip压缩打包文件"
cd "${buildOutputDir}"
zip -oqry "../${buildOutputZipName}" ./* # 保留软连接
echo "打开目标文件夹"
open "../${buildOutputDirName}"
