//
//  AddDataViewController.h
//  BlurrySearch
//
//  Created by zhao on 16/9/30.
//  Copyright © 2016年 zhaoName. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AddDataViewController : UIViewController

@property (nonatomic, strong) void(^AddStringDataBlock)(NSString *);

@end
