//
//  GIFViewController.m
//  UIImageOperationDemo
//
//  Created by 高磊 on 2017/4/20.
//  Copyright © 2017年 高磊. All rights reserved.
//

#import "GIFViewController.h"
#import "UIImage+GLProcessing.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <MobileCoreServices/MobileCoreServices.h>

static NSInteger const kButtonTag = 1000;

@interface GIFViewController ()<UIImagePickerControllerDelegate>

@property (nonatomic,strong) UIImageView *gifImageView;

@end

@implementation GIFViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor whiteColor];
    
    [self addSubViews];
}

- (void)addSubViews
{
    for (NSInteger i = 0; i < 3; i ++) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(20*(i+1) + 70 * i , 80, 70, 30);
        btn.titleLabel.font = [UIFont systemFontOfSize:12];
        btn.backgroundColor = [UIColor orangeColor];
        if (i == 0) {
            [btn setTitle:@"加载本地gif" forState:UIControlStateNormal];
        }else if (i == 1){
            [btn setTitle:@"网络加载gif" forState:UIControlStateNormal];
        }else{
            [btn setTitle:@"获取相册gif" forState:UIControlStateNormal];;
        }

        
        btn.tag = kButtonTag + i;
        [btn addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:btn];
    }
    
    [self.view addSubview:self.gifImageView];
}


#pragma mark == event response
- (void)buttonClick:(UIButton *)sender
{
    switch (sender.tag) {
        case 1000:
        {
            NSString *retinaPath = [[NSBundle mainBundle] pathForResource:@"baf9fd7f6d137c9ef485491bc9ce1466" ofType:@"gif"];
            UIImage *image = [UIImage gl_animateGIFWithImagePath:retinaPath];
            self.gifImageView.image = image;
        }
            break;
        case 1001:
        {
            UIImage *image = [UIImage gl_animateGIFWithImageUrl:[NSURL URLWithString:@"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1492664287090&di=5a345853807dab1853c289ecf7534894&imgtype=0&src=http%3A%2F%2Fscimg.jb51.net%2Fallimg%2F160602%2F2-16060223055H33.gif"]];
            self.gifImageView.image = image;
        }
            break;
        case 1002:
        {
            [self openPhotos];
        }
            break;
        default:
            break;
    }
}



#pragma mark == private method
- (void)openPhotos
{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary])
    {
        UIImagePickerController *controller = [[UIImagePickerController alloc] init];
        controller.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        NSMutableArray *mediaTypes = [[NSMutableArray alloc] init];
        [mediaTypes addObject:(__bridge NSString *)kUTTypeImage];
        controller.mediaTypes = mediaTypes;
        controller.delegate = (id)self;
        [self presentViewController:controller
                           animated:YES
                         completion:^(void){
                             NSLog(@"Picker View Controller is presented");
                         }];
    }
}

#pragma mark == UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    
    __weak typeof(self)weakSelf = self;
    [picker dismissViewControllerAnimated:YES completion:^() {
        
        NSURL *imageURL = [info valueForKey:UIImagePickerControllerReferenceURL];
        
        ALAssetsLibraryAssetForURLResultBlock resultblock = ^(ALAsset *myasset)
        {
            //gif图片转场data  不能直接用UIImagePNGRepresentation 或者 UIImageJPEGRepresentation
            //这样获得的只是其中一帧的图片的data
            ALAssetRepresentation *rep = [myasset defaultRepresentation];
            Byte *imageBuffer = (Byte*)malloc(rep.size);
            NSUInteger bufferSize = [rep getBytes:imageBuffer fromOffset:0.0 length:rep.size error:nil];
            NSData *imageData = [NSData dataWithBytesNoCopy:imageBuffer length:bufferSize freeWhenDone:YES];
            weakSelf.gifImageView.image = [UIImage gl_animateGIFWithImageData:imageData];
            
        };
        ALAssetsLibrary* assetslibrary = [[ALAssetsLibrary alloc] init];
        [assetslibrary assetForURL:imageURL
                       resultBlock:resultblock
         
                      failureBlock:nil];
    }];
}

#pragma mark == 懒加载
- (UIImageView *)gifImageView
{
    if (nil == _gifImageView) {
        _gifImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 150, self.view.frame.size.width, 300)];
    }
    return _gifImageView;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
