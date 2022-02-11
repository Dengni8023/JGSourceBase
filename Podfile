# source 'https://mirrors.tuna.tsinghua.edu.cn/git/CocoaPods/Specs.git'
# source 'https://github.com/cocoapods/specs.git'
source 'https://cdn.cocoapods.org/'

# 私有库B依赖了模块A，同时在主工程里 添加A到 development pod，cocoapods 重复生成相同库的uuid
# pod install 警告信息 [!] [Xcodeproj] Generated duplicate UUIDs
install!'cocoapods', :deterministic_uuids => false

# 源码测试请屏蔽此选项，否则源码库内部调用出现的警告将不会提示
#inhibit_all_warnings!
#use_frameworks!

# workspace
workspace "JGSourceBase"

# platform
platform :ios, 11.0

# JGSourceBase
target "JGSourceBase" do
  
  # project
  project "JGSourceBase.xcodeproj"
end

# JGSourceBaseDemo
target "JGSourceBaseDemo" do
  
  pod 'IQKeyboardManager', '~> 6.5.6' #  https://github.com/hackiftekhar/IQKeyboardManager.git
  # pod 'SAMKeychain' # KeyChain 测试
  # pod 'FLAnimatedImage'
  # pod 'JGSourceBase', :git => 'https://github.com/dengni8023/JGSourceBase.git', :commit => '164a8fbf2af3968af8940f5116bae388c3a3e088' #'~> 1.2.2'
  # pod 'JGSourceBase', '~> 1.2.2'
  # pod 'JGSourceBase', :path => "."
   pod 'JGSourceBase', :path => ".", :subspecs => [
    # Base测试
     'Base',

    # Category测试
    # 'Category',
    
    # Device测试
    # 'Device',
    
    # HUD测试
    # 'HUD',
    # 'Category/UIImage',
    
    # HUD-Loading测试
    # 'HUD/Loading',
    # 'Category/UIImage',
    
    # HUD-Toast测试
    # 'HUD/Toast',
    
    # Reachability测试
    # 'Reachability',

    # SecurityKeyboard测试
    # 'SecurityKeyboard',
   ]
  
  #pod 'Masonry', '~> 1.1.0' # 该发布版本 mas_safeAreaLayoutGuide 有bug导致多条约束崩溃
  pod 'Masonry', :git => 'https://github.com/SnapKit/Masonry.git', :commit => '8bd77ea92bbe995e14c454f821200b222e5a8804' # https://github.com/cloudkite/Masonry.git
  
  # project
  project "JGSourceBaseDemo/JGSourceBaseDemo.xcodeproj"
end

# Hooks: pre_install 在Pods被下载后但是还未安装前对Pods做一些改变
pre_install do |installer|
  puts ""
  puts "##### pre_install start #####"
  
  # target has transitive dependencies that include statically linked  解决pod install失败
  # workaround for https://github.com/CocoaPods/CocoaPods/issues/3289
  # Pod::Installer::Xcode::TargetValidator.send(:define_method, :verify_no_static_framework_transitive_dependencies) {}
  
  puts "##### pre_install end #####"
  puts ""
end

# Hooks: post_install 在生成的Xcode project写入硬盘前做最后的改动
post_install do |installer|
  puts ""
  puts "##### post_install start #####"
  
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      # 设置Pods最低版本
      if config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'].to_f < 11.0
        config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = 11.0
      end
      # 编译架构
      config.build_settings['ARCHS'] = "$(ARCHS_STANDARD)"
      # 解决最新Mac系统编模拟器译报错：
      # building for iOS Simulator-x86_64 but attempting to link with file built for iOS Simulator-arm64
      config.build_settings['ONLY_ACTIVE_ARCH'] = false
    end
  end
  
  puts "##### post_install end #####"
  puts ""
end

#### 以下为构建子 framework 包所需的依赖 ####
# 为避免影响 Demo 项目的子依赖功能测试，默认屏蔽构建子 framework 相关依赖安装
# 不需要构建子 framework 时，保持以下内容为注释状态
# 如需构建子 framework ，取消以下内容的注释状态

# # JGSBase
# target "JGSBase" do
  
#   # project
#   project "JGSBase/JGSBase.xcodeproj"
# end

# # JGSCategory
# target "JGSCategory" do
  
#   pod 'JGSourceBase/Base', :path => "."
  
#   # project
#   project "JGSCategory/JGSCategory.xcodeproj"
# end

# # JGSDataStorage
# target "JGSDataStorage" do
  
#   pod 'JGSourceBase/Base', :path => "."
  
#   # project
#   project "JGSDataStorage/JGSDataStorage.xcodeproj"
# end

# # JGSDevice
# target "JGSDevice" do
  
#   pod 'JGSourceBase/Reachability', :path => "."
  
#   # project
#   project "JGSDevice/JGSDevice.xcodeproj"
# end

# # JGSEncryption
# target "JGSEncryption" do
  
#   pod 'JGSourceBase/Base', :path => "."
  
#   # project
#   project "JGSEncryption/JGSEncryption.xcodeproj"
# end

# # JGSHUD
# target "JGSHUD" do
  
#   pod 'MBProgressHUD'
#   pod 'JGSourceBase/Category/UIColor', :path => '.'
  
#   # project
#   project "JGSHUD/JGSHUD.xcodeproj"
# end

# # JGSReachability
# target "JGSReachability" do
  
#   pod 'JGSourceBase/Base', :path => "."
  
#   # project
#   project "JGSReachability/JGSReachability.xcodeproj"
# end

# # JGSSecurityKeyboard
# target "JGSSecurityKeyboard" do
  
#   pod 'JGSourceBase/Base', :path => "."
#   pod 'JGSourceBase/Category/UIColor', :path => "."

#   # project
#   project "JGSSecurityKeyboard/JGSSecurityKeyboard.xcodeproj"
# end
