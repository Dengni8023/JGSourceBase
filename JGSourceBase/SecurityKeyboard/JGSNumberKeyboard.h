//
//  JGSNumberKeyboard.h
//  
//
//  Created by 梅继高 on 2019/5/31.
//

#import "JGSBaseKeyboard.h"

NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXTERN void JGSKeyboardNumberPadRandomEnable(BOOL enable);

@interface JGSNumberKeyboard : JGSBaseKeyboard

+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithCoder:(NSCoder *)aDecoder NS_UNAVAILABLE;
- (instancetype)initWithFrame:(CGRect)frame NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
