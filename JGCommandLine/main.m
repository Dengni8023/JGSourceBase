//
//  main.m
//  JGCommandLine
//
//  Created by 梅继高 on 2022/4/13.
//  Copyright © 2022 MeiJiGao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JGSCommandLine.h"

int main(int argc, const char * argv[]) {
	@autoreleasepool {
        
        NSLog(@"Sort plist file >>>>");
        [JGSCommandLine sortPlistFiles];
        NSLog(@"");
        
        NSLog(@"Sort json file >>>>");
        [JGSCommandLine sortJSONFiles];
        NSLog(@"");
        
		NSLog(@"Sort and aes encrypt device list data >>>>");
        [JGSCommandLine sortAndAESEncryptDeviceListData];
        NSLog(@"");
	}
	return 0;
}
