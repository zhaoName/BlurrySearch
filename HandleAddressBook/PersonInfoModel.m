//
//  PersonInfoModel.m
//  BlurrySearch
//
//  Created by zhao on 16/9/21.
//  Copyright © 2016年 zhaoName. All rights reserved.
//

#import "PersonInfoModel.h"

@implementation PersonInfoModel


- (instancetype)init
{
    if([super init])
    {
        self.personPhone = [NSMutableArray array];
    }
    return self;
}

@end
