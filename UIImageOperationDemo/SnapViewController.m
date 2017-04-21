//
//  SnapViewController.m
//  UIImageOperationDemo
//
//  Created by 高磊 on 2017/4/21.
//  Copyright © 2017年 高磊. All rights reserved.
//

#import "SnapViewController.h"
#import "UIImage+GLProcessing.h"

@interface SnapViewController ()

@property (nonatomic,strong) UIImageView *bottomImageView;

@property (nonatomic,strong) UIImageView *topImageView;

@end

@implementation SnapViewController

- (void)dealloc
{
    NSLog(@" 打印信息  释放");
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor whiteColor];
    
    [self.view addSubview:self.topImageView];
    [self.view addSubview:self.bottomImageView];
    
    UIButton *snapButton = [UIButton buttonWithType:UIButtonTypeCustom];
    snapButton.frame = CGRectMake(CGRectGetMaxX(self.topImageView.frame), 80, 80, 40);
    [snapButton setTitle:@"截图" forState:UIControlStateNormal];
    snapButton.titleLabel.font = [UIFont systemFontOfSize:11];
    [snapButton addTarget:self action:@selector(snap:) forControlEvents:UIControlEventTouchUpInside];
    snapButton.backgroundColor = [UIColor orangeColor];
    [self.view addSubview:snapButton];
}


#pragma mark == event response
- (void)snap:(UIButton *)sender
{
    UIImage *image = [UIImage gl_snapScreenView:self.bottomImageView];
    self.topImageView.image = image;
    self.bottomImageView.image = image;
}


#pragma mark == 懒加载
- (UIImageView *)bottomImageView
{
    if (nil == _bottomImageView) {
        _bottomImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.view.frame)/2.0, self.view.frame.size.width, CGRectGetHeight(self.view.frame)/2.0)];
        _bottomImageView.image = [UIImage imageNamed:@"4.jpg"];
    }
    return _bottomImageView;
}

- (UIImageView *)topImageView
{
    if (nil == _topImageView) {
        _topImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 80, self.view.frame.size.width - 100, CGRectGetHeight(self.view.frame)/2.0-80)];
    }
    return _topImageView;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
