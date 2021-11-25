//
//  JGSDemoNavigationController.m
//  JGSourceBaseDemo
//
//  Created by 梅继高 on 2021/9/25.
//  Copyright © 2021 MeiJigao. All rights reserved.
//

#import "JGSDemoNavigationController.h"

@interface JGSDemoNavigationController ()

@end

@implementation JGSDemoNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.lineBreakMode = NSLineBreakByTruncatingTail;
    style.lineBreakMode = NSLineBreakByWordWrapping;
    self.navigationBar.titleTextAttributes = @{
        NSFontAttributeName: [UIFont systemFontOfSize:17 weight:UIFontWeightMedium],
#ifdef JGS_Category
        NSForegroundColorAttributeName: JGSColorHex(0xffffff),
#else
        NSForegroundColorAttributeName: [UIColor whiteColor],
#endif
        NSParagraphStyleAttributeName: style};
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
