//
//  main.m
//  JGCommandLineDemo
//
//  Created by 梅继高 on 2022/4/13.
//  Copyright © 2022 MeiJiGao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JGSCommandLineTool.h"

int main(int argc, const char * argv[]) {
	@autoreleasepool {
        
        NSLog(@"Sort plist file >>>>");
        [JGSCommandLineTool sortPlistFiles];
        NSLog(@"");
        
        NSLog(@"Sort json file >>>>");
        [JGSCommandLineTool sortJSONFiles];
        NSLog(@"");
        
		NSLog(@"Sort and aes encrypt device list data >>>>");
        [JGSCommandLineTool sortAndAESEncryptDeviceListData];
        NSLog(@"");
        
        NSLog(@"Sort and base64 encrypt latest global config >>>>");
        [JGSCommandLineTool sortAndBase64EncryptGlobalConfiguration];
        [JGSCommandLineTool globalConfigurationBase64Decrypt];
        NSLog(@"");
	}
	return 0;
}
