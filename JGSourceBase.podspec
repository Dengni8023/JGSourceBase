
Pod::Spec.new do |spec|
    
    spec.name          = "JGSourceBase"
    spec.version       = "1.2.1"
    
    spec.summary       = "JGSourceCode通用功能组件库。"
    spec.description   = <<-DESC
    
        JGSourceCode 通用功能组件库。
        功能包括：
        
            • Base - 通用定义、功能模块、iOS项目常用功能
            • AlertController - 系统UIAlertController便捷方法封装
            • Category - 通用扩展方法定义
            • DataStorage - 通用数据持久化功能
            • Device - iOS设备相关方法
            • Encryption - 常用加解密方法
            • HUD - Loading-HUD、Toast-HUD显示
            • Reachability - 网络状态监听，支持多观察着/监听者
            • SecurityKeyboard - 自定义安全键盘
    DESC
    
    spec.homepage  = "https://github.com/dengni8023/JGSourceBase"
    spec.license   = {
        :type => 'MIT',
        :file => 'LICENSE',
    }
    spec.authors   = {
        "等你8023" => "945835664@qq.com",
    },
    
    spec.source    = {
        :git => "https://github.com/dengni8023/JGSourceBase.git",
        :tag => "#{spec.version}",
    }
    spec.platforms = {
        :ios => '10.0',
    }
    
    # ss.deprecated = true # 该Pod已被废弃
    # ss.deprecated_in_favor_of = 'xxxx' # 该Pod已被废弃，并推荐使用xxxx
    spec.source_files          = "JGSourceBase/*.{h,m}"
    spec.public_header_files   = "JGSourceBase/*.h"

    # subspec，不指定时默认安装所有subspec，用户可自行指定
    spec.default_subspecs = [
        'AlertController',
        'Base',
        'Category',
        'DataStorage',
        'Device',
        'Encryption',
        'Reachability',
        'SecurityKeyboard',
    ]
    
    # Base
    spec.subspec 'Base' do |ss|
        ss.source_files         = [
            "JGSourceBase/Base/*.{h,m}",
        ]
        ss.public_header_files  = [
            "JGSourceBase/Base/*.h",
        ]
        
        ss.xcconfig     = {
            "OTHER_LDFLAGS" => '-ObjC',
            "GCC_PREPROCESSOR_DEFINITIONS" => "JGSUserAgent='\"JGSourceBase/#{spec.version}\"'",
        }
        
    end
    
    # AlertController
    spec.subspec 'AlertController' do |ss|
        ss.source_files    = [
            "JGSourceBase/AlertController/*.{h,m}",
        ]
        ss.public_header_files = [
            "JGSourceBase/AlertController/*.h",
        ]
        
        ss.dependency   "JGSourceBase/Category"
        ss.xcconfig     = {
            "GCC_PREPROCESSOR_DEFINITIONS" => 'JGS_AlertController',
        }
    end
    
    # Category
    spec.subspec 'Category' do |ss|
        ss.source_files    = [
            "JGSourceBase/Category/*.{h,m}",
        ]
        ss.public_header_files = [
            "JGSourceBase/Category/*.h",
        ]
        
        ss.dependency   "JGSourceBase/Base"
        ss.xcconfig     = {
            "GCC_PREPROCESSOR_DEFINITIONS" => 'JGS_Category',
        }
    end
    
    # DataStorage
    spec.subspec 'DataStorage' do |ss|
        ss.source_files    = [
            "JGSourceBase/DataStorage/*.{h,m}",
        ]
        ss.public_header_files = [
            "JGSourceBase/DataStorage/*.h",
        ]
        
        ss.dependency   "JGSourceBase/Category"
        ss.xcconfig     = {
            "GCC_PREPROCESSOR_DEFINITIONS" => 'JGS_DataStorage',
        }
    end
    
    
    # Device
    spec.subspec 'Device' do |ss|
        ss.source_files    = [
            "JGSourceBase/Device/*.{h,m}",
        ]
        ss.public_header_files = [
            "JGSourceBase/Device/*.h",
        ]
        ss.resources    = [
            "JGSourceBase/Device/Resources/*.json",
        ]
        
        ss.dependency   "JGSourceBase/DataStorage"
        ss.xcconfig     = {
            "GCC_PREPROCESSOR_DEFINITIONS" => 'JGS_Device',
        }
    end
    
    # Encryption
    spec.subspec 'Encryption' do |ss|
        ss.source_files    = [
            "JGSourceBase/Encryption/*.{h,m}",
        ]
        ss.public_header_files = [
            "JGSourceBase/Encryption/*.h",
        ]
        
        ss.dependency   "JGSourceBase/Category"
        ss.xcconfig     = {
            "GCC_PREPROCESSOR_DEFINITIONS" => 'JGS_Encryption',
        }
    end
    
    # HUD
    spec.subspec 'HUD' do |ss|
        ss.source_files         = [
            "JGSourceBase/HUD/*.{h,m}",
        ]
        ss.public_header_files  = [
            "JGSourceBase/HUD/*.h",
        ]
        
        ss.dependency   'MBProgressHUD', '>= 1.2.0'
        ss.dependency   "JGSourceBase/Category"
        ss.xcconfig     = {
            "GCC_PREPROCESSOR_DEFINITIONS" => 'JGS_HUD',
        }
        
        # LoadingHUD
        ss.subspec 'LoadingHUD' do |sss|
            sss.source_files    = [
                "JGSourceBase/HUD/LoadingHUD/*.{h,m}",
            ]
            sss.public_header_files = [
                "JGSourceBase/HUD/LoadingHUD/*.h",
            ]
        end
        
        # ToastHUD
        ss.subspec 'ToastHUD' do |sss|
            sss.source_files    = [
                "JGSourceBase/HUD/ToastHUD/*.{h,m}",
            ]
            sss.public_header_files = [
                "JGSourceBase/HUD/ToastHUD/*.h",
            ]
        end
    end
    
    # Reachability
    spec.subspec 'Reachability' do |ss|
        ss.source_files         = "JGSourceBase/Reachability/*.{h,m}"
        ss.public_header_files  = "JGSourceBase/Reachability/*.h"
        
        ss.dependency   "JGSourceBase/Base"
        ss.xcconfig     = {
            "GCC_PREPROCESSOR_DEFINITIONS" => 'JGS_Reachability',
        }
    end
    
    # SecurityKeyboard
    spec.subspec 'SecurityKeyboard' do |ss|
        ss.source_files         = "JGSourceBase/SecurityKeyboard/*.{h,m}"
        ss.public_header_files  = "JGSourceBase/SecurityKeyboard/*.h"
        
        ss.dependency   "JGSourceBase/Category"
        ss.xcconfig     = {
            "GCC_PREPROCESSOR_DEFINITIONS" => 'JGS_SecurityKeyboard',
        }
    end
    
    spec.requires_arc = true
    
end
