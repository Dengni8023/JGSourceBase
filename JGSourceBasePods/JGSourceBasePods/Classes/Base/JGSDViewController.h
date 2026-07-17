//
//  JGSDViewController.h
//  JGSourceBaseDemo
//
//  Created by Mei JiGao on 2026/6/17.
//  Copyright © 2026 ByMountains. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Masonry/Masonry.h>
#import <JGSourceBase/JGSourceBase.h>
//@import JGSourceBase;
#import "JGSDConfig+Defines.h"

NS_ASSUME_NONNULL_BEGIN

#define JGSDShowConsoleLog(vcT, fmt, ...) { \
    JGSLog(fmt, ## __VA_ARGS__); \
    if ([vcT isKindOfClass:JGSDViewController.class]) { \
        dispatch_async(dispatch_get_main_queue(), ^{ \
            [vcT showConsoleLog:(@"%s Line: %@\n" fmt ""), __PRETTY_FUNCTION__, @(__LINE__), ## __VA_ARGS__]; \
        }); \
    } \
}

@interface JGSDViewController: UIViewController <UITableViewDataSource, UITableViewDelegate>

/// 副标题，用于设置多行标题
@property (nonatomic, copy, nullable) NSString *subtitle;

/// 测试入口列表，默认根据sections、rows数据情况控制显示、隐藏
@property (nonatomic, strong, readonly) UITableView *tableView;
/// 页面内容较多时，使用该容器展示页面元素，默认隐藏
@property (nonatomic, strong, readonly) UIScrollView *scrollView;
/// 页面底部日志展示窗口，顶部接tableView、scrollView底部
@property (nonatomic, strong, readonly) UITextView *logTextView;

// 列表数据
@property (nonatomic, copy, readonly, null_resettable) NSArray<JGSDTableSectionData *> *sections;
@property (nonatomic, copy, readonly, null_resettable) NSArray<JGSDTableCellData *> *rows;

- (void)showConsoleLog:(NSString *)format, ... NS_FORMAT_FUNCTION(1, 2);

/// 子类重写该方法调用 setupData (sections: rows: ) 设置页面数据
/// 不需要调用super
- (void)loadData;

/// final 禁止子类重写，仅允许调用
/// sections、rows 必须有一个不为空
- (void)setupData:(nullable NSArray<JGSDTableSectionData *> *)sections rows:(nullable NSArray<JGSDTableCellData *> *)rows;

// MARK: - UI
- (void)setupViews;

@end

NS_ASSUME_NONNULL_END
