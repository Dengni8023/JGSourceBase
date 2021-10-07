//
//  JGSDataStorageDemoViewController.m
//  JGSourceBaseDemo
//
//  Created by 梅继高 on 2021/9/15.
//  Copyright © 2021 MeiJigao. All rights reserved.
//

#import "JGSDataStorageDemoViewController.h"

#ifdef JGS_DataStorage
@interface JGSDataStorageDemoViewController ()

@end

@implementation JGSDataStorageDemoViewController

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
    
    self.title = @"Data Storage";
}

#pragma mark - Action

@end

#endif
