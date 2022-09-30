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

  spec.name         = "JGSourceBase"
  spec.version      = "1.3.2"
  spec.summary      = "JGSourceBase functional component library."

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
  7. Reachability - 网络状态监听，支持多观察着/监听者
  8. SecurityKeyboard - 自定义安全键盘
                   DESC

  spec.homepage     = "https://github.com/dengni8023/JGSourceBase"
  # spec.screenshots  = "www.example.com/screenshots_1.gif", "www.example.com/screenshots_2.gif"


  # ―――  Spec License  ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  Licensing your code is important. See https://choosealicense.com for more info.
  #  CocoaPods will detect a license file if there is a named LICENSE*
  #  Popular ones are 'MIT', 'BSD' and 'Apache License, Version 2.0'.
  #

  spec.license      = "MIT (LICENSE.md)"
  # spec.license      = { :type => "MIT", :file => "FILE_LICENSE" }


  # ――― Author Metadata  ――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  Specify the authors of the library, with email addresses. Email addresses
  #  of the authors are extracted from the SCM log. E.g. $ git log. CocoaPods also
  #  accepts just a name if you'd rather not provide an email address.
  #
  #  Specify a social_media_url where others can refer to, for example a twitter
  #  profile URL.
  #

  spec.author             = {
    "Dengni8023" => "945835664@qq.com",
    "MeiJiGao" => "945835664@qq.com",
   }
  # Or just: spec.author    = "Dengni8023"
  # spec.authors            = { "Dengni8023" => "945835664@qq.com" }
  # spec.social_media_url   = "https://twitter.com/Dengni8023"

  # ――― Platform Specifics ――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  If this Pod runs only on iOS or OS X, then specify the platform and
  #  the deployment target. You can optionally include the target after the platform.
  #

  # spec.platform     = :ios
  spec.platform     = :ios, "11.0"

  #  When using multiple platforms
  # spec.ios.deployment_target = "5.0"
  # spec.osx.deployment_target = "10.7"
  # spec.watchos.deployment_target = "2.0"
  # spec.tvos.deployment_target = "9.0"


  # ――― Source Location ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  Specify the location from where the source should be retrieved.
  #  Supports git, hg, bzr, svn and HTTP.
  #

  spec.source       = { :git => "https://github.com/dengni8023/JGSourceBase.git", :tag => "#{spec.version}" }


  # ――― Source Code ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  CocoaPods is smart about how it includes source code. For source files
  #  giving a folder will include any swift, h, m, mm, c & cpp files.
  #  For header files it will include any header in the folder.
  #  Not including the public_header_files will make all headers public.
  #

  # spec.source_files  = "Classes", "Classes/**/*.{h,m}"
  # spec.exclude_files = "Classes/Exclude"

  # spec.public_header_files = "Classes/**/*.h"

  spec.source_files = "#{spec.name}/*.{h,m}"
  spec.public_header_files = "#{spec.name}/*.h"

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

  # 是否使用静态库。如果 Podfile 指明了 use_frameworks! 命令，但是pod仓库需要使用静态库则需要设置
  # 注意测试，设置为 true 且 Podfile 指明 use_frameworks! 时，启动可能会崩溃，经测试，崩溃原因可能为：
  # 源码JGSourceBase.framework target 设置 Mach-O Type 为动态库 Dynamic Library，设置为 Static Library则不会崩溃
  # 设置为 true，在Podfile指定 use_frameworks!时，打包静态framework
  spec.static_framework = true
  spec.requires_arc = true
  
  # modify info.plist
  # Only work for framework
  # spec.info_plist = {
  #   "CFBundleShortVersionString" => "#{spec.version}",
  #   "CFBundleVersion" => "#{spec.version}",
  # }
  
  spec.pod_target_xcconfig = {
    "PRODUCT_BUNDLE_IDENTIFIER" => "com.meijigao.#{spec.name}",
    "MARKETING_VERSION" => "#{spec.version}",
    "CURRENT_PROJECT_VERSION" => "#{spec.version}",
  }

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
    sub.source_files = "#{spec.name}/JGSBase/*.{h,m}"
    sub.public_header_files = "#{spec.name}/JGSBase/*.h"
    sub.private_header_files = "#{spec.name}/JGSBase/*Private.h"

    # resources形式资源文件引用到主Target，存在同名冲突情况，因此使用bundle方式
    # sub.resources = "JGSDevice/**/JGSiOSDeviceList.json.sec"
    sub.resource_bundles = {
      "#{spec.name}" => [
        # resource_bundles 只能指定一次，所以subspec资源统一在此处打包进bundle
        # 远程未安装subspec时，对应资源将不会打包
        # 本地Demo将打包所有subspec资源
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
        "JGSBuild" => "20220622",
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
      :execution_position => :after_compile,
    }
  
  end
  
  # Category
  spec.subspec 'Category' do |sub|
    sub.source_files =  "#{spec.name}/JGSCategory/*.{h,m}"
    sub.public_header_files = "#{spec.name}/JGSCategory/*.h"
    
    sub.subspec 'NSArray' do |subsub|
      subsub.source_files = "#{spec.name}/JGSCategory/NSArray/*.{h,m}"
      subsub.public_header_files = "#{spec.name}/JGSCategory/NSArray/*.h"
      
      subsub.dependency "JGSourceBase/Category/NSDictionary"
      subsub.dependency "JGSourceBase/Category/NSObject"
    end
    
    sub.subspec 'NSData' do |subsub|
      subsub.source_files = "#{spec.name}/JGSCategory/NSData/*.{h,m}"
      subsub.public_header_files = "#{spec.name}/JGSCategory/NSData/*.h"
      
      subsub.dependency "JGSourceBase/Base"
    end
    
    sub.subspec 'NSDate' do |subsub|
      subsub.source_files = "#{spec.name}/JGSCategory/NSDate/*.{h,m}"
      subsub.public_header_files = "#{spec.name}/JGSCategory/NSDate/*.h"
    end
    
    sub.subspec 'NSDictionary' do |subsub|
      subsub.source_files = "#{spec.name}/JGSCategory/NSDictionary/*.{h,m}"
      subsub.public_header_files = "#{spec.name}/JGSCategory/NSDictionary/*.h"

      subsub.dependency "JGSourceBase/Base"
    end
    
    sub.subspec 'NSObject' do |subsub|
      subsub.source_files = "#{spec.name}/JGSCategory/NSObject/*.{h,m}"
      subsub.public_header_files = "#{spec.name}/JGSCategory/NSObject/*.h"
      
      subsub.dependency "JGSourceBase/Category/NSData"
      subsub.dependency "JGSourceBase/Category/NSString"
    end
    
    sub.subspec 'NSString' do |subsub|
      subsub.source_files = "#{spec.name}/JGSCategory/NSString/*.{h,m}"
      subsub.public_header_files = "#{spec.name}/JGSCategory/NSString/*.h"
      
      subsub.dependency "JGSourceBase/Category/NSData"
    end
    
    sub.subspec 'NSURL' do |subsub|
      subsub.source_files = "#{spec.name}/JGSCategory/NSURL/*.{h,m}"
      subsub.public_header_files = "#{spec.name}/JGSCategory/NSURL/*.h"
    end
    
    sub.subspec 'UIAlertController' do |subsub|
      subsub.source_files = "#{spec.name}/JGSCategory/UIAlertController/*.{h,m}"
      subsub.public_header_files = "#{spec.name}/JGSCategory/UIAlertController/*.h"
      
      subsub.dependency "JGSourceBase/Base"
    end
    
    sub.subspec 'UIApplication' do |subsub|
      subsub.source_files = "#{spec.name}/JGSCategory/UIApplication/*.{h,m}"
      subsub.public_header_files = "#{spec.name}/JGSCategory/UIApplication/*.h"
      
      subsub.dependency "JGSourceBase/Base"
    end
    
    sub.subspec 'UIColor' do |subsub|
      subsub.source_files = "#{spec.name}/JGSCategory/UIColor/*.{h,m}"
      subsub.public_header_files = "#{spec.name}/JGSCategory/UIColor/*.h"
    end
    
    sub.subspec 'UIImage' do |subsub|
      subsub.source_files = "#{spec.name}/JGSCategory/UIImage/*.{h,m}"
      subsub.public_header_files = "#{spec.name}/JGSCategory/UIImage/*.h"
      
      subsub.dependency "JGSourceBase/Base"
    end
  end
  
  # DataStorage
  spec.subspec 'DataStorage' do |sub|
    sub.source_files = "#{spec.name}/JGSDataStorage/*.{h,m}"
    sub.public_header_files = "#{spec.name}/JGSDataStorage/*.h"
    
    sub.dependency "JGSourceBase/Base"
  end
  
  # Device
  spec.subspec 'Device' do |sub|
    sub.source_files = "#{spec.name}/JGSDevice/*.{h,m}"
    sub.public_header_files = "#{spec.name}/JGSDevice/*.h"
    
    sub.pod_target_xcconfig = {
        "JGSDeviceInstalled" => "YES",
        "GCC_PREPROCESSOR_DEFINITIONS" => "JGSDeviceInstalled='\"${JGSDeviceInstalled}\"'",
    }
    
    sub.dependency "JGSourceBase/Reachability"
    sub.dependency "JGSourceBase/Category/NSData"
  end
  
  # Encryption
  spec.subspec 'Encryption' do |sub|
    sub.source_files = "#{spec.name}/JGSEncryption/*.{h,m}"
    sub.public_header_files = "#{spec.name}/JGSEncryption/*.h"
    
    sub.dependency "JGSourceBase/Category/NSData"
    sub.dependency "JGSourceBase/Category/NSString"
  end
  
  # HUD
  spec.subspec 'HUD' do |sub|
    sub.source_files = "#{spec.name}/JGSHUD/*.{h,m}"
    sub.public_header_files = "#{spec.name}/JGSHUD/*.h"
    
    # Loading
    sub.subspec 'Loading' do |subsub|
      subsub.source_files = "#{spec.name}/JGSHUD/Loading/*.{h,m}"
      subsub.public_header_files = "#{spec.name}/JGSHUD/Loading/*.h"
      
      subsub.dependency 'MBProgressHUD'
      subsub.dependency "JGSourceBase/Base"
      subsub.dependency "JGSourceBase/Category/UIColor"
    end
    
    # Toast
    sub.subspec 'Toast' do |subsub|
      subsub.source_files = "#{spec.name}/JGSHUD/Toast/*.{h,m}"
      subsub.public_header_files = "#{spec.name}/JGSHUD/Toast/*.h"
      
      subsub.dependency 'MBProgressHUD'
      subsub.dependency "JGSourceBase/Base"
    end
  end
  
  # IntegrityCheck
  spec.subspec 'IntegrityCheck' do |sub|
    sub.source_files = "#{spec.name}/JGSIntegrityCheck/*.{h,m}"
    sub.public_header_files = "#{spec.name}/JGSIntegrityCheck/*.h"
    
    # 脚本及说明文档不需要被Target编译、作为资源文件引用
    # 但又不能被清理，要保证使用这能够访问到文件
    # 只能配置文件夹路径，不能为文件路径
    # sub.preserve_paths = "JGSIntegrityCheck"
    
    sub.pod_target_xcconfig = {
      "JGSIntegrityCheckInstalled" => "YES",
      "GCC_PREPROCESSOR_DEFINITIONS" => "JGSIntegrityCheckInstalled='\"${JGSIntegrityCheckInstalled}\"' JGSResourcesCheckFileHashSecuritySalt='\"JGSIntegrityCheck\"' JGSApplicationIntegrityCheckFileHashFile='\"JGSApplicationIntegrityCheckFileHashFile\"'",
    }
    
    sub.dependency "JGSourceBase/Base"
    sub.dependency "JGSourceBase/Encryption"
    
  end

  # Reachability
  spec.subspec 'Reachability' do |sub|
    sub.source_files = "#{spec.name}/JGSReachability/*.{h,m}"
    sub.public_header_files = "#{spec.name}/JGSReachability/*.h"
    
    sub.dependency "JGSourceBase/Base"
  end
  
  # SecurityKeyboard
  spec.subspec 'SecurityKeyboard' do |sub|
    sub.source_files = "#{spec.name}/JGSSecurityKeyboard/*.{h,m}"
    sub.public_header_files = [
      "#{spec.name}/JGSSecurityKeyboard/**JGSSecurityKeyboard.h",
    ]
    
    sub.dependency "JGSourceBase/Base"
    sub.dependency "JGSourceBase/Category/NSData"
    sub.dependency "JGSourceBase/Category/NSString"
    sub.dependency "JGSourceBase/Category/UIColor"
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
