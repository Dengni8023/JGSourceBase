//
//  JGSEncryptionDemoViewController.m
//  JGSourceBaseDemo
//
//  Created by 梅继高 on 2021/9/15.
//  Copyright © 2021 MeiJigao. All rights reserved.
//

#import "JGSEncryptionDemoViewController.h"

#ifdef JGS_Encryption
@interface JGSEncryptionDemoViewController ()

@end

@implementation JGSEncryptionDemoViewController

- (NSArray<JGSDemoTableSectionData *> *)tableSectionData {
    
    return @[
        JGSDemoTableSectionMake(nil,
                                @[
                                    JGSDemoTableRowMakeSelector(@"AES加解密字符串", @selector(aesDemo:)),
                                ]),
    ];
}

#pragma mark - Controller
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"EncryptionDemo";
}

#pragma mark - Action
- (void)aesDemo:(NSIndexPath *)indexPath {
    
    // 加解密可以和在线工具进行对比验证：https://www.qtool.net/aes
    NSString *aes128Key = @"1234567890abcdef";
    NSString *aes256Key = @"1234567890abcdef1234567890ABCDEF";
    
    NSString *origin = @"- (void)aesDemo:(NSIndexPath *)indexPath {";
    NSString *encrypt = [origin jg_AES128EncryptWithKey:aes128Key iv:nil];
    JGSLog(@"128 encrypt: %@", encrypt);
    JGSLog(@"128 decrypt: %@", [encrypt jg_AES128DecryptWithKey:aes128Key iv:nil]);

    encrypt = [origin jg_AES128EncryptWithKey:aes128Key iv:aes128Key];
    JGSLog(@"128 encrypt: %@", encrypt);
    JGSLog(@"128 decrypt: %@", [encrypt jg_AES128DecryptWithKey:aes128Key iv:aes128Key]);

    encrypt = [origin jg_AES256EncryptWithKey:aes256Key iv:nil];
    JGSLog(@"256 encrypt: %@", encrypt);
    JGSLog(@"256 decrypt: %@", [encrypt jg_AES256DecryptWithKey:aes256Key iv:nil]);
    
    encrypt = [origin jg_AES256EncryptWithKey:aes256Key iv:@"12345"];
    JGSLog(@"256 encrypt: %@", encrypt);
    JGSLog(@"256 decrypt: %@", [encrypt jg_AES256DecryptWithKey:aes256Key iv:@"12345"]);
    
    encrypt = [origin jg_AES256EncryptWithKey:aes256Key iv:aes256Key];
    JGSLog(@"256 encrypt: %@", encrypt);
    JGSLog(@"256 decrypt: %@", [encrypt jg_AES256DecryptWithKey:aes256Key iv:aes256Key]);
}

@end

#endif
