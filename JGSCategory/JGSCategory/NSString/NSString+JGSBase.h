//
//  NSString+JGSBase.h
//  JGSourceBase
//
//  Created by 梅继高 on 2021/3/10.
//  Copyright © 2021 MeiJiGao. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSString (JGSBase)

/** URL参数特殊字符串编码 */
@property (nonatomic, copy, nullable, readonly) NSString *jg_URLEncodeString;

/**
 URL字符串中文、不可见字符处理
 作为URL的各部分包含特殊字符“&”与”?“的内容必须已进行url编码处理，处理方式参考jg_URLEncodeString
 */
@property (nonatomic, copy, nullable, readonly) NSString *jg_URLString;

/**
 URL字符串中文、不可见字符处理
 作为URL的各部分包含特殊字符“&”与”?“的内容必须已进行url编码处理，处理方式参考jg_URLEncodeString
 */
@property (nonatomic, strong, nullable, readonly) NSURL *jg_URL;

@end

NS_ASSUME_NONNULL_END
