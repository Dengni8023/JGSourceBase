source 'https://mirrors.tuna.tsinghua.edu.cn/git/CocoaPods/Specs.git'
# source 'https://github.com/cocoapods/specs.git'
# source 'https://cdn.cocoapods.org/'

# 私有库B依赖了模块A，同时在主工程里 添加A到 development pod，cocoapods 重复生成相同库的uuid
# pod install 警告信息 [!] [Xcodeproj] Generated duplicate UUIDs
install! 'cocoapods', :deterministic_uuids => false

# 源码测试请屏蔽此选项，否则源码库内部调用出现的警告将不会提示
inhibit_all_warnings!

use_frameworks! # 使用默认，动态链接
# use_frameworks! :linkage => :dynamic # 使用动态链接
# use_frameworks! :linkage => :static # 使用静态链接

# 将 pods 转为 Modular，因为 Modular 是可以直接在 Swift中 import ，所以不需要再经过 bridging-header 的桥接。
# 但是开启 use_modular_headers! 之后，会使用更严格的 header 搜索路径，开启后 pod 会启用更严格的搜索路径和生成模块映射
# 历史项目可能会出现重复引用等问题，因为在一些老项目里 CocoaPods 是利用Header Search Paths 来完成引入编译
# 当然使用 use_modular_headers!可以提高加载性能和减少体积。
use_modular_headers!

# workspace
workspace "JGSourceBase"

# platform
platform :ios, 13.0

# JGSourceBaseDemo
target "JGSourceBaseDemo" do
  
  # pod 'Masonry', '~> 1.1.0' # 该发布版本 mas_safeAreaLayoutGuide 有bug导致多条约束崩溃
  pod 'Masonry', :git => 'https://github.com/SnapKit/Masonry.git', :commit => '8bd77ea92bbe995e14c454f821200b222e5a8804' # https://github.com/cloudkite/Masonry.git
  
  # project
  project "JGSourceBaseDemo/JGSourceBaseDemo.xcodeproj"
end

# Hooks: post_install 在生成的 Pods project 写入硬盘前做最后的改动
post_install do |installer|
  puts ""
  puts "##### post_install start #####"

  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      # 设置 Pods 最低支持 iOS 版本
      if config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'].to_f < 13.0
        config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = 13.0
      end

      if target.name.to_s == "Pods-JGSourceBaseDemo"
        # puts "#{target.name}: #{config.base_configuration_reference.real_path}"
        # 获取当前配置对应的 xcconfig 文件路径
        xcconfig_path = config.base_configuration_reference.real_path
        xcconfig = File.read(xcconfig_path)
        # 配置内容追加
        [
          "#include \"../../../JGSourceBaseDemo/JGSourceBaseDemo/Target.xcconfig/JGSourceBaseDemo.#{config.name.downcase}.xcconfig\"",
        ].each do |additional|
          # 检查是否已经包含，避免重复
          unless xcconfig.include?(additional.strip)
            File.open(xcconfig_path, 'a') do |file|
              file.puts additional
            end
          end
        end
      end
    end
  end
  
  puts "##### post_install end #####"
  puts ""
end
