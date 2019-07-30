#source 'https://github.com/cocoaPods/specs.git'
#source 'https://mirrors.tuna.tsinghua.edu.cn/git/CocoaPods/Specs.git'

# 源码测试请屏蔽此选项，否则源码库内部调用出现的警告将不会提示
#inhibit_all_warnings!
use_frameworks!

# workspace
workspace "JGSourceBase"

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
    project "JGSourceBaseDemo/JGSourceBaseDemo.xcodeproj"
end

# 设置Pods最低版本
post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      if config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'].to_f < 9.0
        config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '9.0'
      end
    end
  end
end
