//
//  JGSSymbolKeyboard.h
//  
//
//  Created by 梅继高 on 2019/5/31.
//

#import "JGSBaseKeyboard.h"

NS_ASSUME_NONNULL_BEGIN

@interface JGSSymbolKeyboard : JGSBaseKeyboard

@property (nonatomic, assign) BOOL showFullAngle; // 是否开启全角，默认关闭，支持全角时将支持全半角字符输入

+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithCoder:(NSCoder *)aDecoder NS_UNAVAILABLE;
- (instancetype)initWithFrame:(CGRect)frame NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
