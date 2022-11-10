//
//  JGSKeyboardDemoViewController.m
//  JGSourceBaseDemo
//
//  Created by 梅继高 on 2019/5/29.
//  Copyright © 2019 MeiJiGao. All rights reserved.
//

#import "JGSKeyboardDemoVC.h"
#import <IQKeyboardManager/IQKeyboardManager.h>

@interface JGSKeyboardDemoVC () <UITextFieldDelegate, UITextViewDelegate>

@property (nonatomic, strong) UITextField *normalInput;
@property (nonatomic, strong) UITextField *accountInput;
@property (nonatomic, strong) UITextField *secPwdInput;
@property (nonatomic, strong) UITextField *secPwdFullInput;

@property (nonatomic, strong) UITextView *secTextView;

@end

@implementation JGSKeyboardDemoVC

#pragma mark - Controller
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"SecurityKeyboard";
    
#ifdef JGSSecurityKeyboard_h
    [self addViewElements];
    
    JGSWeakSelf
    [[NSNotificationCenter defaultCenter] addObserverForName:UITextFieldTextDidChangeNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
        
        JGSStrongSelf
        UITextField *textField = (UITextField *)note.object;
        JGSDemoShowConsoleLog(self, @"%@, %@", textField.text, textField.jg_securityOriginText);
    }];

    [[NSNotificationCenter defaultCenter] addObserverForName:UITextViewTextDidChangeNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
        
        JGSStrongSelf
        UITextView *textView = (UITextView *)note.object;
        JGSDemoShowConsoleLog(self, @"%@", textView.text);
        JGSDemoShowConsoleLog(self, @"%@, %@", textView.text, textView.jg_securityOriginText);
    }];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"小眼睛" style:UIBarButtonItemStylePlain target:self action:@selector(switchTextfieldSecurityEntry:)];
#endif
}

#ifdef JGSSecurityKeyboard_h
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
}

#pragma mark - View
- (void)addViewElements {
    
    static NSInteger accountInputShow = 0;
    
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
            //if (i == 5) {
            //    make.bottom.mas_equalTo(self.scrollView.mas_bottom).inset(32);
            //}
        }];
        
        [fields addObject:field];
    }
    
    _secTextView = [[UITextView alloc] init];
    _secTextView.font = fields.firstObject.font;
    _secTextView.returnKeyType = (accountInputShow % 2 == 1 ? UIReturnKeyDone : UIReturnKeyNext);
    _secTextView.keyboardType = UIKeyboardTypeDefault;
    _secTextView.delegate = self;
    _secTextView.layer.borderColor = [UIColor colorWithWhite:0.9 alpha:1.0].CGColor;
    _secTextView.layer.borderWidth = 1.f / [UIScreen mainScreen].scale;
    _secTextView.layer.cornerRadius = 4.f;
    [self.scrollView addSubview:_secTextView];
    
    //_secTextView.placeholder = @"安全键盘加密输入";
    _secTextView.secureTextEntry = YES;
    JGSSecurityKeyboard *secTextViewInputView = [JGSSecurityKeyboard keyboardWithTextInput:self.secTextView title:@"文本框安全键盘"];
    secTextViewInputView.randomPad = (accountInputShow % 2 == 1);
    secTextViewInputView.randomNumPad = (accountInputShow % 2 == 0);
    secTextViewInputView.enableHighlightedWhenTap = NO;
    _secTextView.inputView = secTextViewInputView;
    
    [_secTextView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(60);
        make.left.right.mas_equalTo(self.scrollView).inset(28);
        make.top.mas_equalTo(self.scrollView).mas_offset(132 + 60 * 6);
        make.bottom.mas_equalTo(self.scrollView.mas_bottom).inset(32);
    }];
    
    // 键盘设置
    self.normalInput = fields[0];
	self.normalInput.keyboardType = UIKeyboardTypeNumbersAndPunctuation;//UIKeyboardTypeDefault + accountInputShow % 12; //12;
    
    // 安全键盘设置
    self.accountInput = fields[1];
    self.accountInput.placeholder = @"安全键盘非加密输入";
    self.accountInput.returnKeyType = (accountInputShow % 2 == 0 ? UIReturnKeyDone : UIReturnKeyNext);
    JGSSecurityKeyboard *accountInputView = [JGSSecurityKeyboard keyboardWithTextField:self.accountInput title:@"自定义安全键盘"];
    accountInputView.randomPad = (accountInputShow % 2 == 0);
    accountInputView.randomNumPad = (accountInputShow % 2 == 1);
    accountInputView.enableHighlightedWhenTap = YES;
    self.accountInput.inputView = accountInputView;
    
    self.secPwdInput = fields[2];
    self.secPwdInput.placeholder = @"安全键盘加密输入";
    self.secPwdInput.secureTextEntry = YES;
    JGSSecurityKeyboard *secPwdInputView = [JGSSecurityKeyboard keyboardWithTextField:self.secPwdInput title:nil];
    secPwdInputView.randomPad = (accountInputShow % 2 == 1);
    secPwdInputView.randomNumPad = (accountInputShow % 2 == 0);
    secPwdInputView.enableHighlightedWhenTap = NO;
    self.secPwdInput.inputView = secPwdInputView;
    if (@available(iOS 12.0, *)) {
        self.secPwdInput.textContentType = UITextContentTypeNewPassword;
    } else if (@available(iOS 11.0, *)) {
        self.secPwdInput.textContentType = UITextContentTypePassword;
    }

    self.secPwdFullInput = fields[3];
    self.secPwdFullInput.placeholder = @"安全键盘加密输入-全角";
    self.secPwdFullInput.secureTextEntry = YES;
    JGSSecurityKeyboard *secPwdFullInputView = [JGSSecurityKeyboard keyboardWithTextField:self.secPwdFullInput title:@"安全键盘加密输入-全角"];
    secPwdFullInputView.aesEncryptInputCharByChar = YES;
    secPwdFullInputView.randomPad = (accountInputShow % 2 == 0);
    secPwdFullInputView.randomNumPad = (accountInputShow % 2 == 1);
    secPwdFullInputView.enableFullAngle = YES;
    self.secPwdFullInput.inputView = secPwdFullInputView;
    if (@available(iOS 12.0, *)) {
        self.secPwdInput.textContentType = UITextContentTypeNewPassword;
    } else if (@available(iOS 11.0, *)) {
        self.secPwdInput.textContentType = UITextContentTypePassword;
    } else if (@available(iOS 10.0, *)) {
        self.secPwdFullInput.textContentType = UITextContentTypeNickname;
    }

    fields[4].placeholder = @"纯数字键盘";
    JGSSecurityKeyboard *inputView4 = [JGSSecurityKeyboard numberKeyboardWithTextField:fields[4] title:@"数字键盘"];
    inputView4.randomNumPad = (accountInputShow % 2 == 0);
    fields[4].inputView = inputView4;
    
    fields[5].placeholder = @"身份证键盘";
    JGSSecurityKeyboard *inputView5 = [JGSSecurityKeyboard idCardKeyboardWithTextField:fields[5] title:@"身份证键盘"];
    inputView5.randomNumPad = (accountInputShow % 2 == 1);
    fields[5].inputView = inputView5;
	
	accountInputShow += 1;
}

#pragma mark - Action
- (void)switchTextfieldSecurityEntry:(id)sender {
    
    //JGSDemoShowConsoleLog(self, @"%@", sender);
    self.accountInput.secureTextEntry = !self.accountInput.secureTextEntry;
    self.secPwdInput.secureTextEntry = !self.secPwdInput.secureTextEntry;
    self.secPwdFullInput.secureTextEntry = !self.secPwdFullInput.secureTextEntry;
    self.secTextView.secureTextEntry = !self.secTextView.secureTextEntry;
}

#pragma mark - UITextFieldDelegate
- (void)textFieldDidBeginEditing:(UITextField *)textField {
    
    if ([textField.inputView isKindOfClass:[JGSSecurityKeyboard class]] && [(JGSSecurityKeyboard *)textField.inputView title].length > 0) {
        [IQKeyboardManager sharedManager].enableAutoToolbar = NO;
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    JGSDemoShowConsoleLog(self, @"%@ -> %@", textField.jg_securityOriginText, textField.text);
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    if ([textField.inputView isKindOfClass:[JGSSecurityKeyboard class]]) {
        JGSDemoShowConsoleLog(self, @"%@", textField.text);
        JGSDemoShowConsoleLog(self, @"%@ -> (%@)", NSStringFromRange(range), string);
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

#pragma mark - UITextViewDelegate
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    return YES;
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
    
    if ([textView.inputView isKindOfClass:[JGSSecurityKeyboard class]] && [(JGSSecurityKeyboard *)textView.inputView title].length > 0) {
        [IQKeyboardManager sharedManager].enableAutoToolbar = NO;
    }
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    
    if ([textView.inputView isKindOfClass:[JGSSecurityKeyboard class]]) {
        JGSDemoShowConsoleLog(self, @"%@", textView.text);
        JGSDemoShowConsoleLog(self, @"%@ -> (%@)", NSStringFromRange(range), text);
    }
    
    return YES;
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView {
    
    if ([textView.inputView isKindOfClass:[JGSSecurityKeyboard class]]) {
        [IQKeyboardManager sharedManager].enableAutoToolbar = YES;
    }
    
    return YES;
}

#pragma mark - End

#endif

@end
