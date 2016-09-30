//
//  TableViewController.m
//  BlurrySearch
//
//  Created by zhao on 16/9/21.
//  Copyright © 2016年 zhaoName. All rights reserved.
//

#import "TableViewController.h"
#import "AddressBookController.h"
#import "CustomTableViewController.h"

@interface TableViewController ()

@end

@implementation TableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row == 0)
    {
        AddressBookController *bookVC = [[AddressBookController alloc] init];
        [self.navigationController pushViewController:bookVC animated:YES];
    }
    if(indexPath.row == 1)
    {
        CustomTableViewController *customVC = [[CustomTableViewController alloc] init];
        [self.navigationController pushViewController:customVC animated:YES];
    }
}

@end
