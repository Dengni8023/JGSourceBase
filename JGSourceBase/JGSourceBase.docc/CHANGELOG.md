
# `JGSourceBase`版本更新记录

---
### V1.4.5 - 2025.04.02

1. `Info.plist`校验不用过记录存储数据类型错误问题
2. `Method_Swizzing`导致系统表情键盘搜索表情死循环问题修复
3. `JGSJSON`优化，`Xcode16.3`范型问题优化

---
### V1.4.4 - 2024.10.12

1. `window`、`topViewController`获取优化
2. 安全键盘缺陷修复
3. 多巴胺越狱检测完善
4. 便捷数据获取、转换功能优化
5. 应用完整性校验`Plist`编码问题修复
6. `iPhone16`设备清单

---
### V1.4.3 - 2024.03.29

1. `Privacy`隐私数据API使用说明配置，配置参考：[所有开发者注意，苹果审核策略有变](https://juejin.cn/post/7267091810379759676)
2. `iOS`最低支持版本升级为`12.0`
3. `JSON`转对象前判断其实字符是否为标准`JSON`起始字符"`{`"或"`[`"

---
### V1.4.2 - 2023.09.25

1. `JGSJSON`基础类型转换功能
2. `iPhone15`设备`Model`映射
3. `iOS`设备映射仅使用本地资源文件

---
### V1.4.1 - 2022.11.16

1. 【FIX】修复`UITextView`无法接受`UIScrollViewDelegate`代理方法问题

---
### V1.4.0 - 2022.11.12

1. 安全键盘支持外接键盘
2. `iOS`设备清单支持在线更新功能
3. `RSA`加解密功能完善

---
### V1.3.1 - 2022.06.18

1. 应用完整性资源文件校验功能及脚本支持
2. 安全键盘功能优化
3. `iOS`设备清单资源文件加密
4. 增加`JGSourceBase.bundle`资源文件

---
### V1.3.0 - 2022.02.21

1. 字母、符号键盘支持随机布局
2. 键盘布局控制逻辑优化，有输入框属性修改为自定义键盘属性
3. `UITextView`输入支持安全键盘

---
### V1.2.2.1 - 2021.12.26

安全键盘内存逐字符加密默认处理方式修改

1. 默认使用`AES`对输入内容进行整体加密，输入变化时，重新对输入整体字符串加密一次
2. 逐字符加密在输入变化时，重新对每个输入字符加密一次

---
### V1.2.2 - 2021.12.21

1. 键盘转屏通知监听优化
2. 键盘输入内容支持逐字符加密，原生系统接口`textField.text`返回"`•`"掩码，`textField.jg_securityOriginText`返回输入原始内容

---
### V1.2.1 - 2021.12.01

安全键盘功能完善

1. 增加身份证输入专用数字键盘
2. `iPad`布局优化
3. 支持横竖屏切换
4. 键盘生命周期优化

---
### V1.2.0 - 2021.05.20

1. 安全键盘功能完善，禁止复制、粘贴
2. `Log`日志功能优化
3. 常用基础类功能扩展完善

---
### V1.1.0 - 2019.06.05

1. 添加自定义键盘

---
### V1.0.2 - 2019.05.12

1. `URL`处理方法整理
2. `JSON`解析移除不常用方法
3. `Toast`默认样式配置`bug`处理

---
### V1.0.1 - 2019.04.17

1. `UIViewController+JGSAlertController`方法参数命名与`JGSAlertController`保持一致
2. `HUD`功能模块整理

---
### V1.0.0 - 2019.03.28

`JGSourceCode`通用定义、功能模块。`iOS`项目常用功能，系统`UIAlertController`便捷方法封装(原项目：`JGActionSheetAlert`/`JGAlertController`)，`Reachability`网络状态监听(原项目：`JGNetworkReachability`)，`Loading HUD`显示，`Toast`显示。功能包括：

* `Base`
	
	1. 常用宏定义、常用警告消除、`SwizzledMethod`的严谨实现
	2. 通用日志控制功能
	3. 字符串、`URL`常用方法
	4. `Block`循环引用常用定义`weak`、`strong`快捷处理
	5. `NSDictionary`便捷取指定类型值方法
	6. `NSJSONSerialization`便捷方法封装
	7. `UIColor`便捷方法封装
	
* `AlertController`

	1. `UIAlertController`便捷方法封装
	
	* 原项目：[JGActionSheetAlert](https://github.com/dengni8023/JGActionSheetAlert.git)
	* 原项目：[JGAlertController](https://github.com/dengni8023/JGAlertController.git)
	 
* `Reachability`
	
	1. 网络状态获取、监听，支持多监听者
	
	* 原项目：[JGNetworkReachability](https://github.com/dengni8023/JGNetworkReachability.git)
	    
	
* `LoadingHUD`
	   
	1. 显示`Loading HUD`方法封装
	
* `Toast`

	1. 显示`Toast`

---
### V0.1.0 - 2018.06.24

* 常用功能修改

	1. 常用功能合并整理，增加`UIColor`相关功能
	2. 增加`Dictionary`兼容取值功能
	3. 增加`NSString`转`URL`、`URL`编码相关功能
	4. 增加`NSURL`查询参数功能
	
* 对象增加分类

	1. 增加合法`JSON`对象快捷获取`JSON`的功能
	2. 增加对象转换为字典功能

---
### V0.0.5 - 2018.06.12

1. 功能模块拆分
2. `Weak`、`Strong`处理优化
3. 前缀`JG`修改为`JGSC`

---
### V0.0.4 - 2018.04.27

1. `Xcode9.3` `log`类型警告处理

---

### V0.0.3 - 2018.03.16

1. `Log`结束不换行
2. `Demo`修改

---
### V0.0.2 - 2017.11.27

1. 头文件引用方式优化

---
### V0.0.1 - 2017.11.24

`JGSourceCode`通用定义、功能模块，功能包括：

1. 通用日志控制模式
2. 通用重用标示快速定义
3. `Bock`循环引用常用定义`weak`、`strong`快捷处理

---