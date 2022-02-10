//
//  JGSDemoViewController.h
//  JGSourceBaseDemo
//
//  Created by 梅继高 on 2021/9/15.
//  Copyright © 2021 MeiJiGao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JGSDemoTableData.h"

NS_ASSUME_NONNULL_BEGIN

@interface JGSDemoViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong, readonly) UITableView *tableView;
@property (nonatomic, strong, readonly) UIScrollView *scrollView;
//@property (nonatomic, strong, readonly) UITextView *textView;

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
