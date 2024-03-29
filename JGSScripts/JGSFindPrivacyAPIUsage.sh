###
 # @Author: Dengni8023 (Mei JiGao: 94583664@qq.com)
 # @Date: 2024-03-27 09:38:50
 # @LastEditors: Dengni8023 (Mei JiGao: 94583664@qq.com)
 # @LastEditTime: 2024-03-27 20:03:45
 # @FilePath: /JGSourceBase/JGSScripts/JGSFindPrivacyAPIUsage.sh
 # @Description: 
 # 
 # Copyright © 2024 by Dengni8023, All Rights Reserved. 
### 

# 隐私设置功能
# 第三方 SDK 要求：https://developer.apple.com/cn/support/third-party-SDK-requirements/
# iOS17 隐私协议适配详解：https://juejin.cn/post/7329732000087425064

#递归搜索当前路径下是否包含传入的文件中的字符串，若包含打印路径。

# 脚本执行目录
# 如本地执行，脚本执行目录 与 脚本所在目录 可能存在差别
SRC_ROOT=$(cd "$(dirname "")"; pwd) # 脚本执行目录
echo "脚本执行目录: ${SRC_ROOT}"
SHELL_ROOT=$(cd "$(dirname "$0")"; pwd) # 脚本所在目录
echo "脚本所在目录: ${SHELL_ROOT}"

# 提示用户输入包含搜索字符串的文件路径
# read -p "请输入隐私API清单文件路径：" file_path
file_path="${SHELL_ROOT}/JGSFindPrivacyAPIs.txt"

# 检查文件是否存在
if [ ! -f "$file_path" ]; then
  echo "错误：文件不存在。"
  exit 1
fi

# 逐行读取文件中的搜索字符串，并执行搜索操作
while IFS= read -r searchAPI; do
  # 检查搜索字符串是否以 "----" 开头
  if [[ "$searchAPI" == ----* ]]; then
    echo "${searchAPI}"
  else
    # 检查搜索字符串是否为空或只包含空格
    if [ -n "$(echo "$searchAPI" | tr -d '[:space:]')" ]; then
      # 指定要搜索的目录为当前目录
      searchDir="${SRC_ROOT}/../JGSourceBase"

      # 对搜索字符串进行处理，确保空格被保留
      # 使用 printf 格式化字符串，%s 表示字符串
      formattedSearchAPI=$(printf "%s" "$searchAPI")
      
      # 使用 find 命令查找目录下的所有文件，并使用 grep 查找包含指定字符串的文件
      # -type f 表示只查找文件
      # -exec grep -H -i "$formattedSearchAPI" {} + 表示对每个找到的文件执行 grep 命令，输出包含匹配字符串的文件路径和匹配的行
      # result=$(find "$searchDir" -type f -exec grep -H -i "$formattedSearchAPI" {} +)
      result=$(find "$searchDir" -type f ! -path "build" ! -path "node_nodules" ! -path "*.xcodeproj" ! -path "*.xcworkspace" ! -path "Pods" ! -name "*.js*" ! -name "*.htm*" | xargs grep -s "$formattedSearchAPI")
        # 检查结果是否为空
        if [ -n "$result" ]; then
            echo "找到包含 ${formattedSearchAPI} 符串的文件："
            echo "$result"
            echo "------------------------end------------------------"
            echo ""
        # else
        #     echo "未找到包含 ${formattedSearchAPI} 字符串的文件。"
        #     echo "------------------------------------------------"
        #     echo ""
        fi
    fi
  fi
done < "$file_path"
