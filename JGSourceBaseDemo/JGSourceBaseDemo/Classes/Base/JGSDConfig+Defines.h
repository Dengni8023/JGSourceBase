//
//  JGSDConfig+Defines.h
//  JGSourceBaseDemo
//
//  Created by Mei JiGao on 2026/6/18.
//  Copyright © 2026 ByMountains. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

//NSDictionary<NSAttributedStringKey, id> *JGSDTitleTextAttributes(void) {
//    
//    //JGSLog(@"%f", [UIFont labelFontSize]); // 17
//    //JGSLog(@"%f", [UIFont buttonFontSize]); // 18
//    //JGSLog(@"%f", [UIFont smallSystemFontSize]); // 12
//    //JGSLog(@"%f", [UIFont systemFontSize]); // 14
//    
//    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
//    style.lineBreakMode = NSLineBreakByTruncatingTail;
//    style.alignment = NSTextAlignmentCenter;
//    
//    return @{
//        NSFontAttributeName: [UIFont boldSystemFontOfSize:[UIFont buttonFontSize]],
//        NSForegroundColorAttributeName: [UIColor whiteColor],
//        NSParagraphStyleAttributeName: style,
//    };
//}

//NSDictionary<NSAttributedStringKey, id> *JGSDSubTitleTextAttributes(void) {
//    
//    //JGSLog(@"%f", [UIFont labelFontSize]); // 17
//    //JGSLog(@"%f", [UIFont buttonFontSize]); // 18
//    //JGSLog(@"%f", [UIFont smallSystemFontSize]); // 12
//    //JGSLog(@"%f", [UIFont systemFontSize]); // 14
//    
//    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
//    style.lineBreakMode = NSLineBreakByTruncatingTail;
//    style.alignment = NSTextAlignmentCenter;
//    
//    return @{
//        NSFontAttributeName: [UIFont systemFontOfSize:[UIFont smallSystemFontSize]],
//        NSForegroundColorAttributeName: [UIColor whiteColor],
//        NSParagraphStyleAttributeName: style,
//    };
//}

@interface JGSDTableCellData : NSObject

/// cell 展示标题
@property (nonatomic, copy, readonly) NSString *title;

/// cell 点击的 target-selector 响应
/// - target: 响应接收者
/// - selector: 接收者的具体响应方法，接受一个 NSIndexPath 参数，对应 cell 的 indexPath
@property (nonatomic, assign, nullable, readonly) id target;
@property (nonatomic, assign, nullable, readonly) SEL selector;

/// cell 点击的 block 响应，接受一个 IndexPath 参数，对应 cell 的 indexPath
@property (nonatomic, copy, nullable, readonly) void (^action)(NSIndexPath *indexPath);

+ (instancetype)new NS_UNAVAILABLE;
+ (instancetype)dataWithTitle:(NSString *)title;
+ (instancetype)dataWithTitle:(NSString *)title target:(id)target selector:(SEL)selector;
+ (instancetype)dataWithTitle:(NSString *)title action:(void (^)(NSIndexPath *indexPath))action;
+ (instancetype)dataWithTitle:(NSString *)title target:(nullable id)target selector:(nullable SEL)selector action:(nullable void (^)(NSIndexPath *indexPath))action;

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithTitle:(NSString *)title;
- (instancetype)initWithTitle:(NSString *)title target:(id)target selector:(SEL)selector;
- (instancetype)initWithTitle:(NSString *)title action:(void (^)(NSIndexPath *indexPath))action;
- (instancetype)initWithTitle:(NSString *)title target:(nullable id)target selector:(nullable SEL)selector action:(nullable void (^)(NSIndexPath *indexPath))action;

@end

@interface JGSDTableSectionData : NSObject

/// section 展示标题
@property (nonatomic, copy, readonly) NSString *title;

/// section 内 cell 数据
@property (nonatomic, copy, readonly) NSArray<JGSDTableCellData *> *rows;

+ (instancetype)new NS_UNAVAILABLE;
+ (instancetype)sectionWithTitle:(NSString *)title rows:(NSArray<JGSDTableCellData *> *)rows;

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithTitle:(NSString *)title rows:(NSArray<JGSDTableCellData *> *)rows;

@end

NS_ASSUME_NONNULL_END
