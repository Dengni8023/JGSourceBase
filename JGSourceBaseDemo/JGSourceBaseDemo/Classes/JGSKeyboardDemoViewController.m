//
//  JGSKeyboardDemoViewController.m
//  JGSourceBaseDemo
//
//  Created by 梅继高 on 2019/5/29.
//  Copyright © 2019 MeiJigao. All rights reserved.
//

#import "JGSKeyboardDemoViewController.h"
#import <Masonry/Masonry.h>
#import <IQKeyboardManager/IQKeyboardManager.h>

@interface JGSKeyboardDemoViewController () <UITextFieldDelegate>

@property (nonatomic, strong) UITextField *normalInput;
@property (nonatomic, strong) UITextField *accountInput;
@property (nonatomic, strong) UITextField *secPwdInput;
@property (nonatomic, strong) UITextField *secPwdFullInput;

@end

@implementation JGSKeyboardDemoViewController

#pragma mark - Controller
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"SecurityKeyboard";
    
#ifdef JGS_SecurityKeyboard
    [self addViewElements];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:UITextFieldTextDidChangeNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
        
        UITextField *textField = (UITextField *)note.object;
        JGSLog(@"%@, %@", textField.text, textField.jg_securityOriginText);
    }];
#endif
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"小眼睛" style:UIBarButtonItemStylePlain target:self action:@selector(switchTextfieldSecurityEntry:)];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
}

#ifdef JGS_SecurityKeyboard
#pragma mark - View
- (void)addViewElements {
    
    NSMutableArray<UITextField *> *fields = @[].mutableCopy;
    for (NSInteger i = 0; i < 6; i++) {
        
        UITextField *field = [[UITextField alloc] init];
        field.clearButtonMode = UITextFieldViewModeWhileEditing;
        field.returnKeyType = (i == 2 ? UIReturnKeyDone : UIReturnKeyNext);
        field.keyboardType = UIKeyboardTypeDefault;
        field.placeholder = [NSString stringWithFormat:@"系统键盘输入-%@", @(i)];
        field.delegate = self;
        field.layer.borderColor = [UIColor colorWithWhite:0.9 alpha:1.0].CGColor;
        field.layer.borderWidth = 1.f / [UIScreen mainScreen].scale;
        field.layer.cornerRadius = 4.f;
        [self.scrollView addSubview:field];
        
        [field mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(36);
            make.left.right.mas_equalTo(self.scrollView).inset(28);
            make.top.mas_equalTo(self.scrollView).mas_offset(32 + 60 * i);
            if (i == 5) {
                make.bottom.mas_equalTo(self.scrollView.mas_bottom).inset(32);
            }
        }];
        
        [fields addObject:field];
    }
    
    // 键盘设置
    self.normalInput = fields[0];
    self.normalInput.keyboardType = arc4random() % 5 == 0 ? UIKeyboardTypeNumberPad : UIKeyboardTypeDefault;
    
    // 安全键盘设置
    static NSInteger accountInputShow = 0;
    accountInputShow += 1;
    self.accountInput = fields[1];
    self.accountInput.placeholder = @"安全键盘非加密输入";
    self.accountInput.inputView = [JGSSecurityKeyboard keyboardWithTextField:self.accountInput title:@"自定义安全键盘"];
    self.accountInput.returnKeyType = (accountInputShow % 2 == 0 ? UIReturnKeyDone : UIReturnKeyNext);

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
    self.secPwdFullInput.jg_aesEncryptInputCharByChar = YES;
    self.secPwdFullInput.inputView = [JGSSecurityKeyboard keyboardWithTextField:self.secPwdFullInput title:@"安全键盘加密输入-全角" randomNumPad:arc4random() % 2 == 0 enableFullAngle:YES];
    if (@available(iOS 10.0, *)) {
        self.secPwdFullInput.textContentType = UITextContentTypeNickname;
    }

    fields[4].placeholder = @"纯数字键盘";
    fields[4].inputView = [JGSSecurityKeyboard numberKeyboardWithTextField:fields[4] title:@"数字键盘" randomNumPad:(accountInputShow % 2 == 0)];
    fields[5].placeholder = @"身份证键盘";
    fields[5].inputView = [JGSSecurityKeyboard idCardKeyboardWithTextField:fields[5] title:@"身份证键盘" randomNumPad:(accountInputShow % 2 == 0)];
}

#pragma mark - Action
- (void)switchTextfieldSecurityEntry:(id)sender {
    
    //JGSLog(@"%@", sender);
    self.accountInput.secureTextEntry = !self.accountInput.secureTextEntry;
    self.secPwdInput.secureTextEntry = !self.secPwdInput.secureTextEntry;
    self.secPwdFullInput.secureTextEntry = !self.secPwdFullInput.secureTextEntry;
}

#pragma mark - UITextFieldDelegate
- (void)textFieldDidBeginEditing:(UITextField *)textField {
    
    if ([textField.inputView isKindOfClass:[JGSSecurityKeyboard class]] && [(JGSSecurityKeyboard *)textField.inputView title].length > 0) {
        [IQKeyboardManager sharedManager].enableAutoToolbar = NO;
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    if ([textField.inputView isKindOfClass:[JGSSecurityKeyboard class]]) {
        JGSLog(@"%@", textField.text);
        JGSLog(@"%@ -> (%@)", NSStringFromRange(range), string);
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

#endif

#pragma mark - End

@end
