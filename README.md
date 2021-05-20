<!--
 * @Author: 梅继高
 * @Date: 2021-01-12 21:25:08
 * @LastEditTime: 2021-05-20 21:45:06
 * @LastEditors: 梅继高
 * @Description: README.md
 * @FilePath: /JGSourceBase/README.md
-->
# JGSourceBase

JGSourceCode通用功能模块：iOS项目常用功能（UIAlertController、Reachability、Loading-HUD、Toast-HUD）；自定义安全键盘。

功能包括：

#### Base - 通用定义、功能模块、iOS项目常用功能

>
1. 常用宏定义、常用警告消除、SwizzledMethod的严谨实现
2. 通用日志控制功能
3. 字符串、URL常用方法
4. Block循环引用常用定义weak、strong快捷处理
5. NSDictionary便捷取指定类型值方法
6. NSJSONSerialization便捷方法封装
7. UIColor便捷方法封装
	
#### AlertController - 系统UIAlertController便捷方法封装(原项目：JGActionSheetAlert/JGAlertController)

	原项目：JGActionSheetAlert => https://github.com/dengni8023/JGActionSheetAlert.git
	原项目：JGAlertController => https://github.com/dengni8023/JGAlertController.git

>
1. UIAlertController便捷方法封装
	
#### Reachability - 网络状态监听(原项目：JGNetworkReachability)

	原项目：JGNetworkReachability => https://github.com/dengni8023/JGNetworkReachability.git

>
1. 网络状态获取、监听，支持多监听者
	
#### HUD - Loading-HUD、Toast-HUD显示

>
1. 显示Loading HUD方法封装
2. 显示Toast HUD方法封装

#### SecurityKeyboard - 自定义安全键盘

>
1. 字母键盘支持单字母大小写切换、选中大写
2. 符号键盘支持与数字混合展示，支持全角、半角字符
3. 数字键盘支持随机/非随机

## 使用方法

##### 基础功能模块、UIAlertController便捷封装功能

	pod 'JGSourceBase'

##### 网络状态监听模块

	pod 'JGSourceBase/Reachability'

##### HUD（Loading、Toast）功能

	pod 'JGSourceBase/HUD'
    
##### 自定义安全键盘

	pod 'JGSourceBase/SecurityKeyboard'


## Podfile引入subpec注意事项


	pod 'JGSourceBase', :path => ".", :subspecs => ['HUD/LoadingHUD'] # 该方式父spec文件可能不会引入

	pod 'JGSourceBase/HUD/LoadingHUD', :path => "." # 该方式父spec文件可能会引入
