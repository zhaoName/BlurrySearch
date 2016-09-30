//
//  HandleAddressBook.h
//  BlurrySearch
//
//  Created by zhao on 16/9/21.
//  Copyright © 2016年 zhaoName. All rights reserved.
//  授权并获取通讯录信息 这里只获取姓名、手机号

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "PersonInfoModel.h"

typedef void(^AddressBookInfoBlock)(NSMutableArray <PersonInfoModel *> *personInfoArray);

@interface HandleAddressBook : NSObject

/**
 *  手机授权App用户获取通讯录权限
 *  想装逼可以用block传值，不想装逼可以直接用返回值的方式传递通讯录内容
 */
+ (void)addressBookAuthorization:(AddressBookInfoBlock)block;

/**
 *  获取通讯录中信息
 */
+ (void)fetchAddressBookInformation:(AddressBookInfoBlock)block;

@end
