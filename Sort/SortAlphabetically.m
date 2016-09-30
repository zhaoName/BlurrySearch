//
//  SortAlphabetically.m
//  BlurrySearch
//
//  Created by zhao on 16/9/23.
//  Copyright © 2016年 zhaoName. All rights reserved.
//  将传递过来的内容排序、模糊查询

#import "SortAlphabetically.h"
#import <objc/runtime.h>

@interface SortAlphabetically ()

@property (nonatomic, strong) NSMutableDictionary *sortDictionary;

@end

@implementation SortAlphabetically

+ (SortAlphabetically *)shareSortAlphabetically
{
    static SortAlphabetically *sort = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        sort = [[SortAlphabetically alloc] init];
    });
    return sort;
}
#pragma mark -- 排序、分类
//排序
- (NSMutableDictionary *)sortAlphabeticallyWithDataArray:(NSMutableArray *)dataArray propertyName:(NSString *)propertyName
{
    NSMutableArray *tempArr = [[NSMutableArray alloc] init];
    //区分字符串数据 和模型数组
    NSDictionary *dict = [self distinguishDataBetweenStringDataAndModelData:dataArray propertyName:propertyName];
    
    if(dict.count <= 0) return nil;
    //按字母排序(重新赋值)
    tempArr = [self sortWithHeadLetterFromDataArray:dict.allValues.firstObject];
    //按首字母分类
    [self classifyDataWithCapitalLatter:tempArr type:dict.allKeys.firstObject];
    
    return self.sortDictionary;
}

#pragma mark -- 模糊查询

//模糊查询
- (NSMutableArray *)blurrySearchFromDataArray:(NSMutableArray *)dataArray propertyName:(NSString *)propertyName searchString:(NSString *)searchString
{
    //区分字符串数据和模型数组
    NSDictionary *dict = [self distinguishDataBetweenStringDataAndModelData:dataArray propertyName:propertyName];
    if(dict.count <= 0) return nil;
    //查询结果
    return [self handleSearchResult:dict.allValues.firstObject searchString:searchString type:dict.allKeys.firstObject];
}

//获取所有的value
- (NSMutableArray *)fetchAllValuesFromSortDict:(NSMutableDictionary *)sortDict
{
    NSMutableArray *values = [[NSMutableArray alloc] init];
    //按字母顺序 取所有的value
    NSMutableArray *keys = [self sortAllIndexFromDictKey:sortDict.allKeys];
    for(NSString *key in keys)
    {
        [values addObjectsFromArray:sortDict[key]];
    }
    return values;
}

#pragma mark -- 索引

//获取所有的key 也就是索引 此方法通用
- (NSMutableArray *)sortAllIndexFromDictKey:(NSArray *)keys
{
    NSMutableArray *keyArr = [keys mutableCopy];
    //排序
    NSSortDescriptor *descriptor = [NSSortDescriptor sortDescriptorWithKey:nil ascending:YES];
    [keyArr sortUsingDescriptors:@[descriptor]];
    
    //将@“#”放在最后
    for(NSString *string in keys)
    {
        if([string isEqualToString:@"#"])
        {
            [keyArr removeObject:@"#"];
            [keyArr addObject:@"#"];
            break;
        }
    }
    return keyArr;
}

//获取所有的索引  此方法只适合非模型数据
- (NSMutableArray *)fetchFirstLetterFromArray:(NSMutableArray *)array
{
    NSMutableSet *letterSet =[[NSMutableSet alloc] init];
    
    for (NSString *string in array)
    {
        NSString *firstLetter = [self chineseToPinYin:string];
        char letterChar = [firstLetter characterAtIndex:0];
        
        if (letterChar >= 'A' && letterChar <= 'Z') {
            [letterSet addObject:[NSString stringWithFormat:@"%c", letterChar]];
        }
        else {
            [letterSet addObject:@"#"];
        }
    }
    //返回去重、排序后所有的首字母
    NSMutableArray *arr = [NSMutableArray arrayWithArray:[[letterSet objectEnumerator].allObjects sortedArrayUsingSelector:@selector(compare:)]];
    //若包含@“#”则将其放在最后
    if([arr containsObject:@"#"])
    {
        [arr removeObject:@"#"];
        [arr addObject:@"#"];
    }
    return arr;
}

#pragma mark -- 添加数据

- (NSMutableDictionary *)addDataToSortDictionary:(id)data
{
    if([data isKindOfClass:[NSString class]])
    {
        NSString *first = [[self chineseToPinYin:data] substringToIndex:1];
        if([self.sortDictionary.allKeys containsObject:first])
        {
            NSMutableArray *arr = [self.sortDictionary valueForKey:first];
            [arr addObject:data];
            //重新排序
            NSSortDescriptor *descriptor = [NSSortDescriptor sortDescriptorWithKey:nil ascending:YES];
            [arr sortUsingDescriptors:@[descriptor]];
            [self.sortDictionary setObject:arr forKey:first];
        }
        else
        {
            [self.sortDictionary setObject:@[data] forKey:[self isEnglishLetter:first] ? first : @"#"];
        }
        return self.sortDictionary;
    }
    else
    {
        return nil;
    }
}

#pragma mark -- 私有方法

/**
 *  区分字符串数据和模型数组，并取出想要需要排序的属性值
 *
 *  @param dataArray    字符串数据或模型数组
 *  @param propertyName 需要排序的属性名
 *
 *  @return key是区分字符串数据和模型数组的标志, value是需要排序的属性值
 */
- (NSDictionary *)distinguishDataBetweenStringDataAndModelData:(NSMutableArray *)dataArray propertyName:(NSString *)propertyName
{
    if (dataArray.count <= 0) return nil;
    
    NSMutableArray *tempArr = [NSMutableArray array];
    NSString *type = nil;
    
    if ([dataArray.firstObject isKindOfClass:[NSString class]]) //字符串
    {
        type = @"string";
        for(NSString *string in dataArray)
        {
            SortAlphabetically *sort = [[SortAlphabetically alloc] init];
            sort.initialStr = string;
            [tempArr addObject:sort];
        }
    }
    else //模型
    {
        type = @"model";
        tempArr = [self handleModelFromDataArray:dataArray propertyName:propertyName];
    }
    return @{type : tempArr};
}

/**
 *  处理模型数据
 */
- (NSMutableArray *)handleModelFromDataArray:(NSMutableArray *)dataArray propertyName:(NSString *)propertyName
{
    NSMutableArray *tempArr = [[NSMutableArray alloc] init];
    unsigned int propertyCount;
    objc_property_t *properties = class_copyPropertyList([dataArray.firstObject class], &propertyCount);
    
    for (NSObject *object in dataArray) //遍历模型
    {
        SortAlphabetically *sort = [[SortAlphabetically alloc] init];
        sort.model = object;
        
        for (int i=0; i<propertyCount; i++) //遍历模型中的属性名
        {
            objc_property_t property = properties[i];
            //获取属性名
            NSString *proName = [NSString stringWithUTF8String:property_getName(property)];
            
            if ([proName isEqualToString:propertyName])
            {
                id propertyValue = [object valueForKey:proName]; //获取属性名对应的属性值
                sort.initialStr = propertyValue;
                [tempArr addObject:sort];
                break;
            }
            if(i == propertyCount-1)
            {
                NSLog(@"数据源model中没有你指定的属性名");
            }
        }
    }
    return tempArr;
}

/**
 *  将数据转化为拼音后(英文、符号、数字不变)，按字母排序;
 *
 *  @param dataArray 数据 若为模型则为要排序属性值
 */
- (NSMutableArray *)sortWithHeadLetterFromDataArray:(NSMutableArray *)dataArray
{
    NSMutableArray *sortArray = [[NSMutableArray alloc] init];
    NSMutableArray *tempArr = [[NSMutableArray alloc] init];
    
    for (SortAlphabetically *sort in dataArray)
    {
        NSString *hanYuPinYin = [self chineseToPinYin:sort.initialStr]; //汉语转拼音
        sort.hanYuPinYin = hanYuPinYin;
        if([self isEnglishLetter:[hanYuPinYin substringToIndex:1]])
        {
            sort.capitalLetter = [hanYuPinYin substringToIndex:1];
        }
        else //不是字母
        {
            sort.capitalLetter = @"#";
        }
    }
    //按hanYuPinYin属性值排序
    NSSortDescriptor *descriptor = [NSSortDescriptor sortDescriptorWithKey:@"hanYuPinYin" ascending:YES];
    [dataArray sortUsingDescriptors:@[descriptor]];
    
    //将首字母不是A-Z的数据 统一放在最后，否则上面分类会出现问题
    sortArray = [dataArray mutableCopy];
    for(SortAlphabetically *sort in dataArray)
    {
        if(![self isEnglishLetter:[sort.hanYuPinYin substringToIndex:1]])
        {
            [sortArray removeObject:sort];
            [tempArr addObject:sort];
        }
    }
    [tempArr sortUsingDescriptors:@[descriptor]];
    [sortArray addObjectsFromArray:tempArr];
    return sortArray;
}

/**
 *  将按字母排序后的数据 按首字母分类(分类中的数据也是排序好的)
 *
 *  @param tempArr 排序后的数据
 *  @param type    区别字符串数据和模型数组
 */
- (void)classifyDataWithCapitalLatter:(NSMutableArray *)tempArr type:(NSString *)type
{
    [self.sortDictionary removeAllObjects];
    //将按字母排序后的数据 按首字母分类
    NSString *capital = nil;
    NSMutableArray *sortArr = [[NSMutableArray alloc] init];
    for(SortAlphabetically *sort in tempArr)
    {
        //首字母相同 加入同一个数组
        if([capital isEqualToString:sort.capitalLetter])
        {
            if([type isEqualToString:@"string"])
            {
                [sortArr addObject:sort.initialStr];
            }
            else if ([type isEqualToString:@"model"])
            {
                [sortArr addObject:sort.model];
            }
        }
        else //首字母不同 重新初始化一个数组
        {
            sortArr = [NSMutableArray array];
            capital = [self isEnglishLetter:[sort.hanYuPinYin substringToIndex:1]] ? [sort.hanYuPinYin substringToIndex:1] : @"#";
            
            if([type isEqualToString:@"string"])
            {
                [sortArr addObject:sort.initialStr];
            }
            else if ([type isEqualToString:@"model"])
            {
                [sortArr addObject:sort.model];
            }
            [self.sortDictionary setObject:sortArr forKey:capital];
        }
    }
}

/**
 *  中文转化为拼音 (英文、数字、字符不变)
 */
- (NSString *)chineseToPinYin:(NSString *)chinese
{
    NSMutableString *english = [chinese mutableCopy];
    //转化为带声调的拼音
    CFStringTransform((__bridge CFMutableStringRef)english, NULL, kCFStringTransformMandarinLatin, NO);
    //转化为不带声调的拼音
    CFStringTransform((__bridge CFMutableStringRef)english, NULL, kCFStringTransformStripCombiningMarks, NO);
    
    //去除两端空格和回车
    [english stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    //去除中间的空格
    english = (NSMutableString *)[english stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    return [english uppercaseString];
}

/**
 *  正则表达式判断数据中是否全为英文字符
 */
- (BOOL)isEnglishLetter:(NSString *)string
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", @"[A-Za-z]+"];
    return [predicate evaluateWithObject:string];
}

/**
 *  判断是否包含汉字
 */
- (BOOL)isIncludeChineseInString:(NSString*)string
{
    for (int i=0; i<string.length; i++)
    {
        unichar ch = [string characterAtIndex:i];
        if (0x4e00 < ch  && ch < 0x9fff) return true;
    }
    return false;
}

/**
 *  模糊查询 可以按拼音、中文、字符查询
 *
 *  @param array        数据源
 *  @param searchString 查询条件
 *  @param type         区分字符串数组或模型数组的标志
 *
 *  @return 符合条件的数据
 */
- (NSMutableArray *)handleSearchResult:(NSMutableArray *)array searchString:(NSString *)searchString type:(NSString *)type
{
    NSMutableArray *searchArray = [[NSMutableArray alloc] init];
    NSString *tempString = nil;
    
    for(SortAlphabetically *sort in array)
    {
        //查找的字符串中不包含中文
        if(searchString.length > 0 && ![self isIncludeChineseInString:searchString])
        {
            tempString = [self chineseToPinYin:sort.initialStr]; //转化为拼音
            //判断转化后的拼音是否包含 搜索框中输入的字符
            NSRange range = [tempString rangeOfString:searchString options:NSCaseInsensitiveSearch];
            if(range.length > 0)
            {
                [searchArray addObject:[type isEqualToString:@"string"] ? sort.initialStr : sort.model];
            }
        }
        //查找的字符串中包含中文
        else if(searchString.length > 0 && [self isIncludeChineseInString:searchString])
        {
            NSRange range = [sort.initialStr rangeOfString:searchString options:NSCaseInsensitiveSearch];
            if(range.length > 0)
            {
                [searchArray addObject:[type isEqualToString:@"string"] ? sort.initialStr : sort.model];
            }
        }
    }
    return searchArray;
}

#pragma mark -- getter

- (NSMutableDictionary *)sortDictionary
{
    if(!_sortDictionary)
    {
        _sortDictionary = [[NSMutableDictionary alloc] init];
    }
    return _sortDictionary;
}

@end
