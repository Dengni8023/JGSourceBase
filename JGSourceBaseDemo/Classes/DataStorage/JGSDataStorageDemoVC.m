//
//  JGSDataStorageDemoVC.m
//  JGSourceBaseDemo
//
//  Created by 梅继高 on 2022/2/16.
//  Copyright © 2022 MeiJiGao. All rights reserved.
//

#import "JGSDataStorageDemoVC.h"

#ifdef JGS_DataStorage
@interface JGSDataStorageDemoVC ()

@end

@implementation JGSDataStorageDemoVC

- (NSArray<JGSDemoTableSectionData *> *)tableSectionData {
    
    return @[
        JGSDemoTableSectionMake(nil,
                                @[
                                    
                                ]),
    ];
}

#pragma mark - Controller
- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    self.title = @"DataStorage";
    self.showTextView = YES;
}

#pragma mark - Action

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
