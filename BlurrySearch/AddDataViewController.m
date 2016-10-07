//
//  AddDataViewController.m
//  BlurrySearch
//
//  Created by zhao on 16/9/30.
//  Copyright © 2016年 zhaoName. All rights reserved.
//

#import "AddDataViewController.h"

@interface AddDataViewController ()

@property (nonatomic, strong) UITextField *textField;

@end

@implementation AddDataViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"添加数据";
    self.view.backgroundColor = [UIColor lightGrayColor];
    
    [self.view addSubview:self.textField];
    
    UIButton *saveBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    saveBtn.frame = CGRectMake(0, 0, 200, 40);
    saveBtn.center = self.view.center;
    [saveBtn setTitle:@"保存" forState:UIControlStateNormal];
    saveBtn.titleLabel.font = [UIFont systemFontOfSize:21];
    saveBtn.backgroundColor = [UIColor colorWithRed:13/255.0 green:126/255.0 blue:251/255.0 alpha:1];
    saveBtn.layer.cornerRadius = 8.0;
    [saveBtn addTarget:self action:@selector(touchSaveBtn:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:saveBtn];
}

- (void)touchSaveBtn:(UIButton *)btn
{
    self.AddStringDataBlock(self.textField.text);
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}

- (UITextField *)textField
{
    if(!_textField)
    {
        _textField = [[UITextField alloc] initWithFrame:CGRectMake(20, 250, self.view.frame.size.width - 40, 34)];
        _textField.placeholder = @"请输入所要添加的数据...";
        _textField.borderStyle = UITextBorderStyleRoundedRect;
        [_textField becomeFirstResponder];
    }
    return _textField;
}

@end
