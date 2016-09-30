//
//  AddressBookTableViewController.m
//  BlurrySearch
//
//  Created by zhao on 16/9/20.
//  Copyright © 2016年 zhaoName. All rights reserved.
//

#import "AddressBookController.h"
#import "HandleAddressBook.h"
#import "PersonInfoModel.h"
#import "SortAlphabetically.h"

#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height

@interface AddressBookController ()<UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataSource; /**< 数据源*/
@property (nonatomic, strong) NSMutableArray *indexArray; /**< 索引数据源*/
@property (nonatomic, strong) NSMutableDictionary *sortDict; /**< 排序后的数据源*/
@property (nonatomic, strong) NSMutableArray *searchArray; /**< 搜索结果*/

@property (nonatomic, strong) UISearchController *searchController;
@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic, strong) UIView *statueView;

@end

@implementation AddressBookController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"通讯录";
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self.view addSubview:self.tableView];
    [self.view addSubview:self.searchBar];
    [self initDatas];
}

- (void)initDatas
{
    [HandleAddressBook addressBookAuthorization:^(NSMutableArray<PersonInfoModel *> *personInfoArray) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.dataSource = personInfoArray;
            //key是索引 value是数据源
            self.sortDict = [SortAlphabetically sortAlphabeticallyWithDataArray:self.dataSource propertyName:@"personName"];
            //字典是无序的 不能直接取key当索引
            self.indexArray = [SortAlphabetically sortAllIndexFromDictKey:self.sortDict.allKeys];
            
            [self.tableView reloadData];
        });
    }];
    
    for(PersonInfoModel *model in self.dataSource)
    {
        NSLog(@"%@ %@ %@", model.personName, model.personPhone, model.personNameHeadLetter);
    }
}


#pragma mark -- UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 25;
}

#pragma mark -- UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if(self.searchBar.text.length > 0) return 1;
    return self.indexArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(self.searchBar.text.length > 0) return self.searchArray.count;
    return [self.sortDict[self.indexArray[section]] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CELL"];
    if(cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"CELL"];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if(self.searchBar.text.length > 0)
    {
        PersonInfoModel *model = self.searchArray[indexPath.row];
        cell.textLabel.text = model.personName;
    }
    else
    {
        PersonInfoModel *model =  self.sortDict[self.indexArray[indexPath.section]][indexPath.row];
        cell.textLabel.text = model.personName;
    }
    return cell;
}

//区头
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if(self.searchBar.text.length > 0) return nil;
    
    return self.indexArray[section];
}

//右侧索引
- (NSArray<NSString *> *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    if(self.searchBar.text.length > 0) return nil;
    
    return self.indexArray;
}

#pragma mark -- UISearchBarDelegate

//开始编辑搜索框
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    [UIView animateWithDuration:0.3 animations:^{
        
        self.navigationController.navigationBar.hidden =  YES;
        self.searchBar.frame = CGRectMake(0, 20, SCREEN_WIDTH, 44);
        self.tableView.frame = CGRectMake(0, 64, SCREEN_WIDTH, SCREEN_HEIGHT - 64);
        self.searchBar.showsCancelButton = YES;
    }];
    [self.view addSubview:self.statueView];
    self.statueView.hidden = NO;
}

//点击取消按钮
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [UIView animateWithDuration:0.3 animations:^{
        
        self.navigationController.navigationBar.hidden = NO;
        self.statueView.hidden = YES;
        self.searchBar.frame = CGRectMake(0, 64, SCREEN_WIDTH, 44);
        self.tableView.frame = CGRectMake(0, 64+44, SCREEN_WIDTH, SCREEN_HEIGHT - 64-44);
        self.searchBar.showsCancelButton = NO;
        [self.searchBar resignFirstResponder];
    }];
}

//搜索框内容变化
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    [self.searchArray removeAllObjects];
    if(searchText.length == 0)
    {
        [self.tableView reloadData];
        return;
    }
    
    self.searchArray = [SortAlphabetically blurrySearchFromDataArray:[SortAlphabetically fetchAllValuesFromSortDict:self.sortDict] propertyName:@"personName" searchString:searchText];
    if(self.searchArray.count == 0)
    {
        NSLog(@"你所搜索的内容不存在");
    }
    [self.tableView reloadData];
}

#pragma mark -- getter

- (UITableView *)tableView
{
    if(!_tableView)
    {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 108, SCREEN_WIDTH, SCREEN_HEIGHT-64 - 44) style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
    }
    return _tableView;
}

- (NSMutableArray *)dataSource
{
    if(!_dataSource)
    {
        _dataSource = [[NSMutableArray alloc] init];
    }
    return _dataSource;
}

- (NSMutableArray *)indexArray
{
    if(!_indexArray)
    {
        _indexArray = [[NSMutableArray alloc] init];
    }
    return _indexArray;
}

- (NSMutableDictionary *)sortDict
{
    if(!_sortDict)
    {
        _sortDict = [[NSMutableDictionary alloc] init];
    }
    return _sortDict;
}

- (NSMutableArray *)searchArray
{
    if(!_searchArray)
    {
        _searchArray = [NSMutableArray array];
    }
    return _searchArray;
}

- (UISearchBar *)searchBar
{
    if(!_searchBar)
    {
        _searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 64, SCREEN_WIDTH, 44)];
        _searchBar.delegate = self;
        _searchBar.placeholder = @"搜索...";
    }
    return _searchBar;
}

- (UIView *)statueView
{
    if(!_statueView)
    {
        _statueView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 20)];
        _statueView.backgroundColor = [UIColor colorWithRed:201/255.0 green:201/255.0 blue:206/255.0 alpha:1];
    }
    return _statueView;
}

@end
