#
#  Be sure to run 'pod spec lint JGSourceBase.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see https://guides.cocoapods.org/syntax/podspec.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |spec|

  # ―――  Spec Metadata  ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  These will help people to find your library, and whilst it
  #  can feel like a chore to fill in it's definitely to your advantage. The
  #  summary should be tweet-length, and the description more in depth.
  #

  # CocoaPods - Podspec文件配置讲解: https://www.jianshu.com/p/743bfd8f1d72
  def self.ios_version
    "12.0" # iOS最低支持版本
  end
  def self.osx_version
    "13.0" # osx最低支持版本
  end
  def self.smart_host
    # 网络防火墙问题，优先使用 Gitee
    "github.com"
    # "gitee.com"
  end
  def self.smart_version
    # tag = `git describe --abbrev=0 --tags 2>/dev/null`.strip
    tag = `git describe --abbrev=0 --tags`
    if $?.success? then tag else "0.0.1" end
  end
  def self.version_date
    date = `git log -1 --pretty=format:%ad --date=format:%Y%m%d #{smart_version}`
    date
  end
  
  spec.name         = "JGSourceBase" # (必填) 库的名字
  spec.version      = smart_version # (必填) 库的版本号
  spec.summary      = "JGSourceBase functional component library." # (必填) 库描述
  
  # (选填) 标记库是否被废弃
  # spec.deprecated = true
  # (选填) 标明库的名字被废弃
  # spec.deprecated_in_favor_of = "JGSourceCodeBase"

  # (必填) 库详细描述
  # This description is used to generate tags and improve search results.
  #   * Think: What does it do? Why did you write it? What is the focus?
  #   * Try to keep it short, snappy and to the point.
  #   * Write the description between the DESC delimiters below.
  #   * Finally, don't worry about the indent, CocoaPods strips it!
  spec.description  = <<-DESC
  JGSourceBase 通用功能组件库。
  功能包括：
  1. Base - 通用定义、功能模块、iOS项目常用功能
  2. Category - 通用扩展方法定义
  3. DataStorage - 通用数据持久化功能
  4. Device - iOS设备相关方法
  5. Encryption - 常用加解密方法
  6. HUD - Loading-HUD、Toast-HUD显示
  7. IntegrityCheck - iOS应用完整性校验
  8. Reachability - 网络状态监听，支持多观察着/监听者
  9. SecurityKeyboard - 自定义安全键盘
                   DESC
  
  # (必填) pod首页地址
  spec.homepage     =  "https://#{smart_host}/dengni8023/JGSourceBase"
  # (选填)
  # spec.screenshots  = "www.example.com/screenshots_1.gif", "www.example.com/screenshots_2.gif"
  # (选填) readme文件地址
  # spec.readme = "https://#{smart_host}/dengni8023/JGSourceBase"
  # (选填) changelog文件地址
  # spec.changelog = "https://#{smart_host}/dengni8023/JGSourceBase"
  # (选填) 库的文档url
  # spec.documentation_url
  
  # ―――  Spec License  ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  Licensing your code is important. See https://choosealicense.com for more info.
  #  CocoaPods will detect a license file if there is a named LICENSE*
  #  Popular ones are 'MIT', 'BSD' and 'Apache License, Version 2.0'.
  #

  # (必填) 许可证
  # spec.license      = "MIT (LICENSE.md)"
  spec.license      = {
    :type => "MIT",
    :file => "./JGSourceBase/JGSourceBase.docc/LICENSE.md"
  }
  
  # ――― Author Metadata  ――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  Specify the authors of the library, with email addresses. Email addresses
  #  of the authors are extracted from the SCM log. E.g. $ git log. CocoaPods also
  #  accepts just a name if you'd rather not provide an email address.
  #
  #  Specify a social_media_url where others can refer to, for example a twitter
  #  profile URL.
  #

  # (必填) 作者信息
  spec.author             = {
    "Dengni8023" => "945835664@qq.com",
  }
  # Or just: spec.author    = "Dengni8023"
  # spec.authors            = { "Dengni8023" => "945835664@qq.com" }
  # (选填) 作者第三方社交平台url
  # spec.social_media_url   = "https://twitter.com/Dengni8023"

  # ――― Platform Specifics ――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  If this Pod runs only on iOS or OS X, then specify the platform and
  #  the deployment target. You can optionally include the target after the platform.
  #

  #  (选填) 支持的Swift版本。CocoaPods会将“4”视为“4.0”，而不是“4.1”或“4.2”。
  # 不配置时，CocoaPods 会根据用户项目的 Swift 版本自动选择合适的版本
  # spec.swift_version = "5.6"
  # https://docs.swift.org/swift-book/documentation/the-swift-programming-language/revisionhistory/
  # 2021/09/20 Swift 5.5: Xcode 13.0
  # 2022/09/12 Swift 5.7: Xcode 14.0
  # 2023/09/18 Swift 5.9: Xcode 15.0
  # 2024/09/23 Swift 6: Xcode 16.0
  # spec.swift_versions = ["5.6", "5.7", "5.8", "5.9", "5.10"]

  #  (选填) 支持的CocoaPods版本
  spec.cocoapods_version = '>= 1.10'
  
  # spec.platform     = :ios
  spec.platform     = :ios, "#{ios_version}" # 指定最低支持 iOS 版本
  
  #  When using multiple platforms
  # spec.ios.deployment_target = "5.0"
  # spec.osx.deployment_target = "10.7"
  # spec.watchos.deployment_target = "2.0"
  # spec.tvos.deployment_target = "9.0"

  # (必填) 源文件地址
  # ――― Source Location ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  Specify the location from where the source should be retrieved.
  #  Supports git, hg, bzr, svn and HTTP.
  #
  spec.source = { :git => "https://#{smart_host}/dengni8023/JGSourceBase.git", :tag => "#{spec.version}" }
  
  # ――― Source Code ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  CocoaPods is smart about how it includes source code. For source files
  #  giving a folder will include any swift, h, m, mm, c & cpp files.
  #  For header files it will include any header in the folder.
  #  Not including the public_header_files will make all headers public.
  #

  # spec.source_files  = "Classes", "Classes/**/*.{h,m,swift}"
  # spec.exclude_files = "Classes/Exclude"

  # spec.public_header_files = "Classes/**/*.h"

  # spec.source_files = "#{spec.name}/*.{h,m,swift}"
  # spec.public_header_files = "#{spec.name}/*.h"
  
  # 不推荐使用prefix_header，如果使用了，需要在podspec中指定
  # spec.prefix_header_file = "#{spec.name}/Prefix-Header.pch"
  
  # 如果OC需要访问Swift代码，需要modulemap
  spec.module_map = "#{spec.name}/JGSourceBase.modulemap"

  # ――― Resources ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  A list of resources included with the Pod. These are copied into the
  #  target bundle with a build phase script. Anything else will be cleaned.
  #  You can preserve files from being cleaned, please don't preserve
  #  non-essential files like tests, examples and documentation.
  #

  # spec.resource  = "icon.png"
  # spec.resources = "Resources/*.png"

  # spec.preserve_paths = "FilesToSave", "MoreFilesToSave"


  # ――― Project Linking ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  Link your library with frameworks, or libraries. Libraries do not include
  #  the lib prefix of their name.
  #

  # spec.framework  = "SomeFramework"
  # spec.frameworks = "SomeFramework", "AnotherFramework"

  # spec.library   = "iconv"
  # spec.libraries = "iconv", "xml2"


  # ――― Project Settings ――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  If your library depends on compiler flags you can set them in the xcconfig hash
  #  where they will only apply to your library. If you depend on other Podspecs
  #  you can include multiple dependencies to ensure it works.

  # (选填) 是否使用静态库
  # 如果 Podfile 指明了 use_frameworks! 命令，是否以静态framework的形式构建
  # use_frameworks! 默认构建动态链接库
  # use_frameworks! :linkage => :dynamic # 使用动态链接库
  # use_frameworks! :linkage => :static # 使用静态链接库
  # 设置为 true，在Podfile使用 use_frameworks!指定动态链接库时，仍旧打包静态库
  # 由于存在bundle资源使用，在动态链接库中，无法直接使用到framework内的bundle资源
  spec.static_framework = true
  # requires_arc允许指定哪些source_files使用ARC。可以设置为true表示所有source_files使用ARC。
  # 不使用ARC的文件会有-fno-objc-arc编译标志。
  spec.requires_arc = true
  
  # modify info.plist
  # Only work for framework
  # spec.info_plist = {
  #   "CFBundleShortVersionString" => "#{spec.version}",
  #   "CFBundleVersion" => "#{spec.version}",
  # }

  # 主工程配置
  spec.user_target_xcconfig = {
    # 解决新版本pod lib lint等检测因项目无Info.plist文件而失败问题
    # 'GENERATE_INFOPLIST_FILE' => 'YES',
    # Xcode15之后默认配置为YES，限制了编译构建期间sh脚本执行
    'ENABLE_USER_SCRIPT_SANDBOXING' => 'NO',
  }
  
  spec.pod_target_xcconfig = {
    "PRODUCT_BUNDLE_IDENTIFIER" => "com.meijigao.#{spec.name}",
    "MARKETING_VERSION" => "#{spec.version}",
    "CURRENT_PROJECT_VERSION" => "#{spec.version}",
    # 'GENERATE_INFOPLIST_FILE' => 'YES', # Xcode 新建项目 Target 默认配置为 YES
    # 'DEFINES_MODULE' => 'NO', # Xcode 新建项目 Target 默认配置为 NO
  }
  
  # (选填) 在安装前执行的脚本
  # spec.prepare_command = <<-CMD
  #   # echo "Pod 安装前执行的脚本"
  # CMD
  
  # # 修改构建产出物 framework 中 Info.plist 内容
  # modifyPodTargetInfoPlistScriptAfterCompile = <<-CMD
  #   # echo "自定义脚本修改构建产出物 framework 中 Info.plist 内容"
  #   Build=$(date "+%Y%m%d%H%M") # 构建时间
  #   InfoPlist="${BUILT_PRODUCTS_DIR}/${PRODUCT_NAME}.framework/Info.plist"
  #   PlistLINES=$(/usr/libexec/PlistBuddy ${InfoPlist} -c print | grep = | tr -d ' ')
  #   HasField=false
  #   for PLIST_ITEMS in $PlistLINES; do
  #       if [[ ${PLIST_ITEMS} =~ ^(CFBundleVersion=)(.*)$ ]]; then
  #           echo "CFBundleVersion: ${PLIST_ITEMS}"
  #           HasField=true
  #           break
  #       fi
  #   done
    
  #   if [[ "${HasField}" == true ]]; then
  #       /usr/libexec/PlistBuddy -c "Set :CFBundleVersion ${Build}" ${InfoPlist}
  #   else
  #       /usr/libexec/PlistBuddy -c "Add :CFBundleVersion string ${Build}" ${InfoPlist}
  #   fi
  # CMD
  # # spec.script_phase 只支持Pod Target执行脚本
  # spec.script_phase = {
  #   :name => "Modify Pod Target‘s Info.plist After Compile",
  #   :script => modifyPodTargetInfoPlistScriptAfterCompile,
  #   # :execution_position => :before_compile,
  #   :execution_position => :after_compile,
  # }
  
  # spec.xcconfig = { "HEADER_SEARCH_PATHS" => "$(SDKROOT)/usr/include/libxml2" }
  # spec.dependency "JSONKit", "~> 1.4"
  
  # Base
  spec.subspec "Base" do |sub|
    sub.source_files = [
      "#{spec.name}/*.{h,m,swift}",
      "#{spec.name}/JGSBase/**/*.{h,m,swift}",
    ]
    sub.public_header_files = [
      "#{spec.name}/*.h",
      "#{spec.name}/JGSBase/*.h",
    ]
    # sub.private_header_files = "#{spec.name}/JGSBase/*Private.h"

    # resources形式资源文件引用到主Target，存在同名冲突情况，因此使用bundle方式
    # sub.resources = "JGSDevice/**/JGSiOSDeviceList.json.sec"
    sub.resource_bundles = {
      "#{spec.name}" => [
        # resource_bundles 只能指定一次，所以subspec资源统一在此处打包进bundle
        # 远程未安装subspec时，对应资源将不会打包
        # 本地Demo将打包所有subspec资源
        "#{spec.name}/*.xcprivacy",
        "#{spec.name}/JGSBase/**/*.{xcassets,png,jpg,gif}",
        "#{spec.name}/JGSDevice/**/JGSiOSDeviceList.json.sec",
        "#{spec.name}/JGSIntegrityCheck/**/JGSIntegrityCheckRecordResourcesHash.sh",
      ]
    }
    
    sub.xcconfig = {
        "OTHER_LDFLAGS" => '-ObjC'
    }

    sub.pod_target_xcconfig = {
        "JGSVersion" => "#{spec.version}",
        "JGSBuild" => "#{version_date}",
        "GCC_PREPROCESSOR_DEFINITIONS" => "JGSUserAgent='\"#{spec.name}/${JGSVersion}\"' JGSVersion='\"${JGSVersion}\"' JGSBuild='\"${JGSBuild}\"'",
    }
    
    # 由于 subspec 可能未安装，对应 resource_bundles 中资源需要清理
    # 移除构建产出物 bundle 中 不需要的资源文件
    # 仅对远程安装形式生效
    RemoveUnInstalledJGSResource = <<-CMD
      # echo "移除构建产出物 #{spec.name}.bundle 中未安装 subspec 的资源文件"
      ProductDir="${BUILT_PRODUCTS_DIR}/${PRODUCT_NAME}.bundle"
      echo "#{spec.name}.bundle: ${ProductDir}"
      function RemoveUninstalledSubspecResource() {
        FileInBundle="${ProductDir}/$1"
        rm -fr "${FileInBundle}"
      }
      # JGSDevice 资源清理
      if [[ ''${JGSDeviceInstalled} != 'YES' ]]; then
        RemoveUninstalledSubspecResource "JGSiOSDeviceList.json.sec"
      fi
      # JGSIntegrityCheck 资源清理
      if [[ ''${JGSIntegrityCheckInstalled} != 'YES' ]]; then
        RemoveUninstalledSubspecResource "JGSIntegrityCheckRecordResourcesHash.sh"
      fi
    CMD

    # spec.script_phase 只支持Pod Target执行脚本
    sub.script_phase = {
      :name => "RemoveUnInstalledJGSResource",
      :script => RemoveUnInstalledJGSResource,
      # :execution_position => :before_compile,
      :execution_position => :after_compile
    }
  
  end
  
  # Category
  spec.subspec 'Category' do |sub|
    sub.source_files = [
      "#{spec.name}/JGSCategory/**/*.{h,m,swift}",
    ]
    sub.public_header_files = [
      "#{spec.name}/JGSCategory/**/*.h",
    ]
    
    sub.dependency "JGSourceBase/Base"
    sub.dependency "JGSourceBase/JSON"
  end
  
  # DataStorage
  spec.subspec 'DataStorage' do |sub|
    sub.source_files = "#{spec.name}/JGSDataStorage/**/*.{h,m,swift}"
    sub.public_header_files = "#{spec.name}/JGSDataStorage/**/*.h"
    
    sub.dependency "JGSourceBase/Encryption"
  end
  
  # Device
  spec.subspec 'Device' do |sub|
    sub.source_files = "#{spec.name}/JGSDevice/**/*.{h,m,swift}"
    sub.public_header_files = "#{spec.name}/JGSDevice/**/*.h"
    
    sub.pod_target_xcconfig = {
        "JGSDeviceInstalled" => "YES",
        "GCC_PREPROCESSOR_DEFINITIONS" => "JGSDeviceInstalled='\"${JGSDeviceInstalled}\"'",
    }
    
    sub.dependency "JGSourceBase/Category"
    sub.dependency "JGSourceBase/Reachability"
  end
  
  # Encryption
  spec.subspec 'Encryption' do |sub|
    sub.source_files = "#{spec.name}/JGSEncryption/**/*.{h,m,swift}"
    sub.public_header_files = "#{spec.name}/JGSEncryption/**/*.h"
    
    sub.dependency "JGSourceBase/Category"
  end
  
  # HUD
  spec.subspec 'HUD' do |sub|
    
    sub.source_files = [
      "#{spec.name}/JGSHUD/**/*.{h,m,swift}",
    ]
    sub.public_header_files = [
      "#{spec.name}/JGSHUD/**/*.h",
    ]
    
    sub.dependency "MBProgressHUD", ">= 1.2.0"
    sub.dependency "JGSourceBase/Category"
  end
  
  # IntegrityCheck
  spec.subspec 'IntegrityCheck' do |sub|
    sub.source_files = "#{spec.name}/JGSIntegrityCheck/**/*.{h,m,swift}"
    sub.public_header_files = "#{spec.name}/JGSIntegrityCheck/**/*.h"
    
    # 脚本及说明文档不需要被Target编译、作为资源文件引用
    # 但又不能被清理，要保证使用这能够访问到文件
    # 只能配置文件夹路径，不能为文件路径
    # sub.preserve_paths = "JGSIntegrityCheck"
    
    sub.pod_target_xcconfig = {
      "JGSIntegrityCheckInstalled" => "YES",
      "GCC_PREPROCESSOR_DEFINITIONS" => "JGSIntegrityCheckInstalled='\"${JGSIntegrityCheckInstalled}\"' JGSAppIntegrityCheckFile='\"JGSAppIntegrityCheckFile.json\"'",
    }
    
    sub.dependency "JGSourceBase/Encryption"
  end

  # JSON
  spec.subspec 'JSON' do |sub|
    sub.source_files = "#{spec.name}/JGSJSON/**/*.{h,m,swift}"
    sub.public_header_files = "#{spec.name}/JGSJSON/**/*.h"
    
    sub.dependency "JGSourceBase/Base"
  end

  # Reachability
  spec.subspec 'Reachability' do |sub|
    sub.source_files = "#{spec.name}/JGSReachability/**/*.{h,m,swift}"
    sub.public_header_files = "#{spec.name}/JGSReachability/**/*.h"
    
    sub.dependency "JGSourceBase/Base"
  end
  
  # SecurityKeyboard
  spec.subspec 'SecurityKeyboard' do |sub|
    sub.source_files = "#{spec.name}/JGSSecurityKeyboard/**/*.{h,m,swift}"
    sub.public_header_files = [
      "#{spec.name}/JGSSecurityKeyboard/**/**JGSSecurityKeyboard.h",
    ]
    
    sub.dependency "JGSourceBase/Category"
  end
  
  # subspec，不指定时默认安装所有subspec，用户可自行指定
  # spec.default_subspecs = [
  #     "Base",
  #     "Category",
  #     "DataStorage",
  #     "Device",
  #     "Encryption",
  #     "HUD",
  #     "IntegrityCheck",
  #     "Reachability",
  #     "SecurityKeyboard",
  # ]
  
end
