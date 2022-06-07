//
//  main.m
//  JGSourceFrameworkDemo
//
//  Created by 梅继高 on 2022/4/13.
//  Copyright © 2022 MeiJiGao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

int main(int argc, char * argv[]) {
	NSString * appDelegateClassName;
	@autoreleasepool {
	    // Setup code that might create autoreleased objects goes here.
	    appDelegateClassName = NSStringFromClass([AppDelegate class]);
	}
	return UIApplicationMain(argc, argv, nil, appDelegateClassName);
}
