source 'https://mirrors.tuna.tsinghua.edu.cn/git/CocoaPods/Specs.git'
# source 'https://github.com/cocoapods/specs.git'
# source 'https://cdn.cocoapods.org/'

# 私有库B依赖了模块A，同时在主工程里 添加A到 development pod，cocoapods 重复生成相同库的uuid
# pod install 警告信息 [!] [Xcodeproj] Generated duplicate UUIDs
install! 'cocoapods', :deterministic_uuids => false

# 源码测试请屏蔽此选项，否则源码库内部调用出现的警告将不会提示
# inhibit_all_warnings!

# use_frameworks! 要求生成的是 .framework 而不是静态库 .a
# JGSourceFrameworkDemo 测试时必须指定 use_frameworks!，否则运行报错，例：
# Include of non-modular header inside framework module 'JGSourceBase': '.../Pods/Headers/Public/JGSourceBase/JGSBase.h'
use_frameworks! # JGSourceFrameworkDemo 测试时必须指定，即开启本行

# JGSourceBaseDemo 测试时建议不指定 use_frameworks!，否则编译会有重复依赖警告，例：
# Multiple targets match implicit dependency for linker flags '-framework JGSourceBase'. Consider adding an explicit dependency on the intended target to resolve this ambiguity. (in target 'JGSourceBaseDemo' from project 'JGSourceBaseDemo')
# use_frameworks! # JGSourceBaseDemo 测试时建议不指定，即注释此行

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
		
		# pod 'JGSourceBase', :git => 'https://github.com/dengni8023/JGSourceBase.git', :commit => 'd620ee8f5c1e782364804da8b5c541d2de38f55c' #'~> 1.4.0'
		# pod 'JGSourceBase', '~> 1.3.0'
		pod 'JGSourceBase', :path => "."
		# pod 'JGSourceBase/Base', :path => "."
		# pod 'JGSourceBase/Category', :path => "."
		# pod 'JGSourceBase/Category/NSData', :path => "."
		# pod 'JGSourceBase/Category/NSDate', :path => "."
		# pod 'JGSourceBase/Category/NSDictionary', :path => "."
		# pod 'JGSourceBase/Category/NSObject', :path => "."
		# pod 'JGSourceBase/Category/NSString', :path => "."
		# pod 'JGSourceBase/Category/NSURL', :path => "."
		# pod 'JGSourceBase/Category/UIAlertController', :path => "."
		# pod 'JGSourceBase/Category/UIApplication', :path => "."
		# pod 'JGSourceBase/Category/UIColor', :path => "."
		# pod 'JGSourceBase/Category/UIImage', :path => "."
		# pod 'JGSourceBase/DataStorage', :path => "."
		# pod 'JGSourceBase/Device', :path => "."
		# pod 'JGSourceBase/Encryption', :path => "."
		# pod 'JGSourceBase/IntegrityCheck', :path => "."
		# pod 'JGSourceBase/Reachability', :path => "."
		# pod 'JGSourceBase/SecurityKeyboard', :path => "."
		
		# HUD
		# pod 'JGSourceBase/HUD', :git => 'https://github.com/dengni8023/JGSourceBase.git', :commit => 'd620ee8f5c1e782364804da8b5c541d2de38f55c'
		pod 'JGSourceBase/HUD', :path => "."
		# pod 'JGSourceBase/HUD/Loading', :path => "."
		# pod 'JGSourceBase/HUD/Toast', :path => "."
		
		JGSApplicationIntegrityCheckScriptPods = <<-CMD
			chmod +x ${PROJECT_DIR}/JGSDemoScripts/JGSIntegrityCheckAfterCompile.sh # sh执行权限
			${PROJECT_DIR}/JGSDemoScripts/JGSIntegrityCheckAfterCompile.sh # 执行sh
		CMD
		script_phase :name => "JGSIntegrityCheck", :script => JGSApplicationIntegrityCheckScriptPods, :execution_position => :after_compile

		# project
		project "JGSourceBaseDemo/JGSourceBaseDemo.xcodeproj"
	end
	
	# JGSourceFrameworkDemo 测试引用 JGSourceBase.framework
	target "JGSourceFrameworkDemo" do
		
		# JGSHUD
		pod 'MBProgressHUD'
		
		JGSApplicationIntegrityCheckScriptFramework = <<-CMD
			chmod +x ${PROJECT_DIR}/JGSDemoScripts/JGSIntegrityCheckAfterCompile.sh # sh执行权限
			${PROJECT_DIR}/JGSDemoScripts/JGSIntegrityCheckAfterCompile.sh # 执行sh
		CMD
		script_phase :name => "JGSIntegrityCheck", :script => JGSApplicationIntegrityCheckScriptFramework, :execution_position => :after_compile

		# project
		project "JGSourceBaseDemo/JGSourceBaseDemo.xcodeproj"
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
