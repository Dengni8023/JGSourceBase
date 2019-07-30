//
//  JGSKeyboardDemoViewController.m
//  JGSourceBaseDemo
//
//  Created by 梅继高 on 2019/5/29.
//  Copyright © 2019 MeiJigao. All rights reserved.
//

#import "JGSKeyboardDemoViewController.h"
#import <JGSourceBase/JGSourceBase.h>
#import <IQKeyboardManager/IQKeyboardManager.h>
#import <Masonry/Masonry.h>

@interface JGSKeyboardDemoViewController () <UITextFieldDelegate>

@property (nonatomic, strong) UITextField *normalInput;
@property (nonatomic, strong) UITextField *accountInput;
@property (nonatomic, strong) UITextField *secPwdInput;

@end

@implementation JGSKeyboardDemoViewController

#pragma mark - Life Cycle
- (void)dealloc {
    JGSLog(@"<%@: %p>", NSStringFromClass([self class]), self);
}

#pragma mark - Controller
- (void)viewDidLoad {
    [super viewDidLoad];
    
    JGSEnableLogWithMode(JGSLogModeFunc);
    
    [[JGSReachability sharedInstance] startMonitor];
    [[JGSReachability sharedInstance] addObserver:self statusChangeBlock:^(JGSReachabilityStatus status) {
        
        JGSEnableLogWithMode(JGSLogModeFunc);
        JGSLog(@"Network status: %@", [[JGSReachability sharedInstance] reachabilityStatusString]);
    }];
    
    self.title = @"iOS安全键盘";
    self.view.backgroundColor = [UIColor whiteColor];
    
    // IQKeyboardManager设置
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
    
        IQKeyboardManager *keyboardManager = [IQKeyboardManager sharedManager]; // 获取类库的单例变量
        keyboardManager.enable = YES;
        keyboardManager.shouldResignOnTouchOutside = YES; // 控制点击背景是否收起键盘
        keyboardManager.shouldToolbarUsesTextFieldTintColor = YES; // 控制键盘上的工具条文字颜色是否用户自定义
        keyboardManager.toolbarManageBehaviour = IQAutoToolbarByPosition; // 有多个输入框时，可以通过点击Toolbar 上的“前一个”“后一个”按钮来实现移动到不同的输入框
        keyboardManager.enableAutoToolbar = YES; // 控制是否显示键盘上的工具条
        keyboardManager.shouldShowToolbarPlaceholder = YES; // 是否显示占位文字
        keyboardManager.placeholderFont = [UIFont systemFontOfSize:16]; // 设置占位文字的字体
        keyboardManager.keyboardDistanceFromTextField = 10.0f; // 输入框距离键盘的距离
    });
    static BOOL JGSIQKeyboardEnable = NO;
    JGSIQKeyboardEnable = !JGSIQKeyboardEnable;
    [IQKeyboardManager sharedManager].enableAutoToolbar = JGSIQKeyboardEnable; // 控制整个功能是否启用
    
    [self addViewElements];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    JGSLog(@"Network status: %@", [[JGSReachability sharedInstance] reachabilityStatusString]);
}

#pragma mark - View
- (void)addViewElements {
    
    NSMutableArray<UITextField *> *fields = @[].mutableCopy;
    for (NSInteger i = 0; i < 3; i++) {
        
        UITextField *field = [[UITextField alloc] init];
        field.clearButtonMode = UITextFieldViewModeWhileEditing;
        field.returnKeyType = (i == 2 ? UIReturnKeyDone : UIReturnKeyNext);
        field.delegate = self;
        field.layer.borderColor = [UIColor colorWithWhite:0.9 alpha:1.0].CGColor;
        field.layer.borderWidth = 1.f / [UIScreen mainScreen].scale;
        field.layer.cornerRadius = 4.f;
        [self.view addSubview:field];
        
        [field mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(self.view);
            make.left.mas_equalTo(self.view).mas_offset(28);
            make.height.mas_equalTo(36);
            if (@available(iOS 11.0, *)) {
                make.top.mas_equalTo(self.view.mas_safeAreaLayoutGuideTop).mas_offset(32 + 60 * i);
            } else {
                make.top.mas_equalTo(self.view.mas_top).mas_offset(96 + 60 * i);
            }
        }];
        
        [fields addObject:field];
    }
    
    // 键盘设置
    self.normalInput = fields[0];
    self.normalInput.placeholder = @"系统键盘输入";
    
    self.accountInput = fields[1];
    self.accountInput.placeholder = @"安全键盘非加密输入";
    self.accountInput.inputView = [JGSSecurityKeyboard keyboardWithTextField:self.accountInput title:@"安全键盘非加密输入"];
    
    self.secPwdInput = fields[2];
    self.secPwdInput.placeholder = @"安全键盘加密输入";
    self.secPwdInput.secureTextEntry = YES;
    self.secPwdInput.inputView = [JGSSecurityKeyboard keyboardWithTextField:self.secPwdInput title:nil randomNumPad:NO];
}

#pragma mark - Action

#pragma mark - UITextFieldDelegate
- (void)textFieldDidBeginEditing:(UITextField *)textField {
    if ([textField.inputView isKindOfClass:[JGSSecurityKeyboard class]] && [(JGSSecurityKeyboard *)textField.inputView title].length > 0) {
        [IQKeyboardManager sharedManager].enableAutoToolbar = NO;
    }
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    if ([textField.inputView isKindOfClass:[JGSSecurityKeyboard class]]) {
        [IQKeyboardManager sharedManager].enableAutoToolbar = YES;
    }
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if ([textField isEqual:self.normalInput]) {
        [self.accountInput becomeFirstResponder];
    }
    else if ([textField isEqual:self.accountInput]) {
        [self.secPwdInput becomeFirstResponder];
    }
    else {
        [textField resignFirstResponder];
    }
    return YES;
}

@end
