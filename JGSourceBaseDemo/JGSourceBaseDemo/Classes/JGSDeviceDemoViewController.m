//
//  JGSDeviceDemoViewController.m
//  JGSourceBaseDemo
//
//  Created by 梅继高 on 2021/9/15.
//  Copyright © 2021 MeiJigao. All rights reserved.
//

#import "JGSDeviceDemoViewController.h"

#ifdef JGS_Device
@interface JGSDeviceDemoViewController ()

@end

@implementation JGSDeviceDemoViewController

- (NSArray<JGSDemoTableSectionData *> *)tableSectionData {
    
    return @[
        JGSDemoTableSectionMake(@" Device",
                                @[
                                ]),
    ];
}

#pragma mark - Controller
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Device Demo";
}

#pragma mark - Action

@end

#endif
