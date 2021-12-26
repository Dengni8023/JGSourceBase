
Pod::Spec.new do |spec|
    
    spec.name          = "JGSourceBase"
    spec.version       = "1.2.2.1"
    
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
        :ios => '11.0',
    }
    
    # spec.deprecated = true # 该Pod已被废弃
    # spec.deprecated_in_favor_of = 'xxxx' # 该Pod已被废弃，并推荐使用xxxx
    # spec.source_files          = "JGSourceBase/*.{h,m}"
    # spec.public_header_files   = "JGSourceBase/*.h"

    # subspec，不指定时默认安装所有subspec，用户可自行指定
    spec.default_subspecs = [
        #'AlertController', # Deprecated
        'Base',
        'Category',
        # 'DataStorage',
        'Device',
        # 'Encryption',
        'Reachability',
        'SecurityKeyboard',
    ]
    
    # Base
    spec.subspec 'Base' do |sub|
        sub.source_files         = [
            "JGSourceBase/Base/*.{h,m}",
        ]
        sub.public_header_files  = [
            "JGSourceBase/Base/*.h",
        ]
        
        sub.xcconfig     = {
            "OTHER_LDFLAGS" => '-ObjC',
            "GCC_PREPROCESSOR_DEFINITIONS" => "JGSUserAgent='\"JGSourceBase/#{spec.version}\"'",
        }
        
    end
    
    # AlertController
    spec.subspec 'AlertController' do |sub|
        sub.source_files    = [
            "JGSourceBase/AlertController/*.{h,m}",
        ]
        sub.public_header_files = [
            "JGSourceBase/AlertController/*.h",
        ]
        
        sub.dependency "JGSourceBase/Category/UIAlertController"
    end
    
    # Category
    spec.subspec 'Category' do |sub|
        sub.source_files    = [
            "JGSourceBase/Category/*.{h,m}",
        ]
        sub.public_header_files = [
            "JGSourceBase/Category/*.h",
        ]
        
        sub.dependency "JGSourceBase/Base"
        
        sub.subspec 'NSDate' do |subspec|
            subspec.source_files    = [
                "JGSourceBase/Category/NSDate/*.{h,m}",
            ]
            
            subspec.public_header_files = [
                "JGSourceBase/Category/NSDate/*.h",
            ]
        end
        
        sub.subspec 'NSDictionary' do |subspec|
            subspec.source_files    = [
                "JGSourceBase/Category/NSDictionary/*.{h,m}",
            ]
            
            subspec.public_header_files = [
                "JGSourceBase/Category/NSDictionary/*.h",
            ]
        end
        
        sub.subspec 'NSObject' do |subspec|
            subspec.source_files    = [
                "JGSourceBase/Category/NSObject/*.{h,m}",
            ]
            
            subspec.public_header_files = [
                "JGSourceBase/Category/NSObject/*.h",
            ]
        end
        
        sub.subspec 'NSString' do |subspec|
            subspec.source_files    = [
                "JGSourceBase/Category/NSString/*.{h,m}",
            ]
            
            subspec.public_header_files = [
                "JGSourceBase/Category/NSString/*.h",
            ]
        end
        
        sub.subspec 'NSURL' do |subspec|
            subspec.source_files    = [
                "JGSourceBase/Category/NSURL/*.{h,m}",
            ]
            
            subspec.public_header_files = [
                "JGSourceBase/Category/NSURL/*.h",
            ]
        end
        
        sub.subspec 'UIAlertController' do |subspec|
            subspec.source_files    = [
                "JGSourceBase/Category/UIAlertController/*.{h,m}",
            ]
            
            subspec.public_header_files = [
                "JGSourceBase/Category/UIAlertController/*.h",
            ]
        end
        
        sub.subspec 'UIApplication' do |subspec|
            subspec.source_files    = [
                "JGSourceBase/Category/UIApplication/*.{h,m}",
            ]
            
            subspec.public_header_files = [
                "JGSourceBase/Category/UIApplication/*.h",
            ]
        end
        
        sub.subspec 'UIColor' do |subspec|
            subspec.source_files    = [
                "JGSourceBase/Category/UIColor/*.{h,m}",
            ]
            
            subspec.public_header_files = [
                "JGSourceBase/Category/UIColor/*.h",
            ]
        end
        
        sub.subspec 'UIImage' do |subspec|
            subspec.source_files    = [
                "JGSourceBase/Category/UIImage/*.{h,m}",
            ]
            
            subspec.public_header_files = [
                "JGSourceBase/Category/UIImage/*.h",
            ]
        end
    end
    
    # DataStorage
    spec.subspec 'DataStorage' do |sub|
        sub.source_files    = [
            "JGSourceBase/DataStorage/*.{h,m}",
        ]
        sub.public_header_files = [
            "JGSourceBase/DataStorage/*.h",
        ]
        
        sub.dependency "JGSourceBase/Base"
    end
    
    # Device
    spec.subspec 'Device' do |sub|
        sub.source_files    = [
            "JGSourceBase/Device/*.{h,m}",
        ]
        sub.public_header_files = [
            "JGSourceBase/Device/*.h",
        ]
        sub.resources    = [
            "JGSourceBase/Device/Resources/*.json",
        ]
        
        sub.dependency "JGSourceBase/Reachability"
    end
    
    # Encryption
    spec.subspec 'Encryption' do |sub|
        sub.source_files    = [
            "JGSourceBase/Encryption/*.{h,m}",
        ]
        sub.public_header_files = [
            "JGSourceBase/Encryption/*.h",
        ]
        
        sub.dependency "JGSourceBase/Base"
        sub.dependency "JGSourceBase/Category"
        sub.xcconfig     = {
            # "GCC_PREPROCESSOR_DEFINITIONS" => 'JGS_Encryption',
        }
    end
    
    # HUD
    spec.subspec 'HUD' do |sub|
        sub.source_files         = [
            "JGSourceBase/HUD/*.{h,m}",
        ]
        sub.public_header_files  = [
            "JGSourceBase/HUD/*.h",
        ]
        
        sub.dependency 'MBProgressHUD', '>= 1.2.0'
        sub.dependency "JGSourceBase/Category/UIColor"
        
        # Loading
        sub.subspec 'Loading' do |subspec|
            subspec.source_files    = [
                "JGSourceBase/HUD/Loading/*.{h,m}",
            ]
            subspec.public_header_files = [
                "JGSourceBase/HUD/Loading/*.h",
            ]
        end
        
        # Toast
        sub.subspec 'Toast' do |subspec|
            subspec.source_files    = [
                "JGSourceBase/HUD/Toast/*.{h,m}",
            ]
            subspec.public_header_files = [
                "JGSourceBase/HUD/Toast/*.h",
            ]
        end
    end
    
    # Reachability
    spec.subspec 'Reachability' do |sub|
        sub.source_files         = "JGSourceBase/Reachability/*.{h,m}"
        sub.public_header_files  = "JGSourceBase/Reachability/*.h"
        
        sub.dependency "JGSourceBase/Base"
    end
    
    # SecurityKeyboard
    spec.subspec 'SecurityKeyboard' do |sub|
        sub.source_files         = "JGSourceBase/SecurityKeyboard/*.{h,m}"
        # sub.public_header_files  = "JGSourceBase/SecurityKeyboard/*.h"
        sub.public_header_files  = "JGSourceBase/SecurityKeyboard/JGSSecurityKeyboard.h"
        
        sub.dependency "JGSourceBase/Base"
        sub.dependency "JGSourceBase/Category/UIColor"
    end
    
    spec.requires_arc = true
    
end
