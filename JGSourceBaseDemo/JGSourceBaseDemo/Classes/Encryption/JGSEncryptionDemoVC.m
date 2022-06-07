//
//  JGSEncryptionDemoVC.m
//  JGSourceBaseDemo
//
//  Created by 梅继高 on 2022/2/16.
//  Copyright © 2022 MeiJiGao. All rights reserved.
//

#import "JGSEncryptionDemoVC.h"

@interface JGSEncryptionDemoVC ()

@end

@implementation JGSEncryptionDemoVC

#pragma mark - Controller
- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    self.title = @"Encryption Encryption Encryption Encryption";
}

#ifdef JGSEncryption_h
#pragma mark - TableRows
- (NSArray<JGSDemoTableSectionData *> *)tableSectionData {
	
	return @[
		JGSDemoTableSectionMake(@" Base64", @[
			JGSDemoTableRowMake(@" Base64 Encryption", self, @selector(showBase64Encryption:)),
			JGSDemoTableRowMake(@" Base64 Decryption", self, @selector(showBase64Encryption:)),
		]),
		JGSDemoTableSectionMake(@" AES", @[
			JGSDemoTableRowMake(@" AES-128", self, @selector(showAESEncryption:)),
			JGSDemoTableRowMake(@" AES-256", self, @selector(showAESEncryption:)),
		]),
		JGSDemoTableSectionMake(@" RSA", @[
			JGSDemoTableRowMake(@" RSA-1", self, @selector(showRSAEncryption:)),
			JGSDemoTableRowMake(@" RSA-2", self, @selector(showRSAEncryption:)),
		]),
	];
}

#pragma mark - Action
- (void)showBase64Encryption:(NSIndexPath *)indexPath {
	
	switch (indexPath.row) {
		case 0: {
			
			NSString *origin = @"Base64 Encryption origin string";
			NSString *encrypt = [origin jg_base64EncodeString];
			JGSDemoShowConsoleLog(self, @"Base64 encrypt: <%@> >>> <%@>", origin, encrypt);
		}
			break;
			
		default: {
			
			NSString *origin = @"QmFzZTY0IEVuY3J5cHRpb24gb3JpZ2luIHN0cmluZw==";
			NSString *decrypt = [origin jg_base64DecodeString];
			JGSDemoShowConsoleLog(self, @"Base64 encrypt: <%@> >>> <%@>", origin, decrypt);
		}
			break;
	}
}

- (void)showAESEncryption:(NSIndexPath *)indexPath {
	
    // 加解密可以和在线工具进行对比验证：https://www.qtool.net/aes
    NSString *aes128Key = @"1234567890abcdef";
    NSString *aes256Key = @"1234567890abcdef1234567890ABCDEF";
	switch (indexPath.row) {
		case 0: {
			
			NSString *origin = @"AES-128 origin string";
			NSString *encrypt = [origin jg_AES128EncryptWithKey:aes128Key iv:nil];
			JGSDemoShowConsoleLog(self, @"128 encrypt: %@", encrypt);
			JGSDemoShowConsoleLog(self, @"128 decrypt: %@", [encrypt jg_AES128DecryptWithKey:aes128Key iv:nil]);
			
			encrypt = [origin jg_AES128EncryptWithKey:aes128Key iv:aes128Key];
			JGSDemoShowConsoleLog(self, @"128 encrypt with iv: %@", encrypt);
			JGSDemoShowConsoleLog(self, @"128 decrypt: %@", [encrypt jg_AES128DecryptWithKey:aes128Key iv:aes128Key]);
		}
			break;
			
		default: {
			
			NSString *origin = @"AES-256 origin string";
			NSString *encrypt = [origin jg_AES256EncryptWithKey:aes256Key iv:nil];
			JGSDemoShowConsoleLog(self, @"256 encrypt: %@", encrypt);
			JGSDemoShowConsoleLog(self, @"256 decrypt: %@", [encrypt jg_AES256DecryptWithKey:aes256Key iv:nil]);
			
			encrypt = [origin jg_AES256EncryptWithKey:aes256Key iv:@"12345"];
			JGSDemoShowConsoleLog(self, @"256 encrypt with short iv: %@", encrypt);
			JGSDemoShowConsoleLog(self, @"256 decrypt: %@", [encrypt jg_AES256DecryptWithKey:aes256Key iv:@"12345"]);
			
			encrypt = [origin jg_AES256EncryptWithKey:aes256Key iv:aes256Key];
			JGSDemoShowConsoleLog(self, @"256 encrypt with iv: %@", encrypt);
			JGSDemoShowConsoleLog(self, @"256 decrypt: %@", [encrypt jg_AES256DecryptWithKey:aes256Key iv:aes256Key]);
		}
			break;
	}
}

- (void)showRSAEncryption:(NSIndexPath *)indexPath {
	JGSDemoShowConsoleLog(self, @"Unimplemented function");
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#endif

@end
