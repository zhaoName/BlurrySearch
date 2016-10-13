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
    
    self.touchSaveButton.layer.cornerRadius = 8.0;
}



- (IBAction)touchSaveBuuton:(UIButton *)sender
{
    // 输入规范在这不做判断 只要不为空就可以
    if (self.nameTextField.text.length <= 0 || self.phoneTextField.text.length <= 0 ) return;
    
    PersonInfoModel *model = [[PersonInfoModel alloc] init];
    model.personName = self.nameTextField.text;
    model.personPhone = [NSMutableArray arrayWithObject:self.phoneTextField.text];
    
    if ([self.delegate respondsToSelector:@selector(addModelDataDelegate:)])
    {
        [self.delegate addModelDataDelegate:model];
    }
    [self.navigationController popViewControllerAnimated:YES];
}
@end
