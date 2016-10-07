//
//  AddModleDataViewController.h
//  BlurrySearch
//
//  Created by 赵松波 on 16/10/7.
//  Copyright © 2016年 zhaoName. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PersonInfoModel.h"

@interface AddModleDataViewController : UIViewController

@property (nonatomic, strong) void(^AddModelDataBlock)(NSString *);

@end
