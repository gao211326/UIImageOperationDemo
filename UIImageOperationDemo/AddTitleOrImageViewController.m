//
//  AddTitleOrImageViewController.m
//  UIImageOperationDemo
//
//  Created by 高磊 on 2017/4/20.
//  Copyright © 2017年 高磊. All rights reserved.
//

#import "AddTitleOrImageViewController.h"
#import "UIImage+GLProcessing.h"

@interface AddTitleOrImageViewController ()

//添加文字按钮
@property (nonatomic,strong) UIButton *addTitleButton;
//添加图片按钮
@property (nonatomic,strong) UIButton *addImageButton;

@property (nonatomic,strong) UIImageView *imageView;

@end

@implementation AddTitleOrImageViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor grayColor];
    [self.view addSubview:self.addTitleButton];
    [self.view addSubview:self.addImageButton];
    [self.view addSubview:self.imageView];
}




#pragma mark == event response
- (void)addImageButtonClick:(UIButton *)sender
{
    UIImage *image = [UIImage imageNamed:@"timg.jpeg"];
    self.imageView.image = [UIImage gl_addAboveImage:image addImage:[UIImage imageNamed:@"3.jpg"] rect:CGRectMake(0, 0, image.size.width/2.0, image.size.height/2.0)];
}

- (void)addTitleButtonClick:(UIButton *)sender
{
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:[UIFont systemFontOfSize:15],NSFontAttributeName,[UIColor whiteColor],NSForegroundColorAttributeName,[UIColor blackColor],NSBackgroundColorAttributeName, nil];
    
    self.imageView.image = [UIImage gl_addTitleAboveImage:[UIImage imageNamed:@"11@2x.png"] addTitleText:@"添加文字成功" attributeDic:dic point:CGPointMake(50, 40)];
}


#pragma mark == 懒加载
- (UIImageView *)imageView
{
    if (nil == _imageView) {
        _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 160, self.view.frame.size.width, 300)];
    }
    return _imageView;
}

- (UIButton *)addImageButton
{
    if (nil == _addImageButton) {
        _addImageButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _addImageButton.frame = CGRectMake(200, 100, 100, 40);
        [_addImageButton setTitle:@"添加一张图片" forState:UIControlStateNormal];
        _addImageButton.titleLabel.font = [UIFont systemFontOfSize:13];
        [_addImageButton addTarget:self action:@selector(addImageButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _addImageButton;
}

- (UIButton *)addTitleButton
{
    if (nil == _addTitleButton) {
        _addTitleButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _addTitleButton.frame = CGRectMake(10, 100, 100, 40);
        [_addTitleButton setTitle:@"添加一段文字" forState:UIControlStateNormal];
        _addTitleButton.titleLabel.font = [UIFont systemFontOfSize:13];
        [_addTitleButton addTarget:self action:@selector(addTitleButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _addTitleButton;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
