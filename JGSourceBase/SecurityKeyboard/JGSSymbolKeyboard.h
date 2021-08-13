//
//  JGSSymbolKeyboard.h
//  
//
//  Created by 梅继高 on 2019/5/31.
//

#if __has_include(<JGSourceBase/JGSBaseKeyboard.h>)
#import <JGSourceBase/JGSBaseKeyboard.h>
#else
#import "JGSBaseKeyboard.h"
#endif

NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXTERN void JGSKeyboardSymbolFullAngleEnable(BOOL enable);

@interface JGSSymbolKeyboard : JGSBaseKeyboard

+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithCoder:(NSCoder *)aDecoder NS_UNAVAILABLE;
- (instancetype)initWithFrame:(CGRect)frame NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
