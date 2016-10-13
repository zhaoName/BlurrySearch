//
//  CustomTableViewController.m
//  BlurrySearch
//
//  Created by zhao on 16/9/23.
//  Copyright © 2016年 zhaoName. All rights reserved.
//

#import "CustomTableViewController.h"
#import "SortAlphabetically.h"
#import "AddDataViewController.h"

#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height

@interface CustomTableViewController ()<UISearchResultsUpdating>

@property (nonatomic, strong) NSMutableArray *dataSource; /**<最初的数据*/
@property (nonatomic, strong) NSMutableArray *indexArray; /**< 索引数据源*/
@property (nonatomic, strong) NSMutableDictionary *sortDict; /**< 排序后的数据源*/

@property (nonatomic, strong) UISearchController *searchController;
@property (nonatomic, strong) NSMutableArray *searchArray; /**< 搜索数据源*/


- (IBAction)touchRightBarItem:(UIBarButtonItem *)sender;

@end

@implementation CustomTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"自定义";
    self.tableView.tableHeaderView = self.searchController.searchBar;
    [self initDatas];
}

- (void)initDatas
{
    self.dataSource = [NSMutableArray arrayWithArray:@[@"卢锡安", @"朝向", @"Will Smith", @"卡特琳娜", @"安妮", @"盖伦", @"赵信1", @"赵信a", @"嘉文四世", @"泰达米尔", @"12abd", @"艾希", @"Nicolas Cage", @"易", @"朝阳", @"金克斯", @"亚索", @"ab赵", @"拉克丝", @"🐶想～", @"阿狸", @"维克托", @"杰斯", @"$@+_#", @"布隆", @"艾瑞莉娅", @"贾克斯", @"潘森", @"内瑟斯", @"Tom", @"£&*12"]];
    
   self.indexArray = [[SortAlphabetically shareSortAlphabetically] fetchFirstLetterFromArray:self.dataSource];
   self.sortDict = [[SortAlphabetically shareSortAlphabetically] sortAlphabeticallyWithDataArray:self.dataSource propertyName:nil];
}

- (IBAction)touchRightBarItem:(UIBarButtonItem *)sender
{
    AddDataViewController * addDataVC = [[AddDataViewController alloc] init];
    
     addDataVC.AddStringDataBlock = ^(NSString *addData)
    {
        //单独添加一个数据
        [self.dataSource addObject:addData];
        self.sortDict = [[SortAlphabetically shareSortAlphabetically] addDataToSortDictionary:addData propertyName:nil];
        self.indexArray = [[SortAlphabetically shareSortAlphabetically] sortAllKeysFromDictKey:self.sortDict.allKeys];
        [self.tableView reloadData];
    };
    [self.navigationController pushViewController:addDataVC animated:YES];
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
    if(self.searchController.active) return 1;
    return self.indexArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(self.searchController.active) return self.searchArray.count;
    
    return [self.sortDict[self.indexArray[section]] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CELL"];
    if(cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CELL"];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if(self.searchController.active)
    {
        cell.textLabel.text = self.searchArray[indexPath.row];
    }
    else
    {
        cell.textLabel.text = self.sortDict[self.indexArray[indexPath.section]][indexPath.row];
    }
    
    return cell;
}

//区头
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if(self.searchController.active) return nil;
    
    return self.indexArray[section];
}

//右侧索引
- (NSArray<NSString *> *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    if(self.searchController.active) return nil;
    
    return self.indexArray;
}

#pragma mark -- UISearchResultsUpdating

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController
{
    [self.searchArray removeAllObjects];
    if(self.searchController.searchBar.text.length == 0){
        [self.tableView reloadData];
        return;
    }
    
    //NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF CONTAINS[c] %@", self.searchController.searchBar.text];
    //[self.searchArray addObjectsFromArray:[self.dataSource filteredArrayUsingPredicate:predicate]];
    
    self.searchArray = [[SortAlphabetically shareSortAlphabetically] blurrySearchFromDataArray:[[SortAlphabetically shareSortAlphabetically] fetchAllValuesFromSortDict:self.sortDict] propertyName:nil searchString:self.searchController.searchBar.text];
    if(self.searchArray.count == 0)
    {
        NSLog(@"你所搜索的内容不存在");
    }
    [self.tableView reloadData];
}

#pragma mark -- getter

- (NSMutableArray *)dataSource
{
    if(!_dataSource)
    {
        _dataSource = [NSMutableArray array];
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

- (UISearchController *)searchController
{
    if(!_searchController)
    {
        _searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
        _searchController.searchResultsUpdater = self;
        _searchController.hidesNavigationBarDuringPresentation = YES;
        _searchController.dimsBackgroundDuringPresentation = NO;
        _searchController.searchBar.placeholder = @"搜索...";
    }
    return _searchController;
}

@end
