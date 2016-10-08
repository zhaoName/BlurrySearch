//
//  AddModleDataViewController.h
//  BlurrySearch
//
//  Created by 赵松波 on 16/10/7.
//  Copyright © 2016年 zhaoName. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PersonInfoModel.h"

@protocol AddModleDataViewControllerDelegate <NSObject>

- (void)addModelDataDelegate:(PersonInfoModel *)model;

@end

@interface AddModleDataViewController : UIViewController

@property (nonatomic, weak) id<AddModleDataViewControllerDelegate> delegate;

@end
