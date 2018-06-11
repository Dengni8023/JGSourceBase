
Pod::Spec.new do |s|

s.name          = "JGSourceBase"
s.version       = "0.0.5"

s.summary       = "JGSourceCode 通用定义、功能模块"
s.description   = <<-DESC

	JGSourceCode 通用定义、功能模块

	功能包括：
	1、通用日志控制模式
	2、通用重用标示快速定义
	3、Block循环引用常用定义weak、strong快捷处理
DESC

s.homepage      = "https://github.com/dengni8023/JGSourceBase"
s.license       = {
	:type => 'MIT',
	:file => 'LICENSE',
}
s.authors       = {
	"等你8023" => "945835664@qq.com",
},

s.source        = {
	:git => "https://github.com/dengni8023/JGSourceBase.git",
	:tag => "#{s.version}",
}
s.platforms     = {
	:ios => 8.0,
}
s.source_files  = "JGSourceBase/*.{h,m}"
s.public_header_files  = "JGSourceBase/*.h"

# s.resource    = "JGSourceBase.bundle"

# s.framework  = "SomeFramework"
# s.frameworks = "SomeFramework", "AnotherFramework"

# s.library   = "SomeLibararyy"
# s.libraries = "SomeLibararyy", "AnotherLibararyy"

# s.dependency "Dependency", "~> 4.0"
# s.dependency "Dependency/SUB"
# s.dependency "Dependency", "~> 2.1"

s.requires_arc = true

end
