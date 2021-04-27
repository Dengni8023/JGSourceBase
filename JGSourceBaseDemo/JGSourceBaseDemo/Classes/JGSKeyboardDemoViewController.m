//
//  JGSKeyboardDemoViewController.m
//  JGSourceBaseDemo
//
//  Created by 梅继高 on 2019/5/29.
//  Copyright © 2019 MeiJigao. All rights reserved.
//

#import "JGSKeyboardDemoViewController.h"

@interface JGSKeyboardDemoViewController () <UITextFieldDelegate>

@property (nonatomic, strong) UITextField *normalInput;
@property (nonatomic, strong) UITextField *accountInput;
@property (nonatomic, strong) UITextField *secPwdInput;
@property (nonatomic, strong) UITextField *secPwdFullInput;

@end

@implementation JGSKeyboardDemoViewController

#pragma mark - Life Cycle
- (void)dealloc {
    JGSLog(@"<%@: %p>", NSStringFromClass([self class]), self);
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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
    
    [self addViewElements];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:UITextFieldTextDidChangeNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
        
        UITextField *textField = (UITextField *)note.object;
        JGSLog(@"%@", textField.text);
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    JGSLog(@"Network status: %@", [[JGSReachability sharedInstance] reachabilityStatusString]);
}

#pragma mark - View
- (void)addViewElements {
    
    NSMutableArray<UITextField *> *fields = @[].mutableCopy;
    for (NSInteger i = 0; i < 4; i++) {
        
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
    self.normalInput.keyboardType = UIKeyboardTypeNumberPad;
    
    self.accountInput = fields[1];
    self.accountInput.placeholder = @"安全键盘非加密输入";
    self.accountInput.inputView = [JGSSecurityKeyboard keyboardWithTextField:self.accountInput title:@"自定义安全键盘"];
    
    self.secPwdInput = fields[2];
    self.secPwdInput.placeholder = @"安全键盘加密输入";
    self.secPwdInput.secureTextEntry = YES;
    self.secPwdInput.inputView = [JGSSecurityKeyboard keyboardWithTextField:self.secPwdInput title:nil randomNumPad:arc4random() % 2 == 0];
    [(JGSSecurityKeyboard *)self.secPwdInput.inputView setEnableHighlightedWhenTap:NO];
    if (@available(iOS 11.0, *)) {
        self.secPwdInput.textContentType = UITextContentTypePassword;
    }
    
    self.secPwdFullInput = fields[3];
    self.secPwdFullInput.placeholder = @"安全键盘加密输入-全角";
    self.secPwdFullInput.secureTextEntry = YES;
    self.secPwdFullInput.inputView = [JGSSecurityKeyboard keyboardWithTextField:self.secPwdFullInput title:nil randomNumPad:arc4random() % 2 == 0 enableFullAngle:YES];
    if (@available(iOS 10.0, *)) {
        self.secPwdFullInput.textContentType = UITextContentTypeNickname;
    }
}

#pragma mark - Action
- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    self.accountInput.secureTextEntry = !self.accountInput.secureTextEntry;
    self.secPwdInput.secureTextEntry = !self.secPwdInput.secureTextEntry;
    self.secPwdFullInput.secureTextEntry = !self.secPwdFullInput.secureTextEntry;
}

#pragma mark - UITextFieldDelegate
- (void)textFieldDidBeginEditing:(UITextField *)textField {
    if ([textField.inputView isKindOfClass:[JGSSecurityKeyboard class]] && [(JGSSecurityKeyboard *)textField.inputView title].length > 0) {
//        [IQKeyboardManager sharedManager].enableAutoToolbar = NO;
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    if ([textField.inputView isKindOfClass:[JGSSecurityKeyboard class]]) {
        
        JGSLog(@"%@", textField.text);
        JGSLog(@"%@: %@", NSStringFromRange(range), string);
    }
    
    return YES;
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
    else if ([textField isEqual:self.secPwdInput]) {
        [self.secPwdFullInput becomeFirstResponder];
    }
    else {
        [textField resignFirstResponder];
    }
    return YES;
}

@end
