//
//  ViewController.m
//  UIImageOperationDemo
//
//  Created by 高磊 on 2017/4/10.
//  Copyright © 2017年 高磊. All rights reserved.
//  之前写测试用的vc

#import "ViewController.h"
#import <HomeKit/HomeKit.h>
#import <objc/runtime.h>
#import <objc/message.h>
#import "UIImage+GLProcessing.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <Photos/Photos.h>
#import <MobileCoreServices/MobileCoreServices.h>

@interface ViewController ()<HMHomeManagerDelegate,UIImagePickerControllerDelegate>

@property (nonatomic,strong) HMHomeManager *homeManager;

@property (nonatomic,strong) UIImageView *imageView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.homeManager = [[HMHomeManager alloc] init];
    self.homeManager.delegate = (id)self;
    
    HMHome *home = self.homeManager.primaryHome;
    
    HMHome *home1;
    for(home1 in self.homeManager.homes ){
    
    }
    HMRoom *room;
    for(room in home.rooms){
    
    }
    
    NSMutableArray *array = [[NSMutableArray alloc] init];
    [array insertObject:@"1" atIndex:0];
    
    objc_msgSend(array,@selector(insertObject:atIndex:),@"1",1);
    
    NSLog(@" 打印信息:%@",array);
    
    objc_msgSend(self, @selector(eat:));
//    ((void(*)(id,SEL, id,id))objc_msgSend)(array,insertObject:atIndex:, @"1", 0);


    for (int i = 0; i < 10; i ++) {
        UILabel *lable = [[UILabel alloc] initWithFrame:CGRectMake(0, 100+i*30, 300, 30)];
        lable.textAlignment = NSTextAlignmentCenter;
        switch (i) {
            case 0:
            {
                lable.font = [UIFont preferredFontForTextStyle:UIFontTextStyleTitle1];
            }
                break;
            case 1:
            {
                lable.font = [UIFont preferredFontForTextStyle:UIFontTextStyleTitle2];
            }
                break;

            case 2:
            {
                lable.font = [UIFont preferredFontForTextStyle:UIFontTextStyleTitle3];
            }
                break;
            case 3:
            {
                lable.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
            }
                break;
            case 4:
            {
                lable.font = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
            }
                break;
            case 5:
            {
                lable.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
            }
                break;
            case 6:
            {
                lable.font = [UIFont preferredFontForTextStyle:UIFontTextStyleCallout];
            }
                break;
            case 7:
            {
                lable.font = [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote];
            }
                break;
            case 8:
            {
                lable.font = [UIFont preferredFontForTextStyle:UIFontTextStyleCaption1];
            }
                break;
            case 9:
            {
                lable.font = [UIFont preferredFontForTextStyle:UIFontTextStyleCaption2];
            }
                break;
                
            default:
                break;
        }
        
        
        lable.attributedText = [[NSAttributedString alloc]initWithString:@"新年好" attributes:@{NSBackgroundColorAttributeName:[UIColor redColor]}];

        [self.view addSubview:lable];
        
    }
    
    UIView *backView = [[UIView alloc] initWithFrame:CGRectMake(20, 200, 250, 250)];
    [self.view addSubview:backView];
    
    UIImageView *gifImageView = [[UIImageView alloc] initWithFrame:backView.bounds];
//    gifImageView.image = [UIImage animatedImageWithImages:@[[UIImage imageNamed:@"燕儿.jpg"],[UIImage imageNamed:@"IMG_1909.JPG"]] duration:0.5];
    
//    UIImage *circleImage = [UIImage circleImage:[UIImage imageNamed:@"2.jpg"] withBorder:10 color:[UIColor redColor]];
//    UIImage *circleImage = [UIImage imageWithColor:[UIColor redColor] size:CGSizeMake(100, 100)];
//    UIImage *circleImage = [UIImage circleImage:[UIImage imageNamed:@"2.jpg"]];
//    UIImage *circleImage = [UIImage circleImageWithColor:[UIColor greenColor] radius:125];
    
//    UIImage *circleImage = [UIImage cornerImage:[UIImage imageNamed:@"2.jpg"] corner:5 rectCorner:UIRectCornerTopLeft | UIRectCornerTopRight];
//    UIImage *circleImage = [UIImage compressImage:[UIImage imageNamed:@"23.jpg"] maxSize:960 maxSizeWithKB:50];
    

//    
//    NSData *data = [NSData dataWithContentsOfFile:retinaPath];
//    
//    UIImage *circleImage = [UIImage animateGIFWithImageData:data];
//    
//    NSString *retinaPath = [[NSBundle mainBundle] pathForResource:@"baf9fd7f6d137c9ef485491bc9ce1466" ofType:@"gif"];
//    UIImage *circleImage = [UIImage animateGIFWithImagePath:retinaPath];
    UIImage *circleImage = [UIImage gl_animateGIFWithImageUrl:[NSURL URLWithString:@"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1492664287090&di=5a345853807dab1853c289ecf7534894&imgtype=0&src=http%3A%2F%2Fscimg.jb51.net%2Fallimg%2F160602%2F2-16060223055H33.gif"]];
    
    gifImageView.image = circleImage;
    
//    [self backGroundJob];
//    [UIImageJPEGRepresentation([UIImage imageNamed:@"23.jpg"], 1) writeToFile:[self getFilePath:@"cache" file:@"231"] atomically:NO];
//    NSData *data = UIImageJPEGRepresentation(circleImage, 1);
//    [data writeToFile:[self getFilePath:@"cache" file:@"23"] atomically:NO];
    
    
    [backView addSubview:gifImageView];
    self.imageView = gifImageView;
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.backgroundColor = [UIColor orangeColor];
    btn.frame = CGRectMake(100, 100, 40, 40);
    [btn addTarget:self action:@selector(changeIcon:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    
}

- (void)backGroundJob
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory = [paths objectAtIndex:0];
    NSFileManager *fm=[NSFileManager defaultManager];
    
    NSString *burimagePath=[documentDirectory stringByAppendingPathComponent:@"cache"];
    if(![fm fileExistsAtPath:burimagePath]){
        [fm createDirectoryAtPath:burimagePath withIntermediateDirectories:YES attributes:nil error:NULL];
    }
}

- (NSString *)getFilePath:(NSString*)directory file:(NSString *)hash{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory = [paths objectAtIndex:0];
    NSString *imagePath=[documentDirectory stringByAppendingPathComponent:directory];
    imagePath=[imagePath stringByAppendingPathComponent:hash];
    return imagePath;
}

- (void)changeIcon:(UIButton *)sender
{
//    [self openPhotos];

    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:[UIFont systemFontOfSize:15],NSFontAttributeName,[UIColor whiteColor],NSForegroundColorAttributeName,[UIColor blackColor],NSBackgroundColorAttributeName, nil];
    
    self.imageView.image = [UIImage gl_addTitleAboveImage:[UIImage imageNamed:@"11@2x.png"] addTitleText:@"添加文字成功" attributeDic:dic point:CGPointMake(50, 40)];
    
    
//    UIApplication *app = [UIApplication sharedApplication];
//    if ([app supportsAlternateIcons]) {
//        [app setAlternateIconName:@"120" completionHandler:^(NSError * _Nullable error) {
//            if (error) {NSLog(@"%@",error);}
//            dispatch_async(dispatch_get_main_queue(), ^{
//                [self updateLabel];
//            });
//        }];
//    }

}




- (void)updateLabel{
    UIApplication *app = [UIApplication sharedApplication];
    NSString *currentName = app.alternateIconName;
//    self.label.text = [NSString stringWithFormat:@"current AppIcon:%@",currentName?:@"<Default AppIcon>"];
//    [self.label sizeToFit];
}

void fooMethod(id obj, SEL _cmd)
{
    NSLog(@"Doing foo");
}



+ (BOOL)resolveInstanceMethod:(SEL)aSEL
{
    IMP fooIMP = imp_implementationWithBlock(^(id _self) {
        NSLog(@"Doing foo");
    });
    
    if(aSEL == @selector(eat:)){
        class_addMethod([self class], aSEL, fooIMP, "v@:");
        return YES;
    }
    return [super resolveInstanceMethod:aSEL];
}

- (id)forwardingTargetForSelector:(SEL)aSelector
{
    if(aSelector == @selector(eat:)){
        return @"";
    }
    return [super forwardingTargetForSelector:aSelector];
}

- (void)forwardInvocation:(NSInvocation *)anInvocation
{

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


@end
