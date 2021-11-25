//
//  JGSDemoTableViewController.h
//  JGSourceBaseDemo
//
//  Created by 梅继高 on 2021/9/15.
//  Copyright © 2021 MeiJigao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JGSDemoTableData.h"

NS_ASSUME_NONNULL_BEGIN

@interface JGSDemoTableViewController : UITableViewController

- (instancetype)initWithCoder:(NSCoder *)aDecoder NS_UNAVAILABLE;
//- (instancetype)initWithStyle:(UITableViewStyle)style NS_UNAVAILABLE;
- (instancetype)initWithNibName:(nullable NSString *)nibNameOrNil bundle:(nullable NSBundle *)nibBundleOrNil NS_UNAVAILABLE;

@property (nonatomic, copy, readonly) NSArray<JGSDemoTableSectionData *> *tableSectionData;

@end

NS_ASSUME_NONNULL_END
