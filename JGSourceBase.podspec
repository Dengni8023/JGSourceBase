#
#  Be sure to run `pod spec lint JGSourceBase.podspec' to ensure this is a
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
  spec.version      = "1.3.0"
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
  2. AlertController - 系统UIAlertController便捷方法封装
  3. Category - 通用扩展方法定义
  4. DataStorage - 通用数据持久化功能
  5. Device - iOS设备相关方法
  6. Encryption - 常用加解密方法
  7. HUD - Loading-HUD、Toast-HUD显示
  8. Reachability - 网络状态监听，支持多观察着/监听者
  9. SecurityKeyboard - 自定义安全键盘
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

  spec.requires_arc = true
  
  # spec.xcconfig = { "HEADER_SEARCH_PATHS" => "$(SDKROOT)/usr/include/libxml2" }
  # spec.dependency "JSONKit", "~> 1.4"

  # AlertController
  spec.subspec 'AlertController' do |sub|
    sub.source_files = "JGSourceBase/AlertController/*.{h,m}"
    sub.public_header_files = "JGSourceBase/AlertController/*.h"
    
    sub.dependency "JGSourceBase/Category/UIAlertController"
  end
  
  # Base
  spec.subspec 'Base' do |sub|
    sub.source_files = "JGSBase/**/*.{h,m}"
    sub.public_header_files = "JGSBase/**/*.h"
    
    sub.xcconfig = {
        "OTHER_LDFLAGS" => '-ObjC',
        "GCC_PREPROCESSOR_DEFINITIONS" => "JGSUserAgent='\"JGSourceBase/#{spec.version}\"' JGSVersion='#{spec.version}'",
    }
  end
  
  # Category
  spec.subspec 'Category' do |sub|
    sub.source_files =  "JGSCategory/JGSCategory/*.{h,m}"
    sub.public_header_files = "JGSCategory/JGSCategory/*.h"
    
    sub.dependency "JGSourceBase/Base"
    
    sub.subspec 'NSDate' do |subsub|
      subsub.source_files = "JGSCategory/JGSCategory/NSDate/*.{h,m}"
      subsub.public_header_files = "JGSCategory/JGSCategory/NSDate/*.h"
    end
    
    sub.subspec 'NSDictionary' do |subsub|
      subsub.source_files = "JGSCategory/JGSCategory/NSDictionary/*.{h,m}"
      subsub.public_header_files = "JGSCategory/JGSCategory/NSDictionary/*.h"
    end
    
    sub.subspec 'NSObject' do |subsub|
      subsub.source_files = "JGSCategory/JGSCategory/NSObject/*.{h,m}"
      subsub.public_header_files = "JGSCategory/JGSCategory/NSObject/*.h"
    end
    
    sub.subspec 'NSString' do |subsub|
      subsub.source_files = "JGSCategory/JGSCategory/NSString/*.{h,m}"
      subsub.public_header_files = "JGSCategory/JGSCategory/NSString/*.h"
    end
    
    sub.subspec 'NSURL' do |subsub|
      subsub.source_files = "JGSCategory/JGSCategory/NSURL/*.{h,m}"
      subsub.public_header_files = "JGSCategory/JGSCategory/NSURL/*.h"
    end
    
    sub.subspec 'UIAlertController' do |subsub|
      subsub.source_files = "JGSCategory/JGSCategory/UIAlertController/*.{h,m}"
      subsub.public_header_files = "JGSCategory/JGSCategory/UIAlertController/*.h"
    end
    
    sub.subspec 'UIApplication' do |subsub|
      subsub.source_files = "JGSCategory/JGSCategory/UIApplication/*.{h,m}"
      subsub.public_header_files = "JGSCategory/JGSCategory/UIApplication/*.h"
    end
    
    sub.subspec 'UIColor' do |subsub|
      subsub.source_files = "JGSCategory/JGSCategory/UIColor/*.{h,m}"
      subsub.public_header_files = "JGSCategory/JGSCategory/UIColor/*.h"
    end
    
    sub.subspec 'UIImage' do |subsub|
      subsub.source_files = "JGSCategory/JGSCategory/UIImage/*.{h,m}"
      subsub.public_header_files = "JGSCategory/JGSCategory/UIImage/*.h"
    end
  end
  
  # DataStorage
  spec.subspec 'DataStorage' do |sub|
    sub.source_files = "JGSDataStorage/**/*.{h,m}"
    sub.public_header_files = "JGSDataStorage/**/*.h"
    
    sub.dependency "JGSourceBase/Base"
  end
  
  # Device
  spec.subspec 'Device' do |sub|
    sub.source_files = "JGSDevice/JGSDevice/*.{h,m}"
    sub.public_header_files = "JGSDevice/JGSDevice/*.h"

    sub.resources = "JGSDevice/JGSDevice/*.json"
    
    sub.dependency "JGSourceBase/Reachability"
  end
  
  # Encryption
  spec.subspec 'Encryption' do |sub|
    sub.source_files = "JGSEncryption/**/*.{h,m}"
    sub.public_header_files = "JGSEncryption/**/*.h"
    
    sub.dependency "JGSourceBase/Base"
  end
  
  # HUD
  spec.subspec 'HUD' do |sub|
    sub.source_files = "JGSHUD/JGSHUD/*.{h,m}"
    sub.public_header_files = "JGSHUD/JGSHUD/*.h"
    
    # Loading
    sub.subspec 'Loading' do |subsub|
      subsub.source_files = "JGSHUD/JGSHUD/Loading/*.{h,m}"
      subsub.public_header_files = "JGSHUD/JGSHUD/Loading/*.h"
      
      subsub.dependency 'MBProgressHUD'
      subsub.dependency "JGSourceBase/Category/UIColor"
    end
    
    # Toast
    sub.subspec 'Toast' do |subsub|
      subsub.source_files = "JGSHUD/JGSHUD/Toast/*.{h,m}"
      subsub.public_header_files = "JGSHUD/JGSHUD/Toast/*.h"

      subsub.dependency 'MBProgressHUD'
    end
  end
  
  # Reachability
  spec.subspec 'Reachability' do |sub|
    sub.source_files = "JGSReachability/**/*.{h,m}"
    sub.public_header_files = "JGSReachability/**/*.h"
    
    sub.dependency "JGSourceBase/Base"
  end
  
  # SecurityKeyboard
  spec.subspec 'SecurityKeyboard' do |sub|
    sub.source_files = "JGSSecurityKeyboard/**/*.{h,m}"
    sub.public_header_files = [
      "JGSSecurityKeyboard/**/**JGSSecurityKeyboard.h",
      # "JGSSecurityKeyboard/**/UITextField+JGSSecurityKeyboard.h",
    ]

    sub.dependency "JGSourceBase/Base"
    sub.dependency "JGSourceBase/Category/UIColor"
  end
  
  # subspec，不指定时默认安装所有subspec，用户可自行指定
  # spec.default_subspecs = [
  #     # 'AlertController', # Deprecated
  #     'Base',
  #     'Category',
  #     'DataStorage',
  #     'Device',
  #     'Encryption',
  #     # 'HUD',
  #     'Reachability',
  #     'SecurityKeyboard',
  # ]
  
end
