//
//  JGSDemoViewController.h
//  JGSourceBaseDemo
//
//  Created by 梅继高 on 2021/9/15.
//  Copyright © 2021 MeiJiGao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JGSDemoTableData.h"
#import <Masonry/Masonry.h>

NS_ASSUME_NONNULL_BEGIN

#ifdef JGSBase_h
#define JGSDemoShowConsoleLog(vcT, fmt, ...) { \
    JGSLog(fmt, ##__VA_ARGS__); \
    if ([vcT respondsToSelector:@selector(showConsoleLog:)]) { \
        [vcT showConsoleLog:(@"%s Line: %@\n" fmt ""), __PRETTY_FUNCTION__, @(__LINE__), ##__VA_ARGS__]; \
    } \
}
#else
#define JGSDemoShowConsoleLog(vcT, fmt, ...) JGSLog(@"%s Line: %@\n" fmt "", __PRETTY_FUNCTION__, @(__LINE__), ##__VA_ARGS__);
#define JGSLog(fmt, ...) NSLog(@"%s Line: %@\n" fmt "", __PRETTY_FUNCTION__, @(__LINE__), ##__VA_ARGS__)
#endif

@interface JGSDemoViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, copy, nullable) NSString *title; // 标题
@property (nonatomic, copy, nullable) NSString *subTitle; // 副标题，用于设置多行标题

@property (nonatomic, strong, readonly) UITableView *tableView;
@property (nonatomic, strong, readonly) UIScrollView *scrollView;
@property (nonatomic, strong, readonly) UITextView *textView;

// 是否显示Table底部调试输出的文本框，默认YES
@property (nonatomic, assign) BOOL showTextView;

@property (nonatomic, copy) NSArray<JGSDemoTableSectionData *> *tableSectionData;

- (instancetype)initWithCoder:(NSCoder *)aDecoder NS_UNAVAILABLE;
- (instancetype)initWithNibName:(nullable NSString *)nibNameOrNil bundle:(nullable NSBundle *)nibBundleOrNil NS_UNAVAILABLE;

- (void)showConsoleLog:(NSString *)format, ...;

@end

@interface JGSDemoNavigationController : UINavigationController

@end

NS_ASSUME_NONNULL_END
