//
//  UIImageSimpleViewController.m
//  UIImageOperationDemo
//
//  Created by 高磊 on 2017/4/20.
//  Copyright © 2017年 高磊. All rights reserved.
//

#import "UIImageSimpleViewController.h"
#import "UIImage+GLProcessing.h"

@interface UIImageSimpleViewController ()

@end

@implementation UIImageSimpleViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor whiteColor];

    [self addSubViews];
}


#pragma mark == private method
- (void)addSubViews
{
    for (NSInteger i = 0; i < 7; i ++) {
        UILabel *lable = [[UILabel alloc] init];
        lable.font = [UIFont systemFontOfSize:11];
        lable.textAlignment = NSTextAlignmentCenter;
        [self.view addSubview:lable];
        
        UIImageView *imageView = [[UIImageView alloc] init];
        [self.view addSubview:imageView];
        
        if (i < 3) {
            lable.frame = CGRectMake(20*(i+1)+80*i, 120, 80, 20);
            imageView.frame = CGRectMake(CGRectGetMinX(lable.frame), CGRectGetMaxY(lable.frame)+10, CGRectGetWidth(lable.frame), CGRectGetWidth(lable.frame));
        }else if(i == 6){
            lable.frame = CGRectMake(20, 120 + 2 * (10+80+40), 80, 20);
            imageView.frame = CGRectMake(CGRectGetMinX(lable.frame), CGRectGetMaxY(lable.frame)+10, CGRectGetWidth(lable.frame), CGRectGetWidth(lable.frame));
        }else{
            lable.frame = CGRectMake(20*(i-3+1)+80*(i-3), 120+10+80+40, 80, 20);
            imageView.frame = CGRectMake(CGRectGetMinX(lable.frame), CGRectGetMaxY(lable.frame)+10, CGRectGetWidth(lable.frame), CGRectGetWidth(lable.frame));
        }
        
        switch (i) {
            case 0:
            {
                lable.text = @"带圆圈的圆图";
                imageView.image = [UIImage gl_circleImage:[UIImage imageNamed:@"11"] withBorder:5 color:[UIColor orangeColor]];
            }
                break;
            case 1:
            {
                lable.text = @"不带圆圈的圆图";
                imageView.image = [UIImage gl_circleImage:[UIImage imageNamed:@"11"]];
            }
                break;
            case 2:
            {
                lable.text = @"颜色创建矩形图";
                imageView.image = [UIImage gl_imageWithColor:[UIColor purpleColor] size:imageView.bounds.size];
            }
                break;
            case 3:
            {
                lable.text = @"颜色创建圆图";
                imageView.image = [UIImage gl_circleImageWithColor:[UIColor magentaColor] radius:imageView.bounds.size.width];
            }
                break;
            case 4:
            {
                lable.text = @"图片设置圆角";
                imageView.image = [UIImage gl_cornerImage:[UIImage imageNamed:@"11"] corner:30 rectCorner:UIRectCornerTopLeft | UIRectCornerBottomRight];
            }
                break;
            case 5:
            {
                lable.text = @"压缩图片";
                imageView.image = [UIImage gl_compressImage:[UIImage imageNamed:@"11"] maxSize:30 maxSizeWithKB:5];
            }
                break;
            case 6:
            {
                lable.text = @"组合头像";
                //段落格式
                NSMutableParagraphStyle *textStyle = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
                textStyle.lineBreakMode = NSLineBreakByWordWrapping;
                textStyle.alignment = NSTextAlignmentCenter;//水平居中
                //字体
                UIFont *font = [UIFont boldSystemFontOfSize:18.0];
                //构建属性集合
                NSDictionary *attributes = @{NSFontAttributeName:font, NSParagraphStyleAttributeName:textStyle,NSForegroundColorAttributeName:[UIColor whiteColor]};
                //获得size
                NSAttributedString *attributeString = [[NSAttributedString alloc] initWithString:@"高" attributes:attributes];
                NSAttributedString *attributeString1 = [[NSAttributedString alloc] initWithString:@"云" attributes:attributes];

                imageView.image = [UIImage gl_groupHeadPortraitWithContents:@[attributeString,attributeString,attributeString,attributeString1] size:imageView.bounds.size];
            }
                break;
            default:
                break;
        }
        
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
