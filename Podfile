source 'https://github.com/cocoaPods/specs.git'

# 源码测试请屏蔽此选项，否则源码库内部调用出现的警告将不会提示
#inhibit_all_warnings!
use_frameworks!

# workspace
workspace "JGSourceBaseDemo"

# platform
platform :ios, '9.0'

# JGSourceBase
target "JGSourceBaseDemo" do
  
    pod 'IQKeyboardManager', '~> 6.2.1' #  https://github.com/hackiftekhar/IQKeyboardManager.git

    # Local
    pod 'JGSourceBase', :path => "."
    pod 'JGSourceBase/Reachability', :path => "."
    pod 'JGSourceBase/HUD', :path => "."
    pod 'JGSourceBase/SecurityKeyboard', :path => "."
    
    #pod 'Masonry', '~> 1.1.0' # 该发布版本 mas_safeAreaLayoutGuide 有bug导致多条约束崩溃
    pod 'Masonry', :git => 'https://github.com/SnapKit/Masonry.git', :commit => '8bd77ea92bbe995e14c454f821200b222e5a8804' # https://github.com/cloudkite/Masonry.git
    
    # project
    project "JGSourceBaseDemo.xcodeproj"
end
