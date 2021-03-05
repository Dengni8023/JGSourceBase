#source 'https://github.com/cocoaPods/specs.git'
source 'https://mirrors.tuna.tsinghua.edu.cn/git/CocoaPods/Specs.git'

# 私有库B依赖了模块A，同时在主工程里 添加A到 development pod，cocoapods 重复生成相同库的uuid
# pod install 警告信息 [!] [Xcodeproj] Generated duplicate UUIDs
install!'cocoapods', :deterministic_uuids => false

# 源码测试请屏蔽此选项，否则源码库内部调用出现的警告将不会提示
#inhibit_all_warnings!
#use_frameworks!

# workspace
workspace "JGSourceBase"

# platform
platform :ios, 10.0

# JGSourceBaseDemo
target "JGSourceBaseDemo" do
  
  pod 'IQKeyboardManager', '~> 6.5.6' #  https://github.com/hackiftekhar/IQKeyboardManager.git
  
  # Local
  pod 'JGSourceBase', :path => "."
  
  #pod 'Masonry', '~> 1.1.0' # 该发布版本 mas_safeAreaLayoutGuide 有bug导致多条约束崩溃
  pod 'Masonry', :git => 'https://github.com/SnapKit/Masonry.git', :commit => '8bd77ea92bbe995e14c454f821200b222e5a8804' # https://github.com/cloudkite/Masonry.git
  
  # project
  project "JGSourceBaseDemo/JGSourceBaseDemo.xcodeproj"
end

# 临时的Class,用来提取Class公共的方法列表和要手动过滤方法列表
class TempClass
    # 定义一下需要过滤的方法
    def initialize
    end
    
    def to_yaml
    end
    
    def +(other)
    end
    
    def -(other)
    end
    
    def *(other)
    end
    
    def /(other)
    end
    
    def -@
    end
  end

# 这里创建了全局变量，来存储TempClass对象的方法列表
# 这个全局变量是为了后面做方法列表滤用。
$classPublicMethos = TempClass.new().public_methods

# 定义一个方法，打印对象属性和方法列表，并递归打印对象的属性，输出日志很多，请使用 Pod install > .PodInstallLog，以将日志输出到文件
# param: instance 要打印的对象
# param: name 对象的名称
# param: currentLayer 当前对象距离顶层的层级
# param: maxLayer 要打印的最大的层级，层级越大日志越多，未找到需要的值信息是可以增大层级之后install查看日志
def putsInstanceVariables(instance,name,currentLayer=0,maxLayer=3)
  
  # 当前层级是否在最大层级内
  if currentLayer < maxLayer
    if (false ||
        # 测试屏蔽非必要层级、节点日志
        # (currentLayer == 1 && name.to_s != "@pods_project") ||
        # (currentLayer == 2 && name.to_s != "@root_object") ||
        # (currentLayer == 3 && name.to_s != "@simple_attributes_hash") ||
        # (currentLayer == 4 && name.to_s != "attributes") ||
        # (currentLayer == 5 && name.to_s != "LastUpgradeCheck") ||
        false)
        proc do
          return
        end.call
    end
    # puts "#{' '*(currentLayer+1)}╟ <#{currentLayer}, #{maxLayer}>"
    # puts "#{' '*(currentLayer+1)}╟ #{name} > LogLayer-#{currentLayer}"
    if instance.nil?
      # instance是空值
      # 一个字符串乘以一个�整数，就是对应整数个字符串拼接
      # ' '*2 结果为 '    '
      # "#{' '*(currentLayer+1)}╟ "作用就是方便查看层级，使用VSCode编辑器就可以折叠对应的层级来查看
      puts "#{' '*(currentLayer+1)}╟ #{name} : nil"
      elsif instance.instance_of? Numeric
      # instance是数字
      puts "#{' '*(currentLayer+1)}╟ #{name} : #{instance}"
      elsif instance.instance_of? TrueClass
      # instance是ture值
      puts "#{' '*(currentLayer+1)}╟ #{name} : true"
      elsif instance.instance_of? FalseClass
      # instance是false值
      puts "#{' '*(currentLayer+1)}╟ #{name} : false"
      elsif instance.instance_of? Pathname
      # instance是路径
      puts "#{' '*(currentLayer+1)}╟ #{name} : #{instance.to_s}"
      elsif instance.instance_of? Array
      # instance为数组对象
      puts "#{' '*(currentLayer+1)}╟ #{name} : Array(Length: #{instance.length})"
      # 遍历数组
      instance.each_index do |index|
        item = instance.at(index)
        # 递归调用,打印数组中的对象,名称为index，层级+1
        putsInstanceVariables item, "#{index}", currentLayer+1, maxLayer
      end
      elsif instance.instance_of? Hash
      # instance为Hash对象,为<Key,Value>形式的集合
      puts "#{' '*(currentLayer+1)}╟ #{name} : Hash(Length: #{instance.length})"
      # 遍历Hash,取出key,value
      instance.each do |key,value|
        # 递归调用,打印Hash中的对象,名称为key，层级+1
        putsInstanceVariables value, "#{key}", currentLayer+1, maxLayer
      end
      else
      # instance为普通对象
      puts "#{' '*(currentLayer+1)}╟ #{name} : #{instance.to_s}"
      # 遍历对象所有属性名称
      instance.instance_variables.each do |variableName|
        # 根据名称获取属性
        variable = instance.instance_variable_get(variableName)
        # 递归调用,打印属性对象信息,名称为属性名，层级+1
        putsInstanceVariables variable, variableName, currentLayer+1, maxLayer
      end
      
      # 过滤掉通用方法
      # 数组使用"-"号就可以进行过滤
      publicMethods = (instance.public_methods - $classPublicMethos)
      # 打印公开方法
      puts "#{' '*(currentLayer+2)}╟ public_methods : Array(Length: #{publicMethods.length})"
      # 过滤Class都有的公共的方法
      publicMethods.each do |method|
          puts "#{' '*(currentLayer+3)}╟ #{method}"
      end
    end
  end
end

# Hooks: pre_install 在Pods被下载后但是还未安装前对Pods做一些改变
pre_install do |installer|
  puts ""
  puts "##### pre_install start #####"
  
  # 打印installer信息
  # putsInstanceVariables installer, "installer", 0, 1
  
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
  
  # 打印installer信息
  # putsInstanceVariables installer, "installer", 0, 1
  # putsInstanceVariables installer.pods_project.root_object.simple_attributes, "simple_attributes", 0, 2
  
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      # 设置Pods最低版本
      if config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'].to_f < 10.0
        config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = 10.0
      end
    end
  end
  
  puts "##### post_install end #####"
  puts ""
end
