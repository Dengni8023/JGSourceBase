# source 'https://mirrors.tuna.tsinghua.edu.cn/git/CocoaPods/Specs.git'
# source 'https://github.com/cocoapods/specs.git'
source 'https://cdn.cocoapods.org/'

# 私有库B依赖了模块A，同时在主工程里 添加A到 development pod，cocoapods 重复生成相同库的uuid
# pod install 警告信息 [!] [Xcodeproj] Generated duplicate UUIDs
install! 'cocoapods', :deterministic_uuids => false

# 源码测试请屏蔽此选项，否则源码库内部调用出现的警告将不会提示
# inhibit_all_warnings!
# use_frameworks! 要求生成的是 .framework 而不是静态库 .a
# JGSourceFrameworkDemo 测试时建议指定 use_frameworks!，否则启动会有重复定义警告，例：
# Class MBProgressHUD is implemented in both /.../JGSourceBase (0x...) and /.../JGSourceFrameworkDemo (0x...). One of the two will be used. Which one is undefined.
# use_frameworks!

# JGSourceBaseDemo 测试时建议不指定 use_frameworks!，否则编译会有重复依赖警告，例：
# Multiple targets match implicit dependency for linker flags '-framework JGSourceBase'. Consider adding an explicit dependency on the intended target to resolve this ambiguity. (in target 'JGSourceBaseDemo' from project 'JGSourceBase')
## use_frameworks!

# workspace
workspace "JGSourceBase"

# platform
platform :ios, 11.0

abstract_target "JGSourceDemo" do
	
	pod 'IQKeyboardManager', '~> 6.5.9' #  https://github.com/hackiftekhar/IQKeyboardManager.git
	# pod 'SAMKeychain' # KeyChain 测试
	# pod 'FLAnimatedImage'
	
	#pod 'Masonry', '~> 1.1.0' # 该发布版本 mas_safeAreaLayoutGuide 有bug导致多条约束崩溃
	pod 'Masonry', :git => 'https://github.com/SnapKit/Masonry.git', :commit => '8bd77ea92bbe995e14c454f821200b222e5a8804' # https://github.com/cloudkite/Masonry.git
	
	# JGSourceBaseDemo 测试 Pod 引用 JGSourceBase
	target "JGSourceBaseDemo" do
		
		# pod 'JGSourceBase', :git => 'https://github.com/dengni8023/JGSourceBase.git', :commit => 'fcadf737e6ed5cfb1e7daccf0a2e17611568c604' #'~> 1.3.0'
		# pod 'JGSourceBase', '~> 1.3.0'
		pod 'JGSourceBase', :path => "."
		pod 'JGSourceBase/Base', :path => "." # Base测试
		pod 'JGSourceBase/Category', :path => "." # Category测试
		pod 'JGSourceBase/Device', :path => "." # Device测试
		pod 'JGSourceBase/Reachability', :path => "." # Reachability测试
		pod 'JGSourceBase/SecurityKeyboard', :path => "." # SecurityKeyboard测试
		
		# HUD
		pod 'JGSourceBase/HUD', :path => "." # HUD测试
		# 'Category/UIImage', :path => "."
		# pod 'JGSourceBase/HUD/Loading', :path => "." # HUD-Loading测试
		# 'Category/UIImage', :path => "."
		# pod 'JGSourceBase/HUD/Toast', :path => "." # HUD-Toast测试
		
		# project
		project "JGSourceBase.xcodeproj"
	end
	
	# JGSourceFrameworkDemo 测试引用 JGSourceBase.framework
	target "JGSourceFrameworkDemo" do
		
		# project
		project "JGSourceBase.xcodeproj"
	end
	
end

# JGSourceBase
target "JGSourceBase" do

	# JGSHUD
	pod 'MBProgressHUD'
	
	# project
	project "JGSourceBase.xcodeproj"
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
