
Pod::Spec.new do |s|
    
    s.name          = "JGSourceBase"
    s.version       = "1.2.0"
    
    s.summary       = "JGSourceCode通用功能模块：iOS项目常用功能（UIAlertController、Reachability、Loading-HUD、Toast-HUD）；自定义安全键盘。"
    s.description   = <<-DESC
    
        JGSourceCode 通用定义、功能模块。iOS项目常用功能、UIAlertController、Reachability、HUD（Loading、Toast）便捷方法封装。
        
        功能包括：
        
            Base - 通用定义、功能模块、iOS项目常用功能
                1、常用宏定义、常用警告消除、SwizzledMethod的严谨实现
                2、通用日志控制功能
                3、字符串、URL常用方法
                4、Block循环引用常用定义weak、strong快捷处理
                5、NSDictionary便捷取指定类型值方法
                6、NSJSONSerialization便捷方法封装
                7、UIColor便捷方法封装
            
            AlertController - 系统UIAlertController便捷方法封装(原项目：JGActionSheetAlert/JGAlertController)
                原项目：JGActionSheetAlert => https://github.com/dengni8023/JGActionSheetAlert.git
                原项目：JGAlertController => https://github.com/dengni8023/JGAlertController.git
                1、UIAlertController便捷方法封装
            
            Reachability - 网络状态监听(原项目：JGNetworkReachability)
                原项目：JGNetworkReachability => https://github.com/dengni8023/JGNetworkReachability.git
                1、网络状态获取、监听，支持多监听者
                
            HUD - Loading-HUD、Toast-HUD显示
                1、显示Loading HUD方法封装
                2、显示Toast HUD方法封装
                
            SecurityKeyboard - 自定义安全键盘
                1、字母键盘支持单字母大小写切换、选中大写
                2、符号键盘支持与数字混合展示，支持全角、半角字符
                3、数字键盘支持随机、非随机
            
    DESC
    
    s.homepage  = "https://github.com/dengni8023/JGSourceBase"
    s.license   = {
        :type => 'MIT',
        :file => 'LICENSE',
    }
    s.authors   = {
        "等你8023" => "945835664@qq.com",
    },
    
    s.source    = {
        :git => "https://github.com/dengni8023/JGSourceBase.git",
        :tag => "#{s.version}",
    }
    s.platforms = {
        :ios => 10.0,
    }
    
    s.source_files          = "JGSourceBase/*.{h,m}"
    s.public_header_files   = "JGSourceBase/*.h"
    
    # subspec，不指定时默认安装所有subspec，用户可自行指定
    #s.default_subspecs = [
    #    'AlertController',
    #    'Base',
    #    'Category',
    #    'HUD',
    #    'Reachability',
    #]
                                                        
    # Base
    s.subspec 'Base' do |ss|
        ss.source_files         = [
            "JGSourceBase/*.{h,m}",
            "JGSourceBase/Base/*.{h,m}", # 防止用户自行指定subspec时JGSourceBase.h不会作为公共头文件导出问题
        ]
        ss.public_header_files  = [
            "JGSourceBase/*.h",
            "JGSourceBase/Base/*.h", # 防止用户自行指定subspec时JGSourceBase.h不会作为公共头文件导出问题
        ]
        ss.resources    = [
            "JGSourceBase/Base/Resources/*.json",
        ]

        ss.xcconfig     = {
            "OTHER_LDFLAGS" => '-ObjC',
            "GCC_PREPROCESSOR_DEFINITIONS" => 'JGSUserAgent=\'@"JGSourceBase 1.2.0"\'',
        }
    end
    
    # AlertController
    s.subspec 'AlertController' do |ss|
        ss.source_files    = [
            "JGSourceBase/AlertController/*.{h,m}",
        ]
        ss.public_header_files = [
            "JGSourceBase/AlertController/*.h",
        ]
        
        ss.dependency   "JGSourceBase/Base"
    end
    
    # Category
    s.subspec 'Category' do |ss|
        ss.source_files    = [
            "JGSourceBase/Category/*.{h,m}",
        ]
        ss.public_header_files = [
            "JGSourceBase/Category/*.h",
        ]
        
        ss.dependency   "JGSourceBase/Base"
    end
    
    # Reachability
    s.subspec 'Reachability' do |ss|
        ss.source_files         = "JGSourceBase/Reachability/*.{h,m}"
        ss.public_header_files  = "JGSourceBase/Reachability/*.h"
        
        ss.dependency   "JGSourceBase/Base"
        ss.xcconfig     = {
            "GCC_PREPROCESSOR_DEFINITIONS" => 'JGS_Reachability',
        }
    end
    
    # HUD
    s.subspec 'HUD' do |ss|
        ss.source_files         = [
            "JGSourceBase/HUD/*.{h,m}",
        ]
        ss.public_header_files  = [
            "JGSourceBase/HUD/*.h",
        ]
        
        ss.dependency   'MBProgressHUD', '~> 1.2.0'
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
    
    # SecurityKeyboard
    s.subspec 'SecurityKeyboard' do |ss|
        ss.source_files         = "JGSourceBase/SecurityKeyboard/*.{h,m}"
        ss.public_header_files  = "JGSourceBase/SecurityKeyboard/*.h"
        
        ss.dependency   "JGSourceBase/Category"
        ss.xcconfig     = {
            "GCC_PREPROCESSOR_DEFINITIONS" => 'JGS_SecurityKeyboard',
        }
    end
    
    s.requires_arc = true
    
end
