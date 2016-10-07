//
//  AddModleDataViewController.m
//  BlurrySearch
//
//  Created by 赵松波 on 16/10/7.
//  Copyright © 2016年 zhaoName. All rights reserved.
//

#import "AddModleDataViewController.h"

@interface AddModleDataViewController ()


@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextField *phoneTextField;
@property (weak, nonatomic) IBOutlet UIButton *touchSaveButton;

- (IBAction)touchSaveBuuton:(UIButton *)sender;


@end

@implementation AddModleDataViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
}



- (IBAction)touchSaveBuuton:(UIButton *)sender
{
    PersonInfoModel *model = [[PersonInfoModel alloc] init];
    model.personName = self.nameTextField.text;
    model.personPhone = [NSMutableArray arrayWithObject:self.phoneTextField.text];
    model.personNameHeadLetter = @"A";
    self.AddModelDataBlock(@"mmode");
    
    [self.navigationController popViewControllerAnimated:YES];
}
@end
