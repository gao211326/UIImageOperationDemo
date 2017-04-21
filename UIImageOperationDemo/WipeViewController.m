//
//  WipeViewController.m
//  UIImageOperationDemo
//
//  Created by 高磊 on 2017/4/21.
//  Copyright © 2017年 高磊. All rights reserved.
//

#import "WipeViewController.h"
#import "UIImage+GLProcessing.h"

@interface WipeViewController ()

@property (nonatomic,strong) UIImageView *imageView;//底层图

@property (nonatomic,strong) UIImageView *maskImageView;//蒙板

@end

@implementation WipeViewController

- (void)dealloc
{
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
    [self.view addGestureRecognizer:pan];
    
    [self.view addSubview:self.imageView];
    [self.view addSubview:self.maskImageView];
}


#pragma mark == event response
- (void)pan:(UIPanGestureRecognizer *)pan
{
    CGPoint point = [pan locationInView:self.view];
    if (pan.state == UIGestureRecognizerStateBegan)
    {
        
        CGRect rect = {CGPointMake(point.x-10, point.y-10),CGSizeMake(20, 20)};
        
        UIView *wipeView = [[UIView alloc] initWithFrame:rect];
        wipeView.layer.borderColor = [UIColor redColor].CGColor;
        wipeView.layer.borderWidth = 1;
        wipeView.layer.cornerRadius = 10;
        wipeView.tag = 2006;
        [self.view addSubview:wipeView];
    }
    else if (pan.state == UIGestureRecognizerStateChanged)
    {
        UIView *wipeView;
        if ([self.view viewWithTag:2006]) {
            wipeView = [self.view viewWithTag:2006];
            CGRect rect = {CGPointMake(point.x-10, point.y-10),CGSizeMake(20, 20)};
            wipeView.frame = rect;
        }
        
        self.maskImageView.image = [UIImage gl_wipeImageWithView:self.maskImageView movePoint:point brushSize:CGSizeMake(20, 20)];
        
    }
    else if(pan.state == UIGestureRecognizerStateCancelled || pan.state == UIGestureRecognizerStateEnded)
    {
    
        UIView *wipeView;
        if ([self.view viewWithTag:2006]) {
            wipeView = [self.view viewWithTag:2006];
            [wipeView removeFromSuperview];
            wipeView = nil;
        }
    }
}


#pragma mark == 懒加载
- (UIImageView *)imageView
{
    if (nil == _imageView) {
        _imageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
        _imageView.image = [UIImage imageNamed:@"back.jpg"];
    }
    return _imageView;
}

- (UIImageView *)maskImageView
{
    if (nil == _maskImageView) {
        _maskImageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
        _maskImageView.image = [UIImage imageNamed:@"mask.jpg"];
    }
    return _maskImageView;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
