//
//  JGSEncryptionDemoViewController.m
//  JGSourceBaseDemo
//
//  Created by 梅继高 on 2022/2/16.
//  Copyright © 2022 MeiJiGao. All rights reserved.
//

#import "JGSEncryptionDemoViewController.h"

#ifdef JGS_Encryption
@interface JGSEncryptionDemoViewController ()

@end

@implementation JGSEncryptionDemoViewController

- (NSArray<JGSDemoTableSectionData *> *)tableSectionData {
    
    return @[
        JGSDemoTableSectionMake(@" UserDefaults",
                                @[
                                    
                                ]),
    ];
}

#pragma mark - Controller
- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    self.title = @"Encryption";
    self.showTextView = YES;
}

#pragma mark - Action
- (void)showAESEncryption:(NSIndexPath *)indexPath {

#ifdef JGS_Encryption
    // 加解密可以和在线工具进行对比验证：https://www.qtool.net/aes
    NSString *aes128Key = @"1234567890abcdef";
    NSString *aes256Key = @"1234567890abcdef1234567890ABCDEF";

    NSString *origin = @"origin string: - (void)aesDemo:(NSIndexPath *)indexPath {";
    NSString *encrypt = [origin jg_AES128EncryptWithKey:aes128Key iv:nil];
    JGSDemoShowConsoleLog(@"128 encrypt: %@", encrypt);
    JGSDemoShowConsoleLog(@"128 decrypt: %@", [encrypt jg_AES128DecryptWithKey:aes128Key iv:nil]);

    encrypt = [origin jg_AES128EncryptWithKey:aes128Key iv:aes128Key];
    JGSDemoShowConsoleLog(@"128 encrypt: %@", encrypt);
    JGSDemoShowConsoleLog(@"128 decrypt: %@", [encrypt jg_AES128DecryptWithKey:aes128Key iv:aes128Key]);

    encrypt = [origin jg_AES256EncryptWithKey:aes256Key iv:nil];
    JGSDemoShowConsoleLog(@"256 encrypt: %@", encrypt);
    JGSDemoShowConsoleLog(@"256 decrypt: %@", [encrypt jg_AES256DecryptWithKey:aes256Key iv:nil]);

    encrypt = [origin jg_AES256EncryptWithKey:aes256Key iv:@"12345"];
    JGSDemoShowConsoleLog(@"256 encrypt: %@", encrypt);
    JGSDemoShowConsoleLog(@"256 decrypt: %@", [encrypt jg_AES256DecryptWithKey:aes256Key iv:@"12345"]);

    encrypt = [origin jg_AES256EncryptWithKey:aes256Key iv:aes256Key];
    JGSDemoShowConsoleLog(@"256 encrypt: %@", encrypt);
    JGSDemoShowConsoleLog(@"256 decrypt: %@", [encrypt jg_AES256DecryptWithKey:aes256Key iv:aes256Key]);
#endif
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
#endif
