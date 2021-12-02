//
//  JGSDemoViewController.m
//  JGSourceBaseDemo
//
//  Created by 梅继高 on 2021/9/15.
//  Copyright © 2021 MeiJigao. All rights reserved.
//

#import "JGSDemoViewController.h"
#import <Masonry/Masonry.h>

@interface JGSDemoViewController ()

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UITextView *textView;

@property (nonatomic, copy) NSArray<JGSDemoTableSectionData *> *demoData;

@end

@implementation JGSDemoViewController

#pragma mark - Life Cycle
- (void)dealloc {
    JGSLog(@"<%@: %p>", NSStringFromClass([self class]), self);
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Controller
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = self.title ?: NSStringFromClass([self class]);
    self.view.backgroundColor = [UIColor colorWithWhite:0.99 alpha:1.f];
    
    // tableView
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.mas_equalTo(self.view.mas_safeAreaLayoutGuide);
    }];
    
    // scrollView
    [self.view addSubview:self.scrollView];
    [self.scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.tableView);
    }];
    
    // TextView
    [self.view addSubview:self.textView];
    [self.textView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.tableView.mas_bottom);
        make.height.mas_equalTo(0);
        make.left.bottom.right.mas_equalTo(self.view);
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.barTintColor = [UIColor blueColor];
#ifdef JGS_Category_UIColor
    switch (arc4random() % 5) {
        case 0:
            self.navigationController.navigationBar.barTintColor = JGSDemoNavigationBarColor;
            break;
            
        case 1:
            self.navigationController.navigationBar.barTintColor = JGSDemoRadiusGradientCenter;
            break;
            
        default:
            self.navigationController.navigationBar.barTintColor = JGSDemoRadiusGradientEnd;
            break;
    }
#endif
    
    BOOL isPortrait = UIInterfaceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation);
    self.tableView.hidden = (self.tableSectionData.count == 0);
    self.scrollView.hidden = !self.tableView.hidden;
    [self.textView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(self.showTextView ? (isPortrait ? 180 : 120) : 0);
    }];
}

- (void)viewSafeAreaInsetsDidChange {
    [super viewSafeAreaInsetsDidChange];
    
    UIEdgeInsets inset = self.view.safeAreaInsets;
    UIEdgeInsets contentInset = UIEdgeInsetsMake(6, inset.left + 16, inset.bottom + 6, inset.right + 16);
    self.textView.contentInset = contentInset;
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    
    BOOL isPortrait = size.height > size.width;
    [self.textView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(self.showTextView ? (isPortrait ? 180 : 120) : 0);
    }];
}

#pragma mark - Getter
- (UITableView *)tableView {
    
    if (!_tableView) {
        
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        _tableView.backgroundColor = [UIColor colorWithWhite:0.93 alpha:1.f];
        _tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentAlways;
        
        _tableView.sectionHeaderHeight = 44;
        _tableView.rowHeight = 44;
        
        _tableView.dataSource = self;
        _tableView.delegate = self;
        
        [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:JGSReuseIdentifier(UITableViewCell)];
    }
    return _tableView;
}

- (UIScrollView *)scrollView {
    
    if (!_scrollView) {
        
        _scrollView = [[UIScrollView alloc] init];
        _scrollView.backgroundColor = [UIColor clearColor];
        _scrollView.alwaysBounceVertical = YES;
        
        UIView *line = [[UIView alloc] init];
        [_scrollView addSubview:line];
        
        [line mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.top.right.mas_equalTo(_scrollView);
            make.height.mas_equalTo(1);
            make.width.mas_equalTo(_scrollView);
        }];
    }
    return _scrollView;
}

- (UITextView *)textView {
    
    if (!_textView) {
        
        _textView = [[UITextView alloc] init];
        _textView.editable = NO;
        _textView.font = [UIFont systemFontOfSize:16];
        
        NSString *text = @"Debug Log Area \n\n内容可复制、不可编辑";
        _textView.attributedText = [[NSAttributedString alloc] initWithString:text attributes:@{NSForegroundColorAttributeName: [UIColor lightGrayColor]}];
    }
    return _textView;
}

- (NSArray<JGSDemoTableSectionData *> *)demoData {
    
    _demoData = _demoData ?: [self tableSectionData].copy;
    return _demoData;
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.demoData.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.demoData[section].rows.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:JGSReuseIdentifier(UITableViewCell) forIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    cell.textLabel.text = self.demoData[indexPath.section].rows[indexPath.row].title;
    
    return cell;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return self.demoData[section].title.length > 0 ? 32 : CGFLOAT_MIN;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UILabel *header = [[UILabel alloc] init];
    header.text = self.demoData[section].title;
    header.textColor = [UIColor colorWithWhite:0.36 alpha:1.f];
    return header;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return [[UIView alloc] init];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return CGFLOAT_MIN;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    //JGSLog(@"Selected IndexPath: {%@, %@}", @(indexPath.section), @(indexPath.row));
    JGsDemoTableRowData *rowData = self.demoData[indexPath.section].rows[indexPath.row];
    id object = rowData.object ?: self;
    if (rowData.selector && [object respondsToSelector:rowData.selector]) {
        
        // 避免警告
        IMP imp = [object methodForSelector:rowData.selector];
        id (*func)(id, SEL, NSIndexPath *) = (void *)imp;
        func(object, rowData.selector, indexPath);
    }
}

#pragma mark - Console
- (void)showConsoleLog:(NSString *)format, ... {
    
    va_list varList;
    va_start(varList, format);
    JGSLogv(format, varList);
    NSString *message = [[NSString alloc] initWithFormat:format arguments:varList];
    va_end(varList);
    
    self.textView.text = message;
}

#pragma mark - End

@end

@interface JGSDemoNavigationController ()

@end

@implementation JGSDemoNavigationController

#pragma mark - Life Cycle
- (void)dealloc {
    JGSLog(@"<%@: %p>", NSStringFromClass([self class]), self);
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Controller
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.lineBreakMode = NSLineBreakByTruncatingTail;
    style.lineBreakMode = NSLineBreakByWordWrapping;
    self.navigationBar.titleTextAttributes = @{
        NSFontAttributeName: [UIFont systemFontOfSize:17 weight:UIFontWeightMedium],
        NSForegroundColorAttributeName: [UIColor whiteColor],
        NSParagraphStyleAttributeName: style};
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - End

@end
