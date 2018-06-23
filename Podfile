source 'https://github.com/CocoaPods/Specs.git'

# 源码测试请屏蔽此选项，否则源码库内部调用出现的警告将不会提示
#inhibit_all_warnings!
use_frameworks!

# workspace
workspace "JGSourceBase"

# platform
platform :ios, '9.0'

# JGSourceBase
target "JGSourceBaseDemo" do
    
    # Local
    pod 'JGSourceBase', :path => "."
    pod 'JGSourceBase/NSObject', :path => "."

    # project
    project "JGSourceBaseDemo/JGSourceBaseDemo.xcodeproj"
end
