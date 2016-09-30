//
//  PersonInfoModel.h
//  BlurrySearch
//
//  Created by zhao on 16/9/21.
//  Copyright © 2016年 zhaoName. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PersonInfoModel : NSObject

@property (nonatomic, strong) NSString *personName; /**< 联系人姓名*/
@property (nonatomic, strong) NSString *personNameHeadLetter; /**< 联系人姓名的首字母*/
@property (nonatomic, strong) NSMutableArray *personPhone; /**< 联系人电话 可能有多个*/

@end
