//
//  JGSDViewController.m
//  JGSourceBaseDemo
//
//  Created by Mei JiGao on 2026/6/17.
//  Copyright © 2026 ByMountains. All rights reserved.
//

#import "JGSDViewController.h"
#import "JGSourceBaseDemo-Swift.h"

@interface JGSDViewController ()

/// 测试入口列表，默认根据sections、rows数据情况控制显示、隐藏
@property (nonatomic, strong) UITableView *tableView;
/// 页面内容较多时，使用该容器展示页面元素，默认隐藏
@property (nonatomic, strong) UIScrollView *scrollView;
/// 页面底部日志展示窗口，顶部接tableView、scrollView底部
@property (nonatomic, strong) UITextView *logTextView;

// 列表数据
@property (nonatomic, copy) NSArray<JGSDTableSectionData *> *sections;
@property (nonatomic, copy) NSArray<JGSDTableCellData *> *rows;

@end

@implementation JGSDViewController

- (void)setTitle:(NSString *)title {
    [super setTitle:title];
}

- (void)setSubtitle:(NSString *)subtitle {
    _subtitle = subtitle;
}

- (UITableView *)tableView {
    
    if (_tableView) {
        return _tableView;
    }
    
    UITableView *v = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    v.hidden = YES;
    v.backgroundColor = self.view.backgroundColor;
    v.alwaysBounceVertical = YES;
    v.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentAlways;
    
    v.sectionHeaderHeight = UITableViewAutomaticDimension;
    v.rowHeight = UITableViewAutomaticDimension;
    v.sectionFooterHeight = CGFLOAT_MIN;
    
    v.dataSource = self;
    v.delegate = self;
    [v registerClass:UITableViewCell.class forCellReuseIdentifier:@"UITableViewCell"];
    
    return _tableView = v;
}

- (UIScrollView *)scrollView {
    
    if (_scrollView) {
        return _scrollView;
    }
    
    UIScrollView *v = [[UIScrollView alloc] init];
    v.hidden = YES;
    v.backgroundColor = self.view.backgroundColor;
    v.alwaysBounceVertical = YES;
        
    // 撑开宽度
    UIView *line = [[UIView alloc] init];
    [v addSubview:line];
    [line mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.mas_equalTo(v);
        make.height.mas_equalTo(0);
        make.width.mas_equalTo(v);
    }];
    
    return _scrollView = v;
}

- (UITextView *)logTextView {
    
    if (_logTextView) {
        return _logTextView;
    }
    
    UITextView *v = [[UITextView alloc] init];
    v.backgroundColor = [UIColor whiteColor];
    v.editable = NO;
    v.textColor = [UIColor darkGrayColor];
    v.font = [UIFont systemFontOfSize:16];
    v.contentInset = UIEdgeInsetsMake(5, 5, 5, 5);
    
    v.attributedText = [[NSAttributedString alloc] initWithString:@"调试日志输出区域，内容可复制、不可编辑" attributes:@{NSForegroundColorAttributeName: [UIColor lightGrayColor]}];
    
    return _logTextView = v;
}

// MARK: - Data
- (void)setSections:(NSArray<JGSDTableSectionData *> *)sections {
    _sections = sections ?: @[];
}

- (void)setRows:(NSArray<JGSDTableCellData *> *)rows {
    _rows = rows ?: @[];
}

- (void)loadData {
    
}

- (void)setupData:(NSArray<JGSDTableSectionData *> *)sections rows:(NSArray<JGSDTableCellData *> *)rows {
    if (sections) {
        self.sections = sections;
    }
    if (rows) {
        self.rows = rows;
    }
    
    NSArray<JGSDTableCellData *> *secRows = [self.sections flatMap:^NSArray * _Nonnull(JGSDTableSectionData * _Nonnull obj) {
        return obj.rows;
    }];
    self.tableView.hidden = secRows.count + self.rows.count == 0;
}

// MARK: - Controller
- (void)dealloc {
    JGSLog(@"<%@: %p>", NSStringFromClass([self class]), self);
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.view.backgroundColor = [UIColor colorWithWhite:0.96 alpha: 1.0];
    
    // title
    self.title = self.title ?: [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleName"] ?: NSStringFromClass([self class]);
    NSString *version = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    NSString *build = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"];
    self.subtitle = [NSString stringWithFormat:@"%@ (%@)", version, build];
    
    [self loadData];
    [self setupViews];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
//#pragma clang diagnostic push
//#pragma clang diagnostic ignored "-Wdeprecated-declarations"
//    [JGSLogFunction enableLog:!JGSLogFunction.isLogEnabled];
//#pragma clang diagnostic pop
//    [JGSLogger enableLogWithMode:!JGSLogger.enableDebug level:JGSLogger.level useNSLog:JGSLogger.useNSLog];
//    [JGSLogger enableLogWithMode:!JGSLogger.enableDebug level:JGSLogger.level useNSLog:JGSLogger.useNSLog lengthLimit:JGSLogger.lengthLimit truncating:JGSLogger.truncating];
    
    JGSLog(@"%.02f", 0.926);
}

// MARK: - UI
- (void)setupViews {
    
    [self.view addSubview:self.scrollView];
    [self.scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self.view);
    }];
    
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self.view);
    }];
    
    [self.view addSubview:self.logTextView];
    [self.logTextView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.tableView.mas_bottom);
        make.top.equalTo(self.scrollView.mas_bottom);
        make.left.bottom.right.equalTo(self.view);
        make.height.equalTo(self.view).multipliedBy(0.25);
    }];
}

// MARK: - Console
- (void)showConsoleLog:(NSString *)format, ... {
    
    va_list varList;
    va_start(varList, format);
    NSString *message = [[NSString alloc] initWithFormat:format arguments:varList];
    va_end(varList);
    
    self.logTextView.text = [self.logTextView.text stringByAppendingFormat:@"\n%@", message];
    [self.logTextView scrollRangeToVisible:NSMakeRange(self.logTextView.text.length - 1, 1)];
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.sections.count > 0 ? self.sections.count : 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.sections.count > 0 ? self.sections[section].rows.count : self.rows.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell" forIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    JGSDTableCellData *rowData = self.sections.count > 0 ? self.sections[indexPath.section].rows[indexPath.row] : self.rows[indexPath.row];
    cell.textLabel.text = rowData.title;
    
    return cell;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (self.sections.count > 0) {
        return self.sections[section].title.length == 0 ? CGFLOAT_MIN : UITableViewAutomaticDimension;
    }
    return CGFLOAT_MIN;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (self.sections.count > 0) {
        return self.sections[section].title;
    }
    return nil;
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section {
    if ([@"26.0" compare:UIDevice.currentDevice.systemVersion] == NSOrderedDescending) {
        return;
    }
    
    // 设置原始文本，覆盖系统的大写文本
    [(UITableViewHeaderFooterView *)view textLabel].text = [self tableView:tableView titleForHeaderInSection:section];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    JGSDShowConsoleLog(self, @"indexPath: %@", indexPath)
    JGSDTableCellData *rowData = self.sections.count > 0 ? self.sections[indexPath.section].rows[indexPath.row] : self.rows[indexPath.row];
    
    // action 响应
    if (rowData.action) {
        rowData.action(indexPath);
    }
    
    // target-selector 响应
    if (rowData.target && rowData.selector && [rowData.target respondsToSelector:rowData.selector]) {
        
        // OC多参数实现，避免警告
        //IMP imp = class_getMethodImplementation(rowData.target.class, rowData.selector); // 需要 target: NSObject
        IMP imp = [rowData.target methodForSelector:rowData.selector];
        // (target, selector, args...)
        id (*func)(id, SEL, NSIndexPath *) = (void *)imp;
        func(rowData.target, rowData.selector, indexPath);
    }
}

@end
