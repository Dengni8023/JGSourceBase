//
//  JGSDemoViewController.m
//  JGSourceBaseDemo
//
//  Created by 梅继高 on 2021/9/15.
//  Copyright © 2021 MeiJiGao. All rights reserved.
//

#import "JGSDemoViewController.h"

NSDictionary<NSAttributedStringKey, id> *JGSDemoTitleTextAttributes(void) {
	
	//JGSLog(@"%f", [UIFont labelFontSize]); // 17
	//JGSLog(@"%f", [UIFont buttonFontSize]); // 18
	//JGSLog(@"%f", [UIFont smallSystemFontSize]); // 12
	//JGSLog(@"%f", [UIFont systemFontSize]); // 14
	
	NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
	style.lineBreakMode = NSLineBreakByTruncatingTail;
	style.alignment = NSTextAlignmentCenter;
	
	return @{
		NSFontAttributeName: [UIFont boldSystemFontOfSize:[UIFont buttonFontSize]],
		NSForegroundColorAttributeName: [UIColor whiteColor],
		NSParagraphStyleAttributeName: style,
	};
}

NSDictionary<NSAttributedStringKey, id> *JGSDemoSubTitleTextAttributes(void) {
	
	//JGSLog(@"%f", [UIFont labelFontSize]); // 17
	//JGSLog(@"%f", [UIFont buttonFontSize]); // 18
	//JGSLog(@"%f", [UIFont smallSystemFontSize]); // 12
	//JGSLog(@"%f", [UIFont systemFontSize]); // 14
	
	NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
	style.lineBreakMode = NSLineBreakByTruncatingTail;
	style.alignment = NSTextAlignmentCenter;
	
	return @{
		NSFontAttributeName: [UIFont systemFontOfSize:[UIFont smallSystemFontSize]],
		NSForegroundColorAttributeName: [UIColor whiteColor],
		NSParagraphStyleAttributeName: style,
	};
}

@interface JGSDemoViewController ()

@property (nonatomic, strong) UIView *titleView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *subTitleLabel;

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UITextView *textView;

@property (nonatomic, copy) NSArray<JGSDemoTableSectionData *> *demoData;

@end

@implementation JGSDemoViewController

@dynamic title;

#pragma mark - Life Cycle
- (void)dealloc {
    JGSLog(@"<%@: %p>", NSStringFromClass([self class]), self);
	//JGSDemoShowConsoleLog(self, @"<%@: %p>", NSStringFromClass([self class]), self);
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Controller
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = self.title ?: NSStringFromClass([self class]);
	
	if (arc4random() % 2 == 0) {
		NSString *version = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
		NSString *build = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"];
		self.subTitle = [NSString stringWithFormat:@"%@ (%@)", version, build];
	}
	
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
	
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"清理日志" style:UIBarButtonItemStylePlain target:self action:@selector(clenDebugAreaText:)];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.barTintColor = [UIColor blueColor];
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
	
    BOOL isPortrait = UIInterfaceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation);
    [self.textView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(self.textView.isHidden ? 0 : (isPortrait ? 180 : 120));
    }];
	
	if (@available(iOS 15.0, *)) {
		// UITableView
		[UITableView appearance].sectionHeaderTopPadding = 0;
	}
	
	if (@available(iOS 15.0, *)) {
		// NavigationBar
		UINavigationBarAppearance *navBarAppearance = [[UINavigationBarAppearance alloc] init];
		navBarAppearance.backgroundColor = self.navigationController.navigationBar.barTintColor ?: JGSDemoNavigationBarColor;
		navBarAppearance.titleTextAttributes = self.navigationController.navigationBar.titleTextAttributes;
		navBarAppearance.backgroundEffect = nil;
		navBarAppearance.shadowColor = [UIColor clearColor];
		navBarAppearance.shadowImage = self.navigationController.navigationBar.shadowImage;
		
		self.navigationController.navigationBar.scrollEdgeAppearance = navBarAppearance;
		self.navigationController.navigationBar.standardAppearance = navBarAppearance;
	}
	
	self.navigationItem.titleView = self.subTitle.length > 0 ? self.titleView : self.titleLabel;
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
        make.height.mas_equalTo(self.textView.isHidden ? 0 : (isPortrait ? 180 : 120));
    }];
}

#pragma mark - Title
- (UIView *)titleView {
	
	if (!_titleView) {
		
		_titleView = [[UIView alloc] init];
		_titleView.backgroundColor = nil;
		
		[_titleView addSubview:self.titleLabel];
		[self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
			make.top.centerX.mas_equalTo(_titleView);
			make.left.right.mas_greaterThanOrEqualTo(_titleView).inset(0);
		}];
		
		[_titleView addSubview:self.subTitleLabel];
		[self.subTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
			make.bottom.centerX.mas_equalTo(_titleView);
			make.left.right.mas_greaterThanOrEqualTo(_titleView).inset(0);
			make.top.mas_greaterThanOrEqualTo(self.titleLabel.mas_bottom).offset(0);
		}];
	}
	return _titleView;
}

- (UILabel *)titleLabel {
	
	if (!_titleLabel) {
		
		_titleLabel = [[UILabel alloc] init];
		
		NSDictionary<NSAttributedStringKey, id> *attributes = JGSDemoTitleTextAttributes();
		NSParagraphStyle *style = attributes[NSParagraphStyleAttributeName];
		
		_titleLabel.font = attributes[NSFontAttributeName];
		_titleLabel.textAlignment = style.alignment;
		_titleLabel.lineBreakMode = style.lineBreakMode;
		_titleLabel.textColor = attributes[NSForegroundColorAttributeName];
	}
	return _titleLabel;
}

- (UILabel *)subTitleLabel {
	
	if (!_subTitleLabel) {
		
		_subTitleLabel = [[UILabel alloc] init];
		
		NSDictionary<NSAttributedStringKey, id> *attributes = JGSDemoSubTitleTextAttributes();
		NSParagraphStyle *style = attributes[NSParagraphStyleAttributeName];
		
		_subTitleLabel.font = attributes[NSFontAttributeName];
		_subTitleLabel.textAlignment = style.alignment;
		_subTitleLabel.lineBreakMode = style.lineBreakMode;
		_subTitleLabel.textColor = attributes[NSForegroundColorAttributeName];
	}
	return _subTitleLabel;
}

- (void)setTitle:(NSString *)title {
	[self setTitle:title subTitle:nil];
}

- (void)setSubTitle:(NSString *)subTitle {
	[self setTitle:nil subTitle:subTitle];
}

- (void)setTitle:(NSString *)title subTitle:(NSString *)subTitle {
	title = title ?: (self.title ?: super.title);
	subTitle = subTitle ?: self.subTitle;
	
	if (title.length == 0) {
		title = subTitle;
		subTitle = nil;
	}
	
	// property
	super.title = title;
	_subTitle = subTitle;
	
	self.titleLabel.text = title;
	self.subTitleLabel.text = subTitle;
	
	//[self.titleLabel sizeToFit];
	//[self.subTitleLabel sizeToFit];
	//[self.titleView sizeToFit];
	//[self.titleView setNeedsLayout];
}

#pragma mark - Getter
- (UITableView *)tableView {
    
    if (!_tableView) {
        
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        _tableView.backgroundColor = [UIColor colorWithWhite:0.93 alpha:1.f];
        _tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentAlways;
        _tableView.hidden = YES;
        
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
        _scrollView.hidden = YES;
        
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
		_textView.layer.borderColor = [UIColor grayColor].CGColor;
		_textView.layer.borderWidth = JGSMinimumPoint;
        
        NSString *text = @"调试日志输出区域\n\n内容可复制、不可编辑";
        _textView.attributedText = [[NSAttributedString alloc] initWithString:text attributes:@{NSForegroundColorAttributeName: [UIColor darkGrayColor]}];
    }
    return _textView;
}

- (NSArray<JGSDemoTableSectionData *> *)demoData {
    
    _demoData = _demoData ?: [self tableSectionData].copy;
    return _demoData;
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    NSInteger sections = self.demoData.count;
    tableView.hidden = sections == 0;
    return sections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.demoData[section].rows.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:JGSReuseIdentifier(UITableViewCell) forIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    cell.textLabel.text = self.demoData[indexPath.section].rows[indexPath.row].title;
    cell.backgroundColor = JGSColorHex(arc4random() % 0x01000000);
    cell.contentView.backgroundColor = JGSColorHex(0xffffff);
    
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
    
    //JGSDemoShowConsoleLog(self, @"Selected IndexPath: {%@, %@}", @(indexPath.section), @(indexPath.row));
    JGSDemoTableRowData *rowData = self.demoData[indexPath.section].rows[indexPath.row];
    id object = rowData.target ?: self;
    if (rowData.selector && [object respondsToSelector:rowData.selector]) {
        
        // 避免警告
        IMP imp = [object methodForSelector:rowData.selector];
        id (*func)(id, SEL, NSIndexPath *, JGSDemoViewController *) = (void *)imp;
        func(object, rowData.selector, indexPath, self);
    }
}

#pragma mark - Console
- (void)showConsoleLog:(NSString *)format, ... {
    
    va_list varList;
    va_start(varList, format);
    NSString *message = [[NSString alloc] initWithFormat:format arguments:varList];
    va_end(varList);
    
    self.textView.text = [self.textView.text stringByAppendingFormat:@"\n%@", message];
    [self.textView scrollRangeToVisible:NSMakeRange(self.textView.text.length, 1)];
}

- (void)clenDebugAreaText:(id)sender {
    self.textView.text = nil;
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
    
    self.navigationBar.titleTextAttributes = JGSDemoTitleTextAttributes();
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
