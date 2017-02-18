//
//  HandleAddressBook.m
//  BlurrySearch
//
//  Created by zhao on 16/9/21.
//  Copyright © 2016年 zhaoName. All rights reserved.
//  授权并获取通讯录信息 这里只获取姓名、手机号

#import "HandleAddressBook.h"
#ifdef __IPHONE_9_0
#import <Contacts/Contacts.h>
#endif
#import <AddressBook/AddressBook.h>
#import "PinYinForObjc.h"


#define iOS9_LATER [[UIDevice currentDevice].systemVersion floatValue] >= 9.0 ? YES : NO

@implementation HandleAddressBook

#pragma mark -- 授权
//授权
+ (void)addressBookAuthorization:(AddressBookInfoBlock)block
{
    if(iOS9_LATER) // 在iOS9之后获取通讯录用CNContactStore
    {
        // 已经授权了 直接返回
        if([CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts] == CNAuthorizationStatusAuthorized)
        {
            [self fetchAddressBookInformation:block];
            return;
        }
        
        CNContactStore *contactStore = [[CNContactStore alloc] init];
        [contactStore requestAccessForEntityType:CNEntityTypeContacts completionHandler:^(BOOL granted, NSError * _Nullable error) {
            
            if(granted){
                [self fetchAddressBookInformation:block];
                NSLog(@"授权成功");
            }
            else{
                [self showAlert];
                NSLog(@"授权失败");
            }
        }];
    }
    else // 在iOS9之前 用ABAddressBookRef获取通讯录
    {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        ABAuthorizationStatus status = ABAddressBookGetAuthorizationStatus();
        if(status == kABAuthorizationStatusAuthorized) //已经授权了 直接返回
        {
            [self fetchAddressBookInformation:block];
            return;
        }
        
        ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, NULL);
        ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {
            if(granted){
                [self fetchAddressBookInformation:block];
                NSLog(@"授权成功");
            }
            else{
                [self showAlert];
                NSLog(@"授权失败");
            }
        });
#pragma clang diagnostic pop
    }
}


#pragma mark -- 获取联系人信息
/**
 *  获取通讯录中信息
 */
+ (void)fetchAddressBookInformation:(AddressBookInfoBlock)block
{
    if(iOS9_LATER){
        [self fetchAddressBookInformationWhenSystemVersionIsiOS9_later:block];
    }
    else{
        [self fetchAddressBookInformationWhenSystemVersionIsiOS9_before:block];
    }
}

/**
 *  iOS9之后获取通讯录信息的方法
 */
+ (void)fetchAddressBookInformationWhenSystemVersionIsiOS9_later:(AddressBookInfoBlock)block
{
    NSMutableArray *array = [[NSMutableArray alloc] init];
    
    CNContactStore *contactStore = [[CNContactStore alloc] init];
    // 由keys决定获取联系人的那些信息：姓名 手机号
    NSArray *keys = @[CNContactGivenNameKey, CNContactFamilyNameKey, CNContactPhoneNumbersKey];
    CNContactFetchRequest *request = [[CNContactFetchRequest alloc] initWithKeysToFetch:keys];
    
    NSError *error = nil;
    [contactStore enumerateContactsWithFetchRequest:request error:&error usingBlock:^(CNContact * _Nonnull contact, BOOL * _Nonnull stop) {
        
        PersonInfoModel *model = [[PersonInfoModel alloc] init];
        
        // 联系人姓名
        NSString *name = [NSString stringWithFormat:@"%@%@", contact.familyName ? contact.familyName : @"", contact.givenName ? contact.givenName : @""];
        model.personName = name ? name :@"你叫啥呢";
        
        // 联系人每个拼音首字母
        model.personNameHeadLetter = [[PinYinForObjc chineseConvertToPinYinHead:model.personName] uppercaseString];
        
        // 联系人手机号
        NSArray *phones = contact.phoneNumbers;
        for(CNLabeledValue *labeledValue in phones)
        {
            CNPhoneNumber *phone = labeledValue.value;
            [model.personPhone addObject:(phone.stringValue ? phone.stringValue : @"我也不知道")];
        }
        
        [array addObject:model];
    }];
    
    // 把获取到的联系人信息传过去
    block(array);
}

/**
 *  iOS9之前获取通讯录信息的方法
 */
+ (void)fetchAddressBookInformationWhenSystemVersionIsiOS9_before:(AddressBookInfoBlock)block
{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    
    NSMutableArray *array = [[NSMutableArray alloc] init];
    // 创建通讯录对象
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, NULL);
    
    // 从通讯录中将所有人的信息拷贝出来
    CFArrayRef allPersonInfoArray = ABAddressBookCopyArrayOfAllPeople(addressBook);
    
    // 获取联系人的个数
    CFIndex personCount = CFArrayGetCount(allPersonInfoArray);
    
    for(int i=0; i<personCount; i++)
    {
        PersonInfoModel *model = [[PersonInfoModel alloc] init];
        // 获取其中每个联系人的信息
        ABRecordRef person = CFArrayGetValueAtIndex(allPersonInfoArray, i);
        
        // 联系人姓名
        NSString *lastName = (__bridge_transfer NSString *)ABRecordCopyValue(person, kABPersonLastNameProperty);
        NSString *firstName = (__bridge_transfer NSString *)ABRecordCopyValue(person, kABPersonFirstNameProperty);
        NSString *name = [NSString stringWithFormat:@"%@%@", lastName?lastName:@"", firstName?firstName:@""];
        model.personName = name ? name : @"你叫啥呢";
        
        // 联系人每个拼音首字母
        model.personNameHeadLetter = [[PinYinForObjc chineseConvertToPinYinHead:model.personName] uppercaseString];
        
        // 联系人电话
        ABMultiValueRef phones = ABRecordCopyValue(person, kABPersonPhoneProperty);
        CFIndex phoneCout = ABMultiValueGetCount(phones);
        for(int j=0; j<phoneCout; j++)
        {
            NSString *phone = (__bridge_transfer NSString *)ABMultiValueCopyValueAtIndex(phones, i);
            [model.personPhone addObject:phone ? phone : @"我也不知道"];
        }
        CFRelease(phones);
        
        [array addObject:model];
    }
    // 把获取到的联系人信息传过去
    block(array);
    
    CFRelease(allPersonInfoArray);
    CFRelease(addressBook);
#pragma clang diagnostic pop
}

/**
 *  提示
 */
+ (void)showAlert
{
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"提示" message:@"请在iPhone的“设置-隐私-通讯录”选项中，允许BlurrySearch访问您的通讯录" preferredStyle:UIAlertControllerStyleAlert];
    
    [alertVC addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil]];
    
    [[self getCurrentViewController] presentViewController:alertVC animated:YES completion:nil];
    return;
}

/**
 * 获取当前呈现的ViewController
 */
+ (UIViewController *)getCurrentViewController
{
    UIViewController *result = nil;
    
    UIWindow * window = [[UIApplication sharedApplication] keyWindow];
    if (window.windowLevel != UIWindowLevelNormal)
    {
        NSArray *windows = [[UIApplication sharedApplication] windows];
        for(UIWindow * tmpWin in windows)
        {
            if (tmpWin.windowLevel == UIWindowLevelNormal)
            {
                window = tmpWin;
                break;
            }
        }
    }
    
    UIView *frontView = [[window subviews] objectAtIndex:0];
    id nextResponder = [frontView nextResponder];
    
    if ([nextResponder isKindOfClass:[UIViewController class]])
        result = nextResponder;
    else
        result = window.rootViewController;
    
    return result;
}

@end
