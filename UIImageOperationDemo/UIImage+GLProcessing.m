//
//  UIImage+GLProcessing.m
//  UIImageOperationDemo
//
//  Created by 高磊 on 2017/4/12.
//  Copyright © 2017年 高磊. All rights reserved.
//

#import "UIImage+GLProcessing.h"
#import <ImageIO/ImageIO.h>


@implementation UIImage (GLProcessing)

+ (UIImage*)gl_circleImage:(UIImage*)image withBorder:(CGFloat)border color:(UIColor *)color
{
    //通过自己创建一个context来绘制,通常用于对图片的处理
    //在retian屏幕上要使用这个函数，才能保证不失真
    //该函数会自动创建一个context，并把它push到上下文栈顶，坐标系也经处理和UIKit的坐标系相同
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(image.size.width, image.size.height), NO, [UIScreen mainScreen].scale);
    //获取上下文
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGRect rect = CGRectMake(0, 0, image.size.width, image.size.height);
    //设置宽度
    CGContextSetLineWidth(context, 4*border);
    //设置边框颜色
    CGContextSetStrokeColorWithColor(context, color.CGColor);

    //画椭圆 当宽和高一样的时候 为圆 此处设置可视范围
    CGContextAddEllipseInRect(context, rect);
    //剪切可视范围
    CGContextClip(context);

    //绘制图片
    [image drawInRect:rect];

    CGContextAddEllipseInRect(context, rect);
    // 绘制当前的路径 只描绘边框
    CGContextStrokePath(context);

    
    UIImage *newimg = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newimg;
}

+ (UIImage *)gl_circleImage:(UIImage *)image
{
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(image.size.width, image.size.height), NO, [UIScreen mainScreen].scale);
    //获取上下文
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGRect rect = CGRectMake(0, 0, image.size.width, image.size.height);

    //画椭圆 当宽和高一样的时候 为圆
    CGContextAddEllipseInRect(context, rect);
    //剪切可视范围
    CGContextClip(context);
    
    //绘制图片
    [image drawInRect:rect];
    
    UIImage *newimg = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newimg;
}

+ (UIImage *)gl_imageWithColor:(UIColor *)color size:(CGSize)size{
    CGSize imageSize = size;
    //通过自己创建一个context来绘制，通常用于对图片的处理
    UIGraphicsBeginImageContextWithOptions(imageSize, NO, [UIScreen mainScreen].scale);
    //获取上下文
    CGContextRef context = UIGraphicsGetCurrentContext();
    //设置填充颜色
    CGContextSetFillColorWithColor(context, color.CGColor);
    //直接按rect的范围覆盖
    CGContextFillRect(context, CGRectMake(0, 0, size.width, size.height));
    UIImage *newimg = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newimg;
}

+ (UIImage *)gl_circleImageWithColor:(UIColor *)color radius:(CGFloat)radius
{
    CGSize imageSize = CGSizeMake(radius, radius);
    //通过自己创建一个context来绘制，通常用于对图片的处理
    UIGraphicsBeginImageContextWithOptions(imageSize, NO, [UIScreen mainScreen].scale);
    //获取上下文
    CGContextRef context = UIGraphicsGetCurrentContext();
    //设置填充颜色
    CGContextSetFillColorWithColor(context, color.CGColor);
    CGContextAddEllipseInRect(context, CGRectMake(0, 0, imageSize.width, imageSize.height));

    //用当前的填充颜色或样式填充路径线段包围的区域
    CGContextFillPath(context);
    UIImage *newimg = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newimg;
}

+ (UIImage*)gl_cornerImage:(UIImage*)image corner:(CGFloat)corner rectCorner:(UIRectCorner)rectCorner
{
    CGSize imageSize = image.size;
    UIGraphicsBeginImageContextWithOptions(imageSize, NO, [UIScreen mainScreen].scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGRect rect = CGRectMake(0,
                             0,
                             imageSize.width,
                             imageSize.height);
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:rect
                                               byRoundingCorners:rectCorner
                                                     cornerRadii:CGSizeMake(corner,
                                                                            corner)];
    //添加路径
    CGContextAddPath(context, [path CGPath]);
    //剪切可视范围
    CGContextClip(context);
    [image drawInRect:rect];
    
    UIImage *newimg = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newimg;
}

+ (UIImage*)gl_compressImage:(UIImage *)image maxSize:(CGFloat)maxSize maxSizeWithKB:(CGFloat)maxSizeKB
{    
    if (maxSize <= 0) {
        return nil;
    }
    
    if (maxSizeKB <= 0) {
        return nil;
    }

    CGSize compressSize = image.size;
    //获取缩放比 进行比较 
    CGFloat widthScale = compressSize.width*1.0 / maxSize;
    CGFloat heightScale = compressSize.height*1.0 / maxSize;
    
    if (widthScale > 1 && widthScale > heightScale) {
        compressSize = CGSizeMake(image.size.width/widthScale, image.size.height/widthScale);
    }
    else if (heightScale > 1 && heightScale > widthScale){
        compressSize = CGSizeMake(image.size.width/heightScale, image.size.height/heightScale);
    }
    
    //创建图片上下文 并获取剪切尺寸后的图片
    UIGraphicsBeginImageContextWithOptions(compressSize, NO, 1);
    CGRect rect = {CGPointZero,compressSize};
    [image drawInRect:rect];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    //循环缩小图片大小
    NSData *imageData = UIImageJPEGRepresentation(newImage, 1.0);
    //获取当前图片的大小
    CGFloat currentImageSizeOfKB = imageData.length/1024.0;
    
    //压缩比例
    CGFloat compress = 0.9;
    
    while (currentImageSizeOfKB > maxSizeKB && compress > 0.1) {
        imageData = UIImageJPEGRepresentation(newImage, compress);
        currentImageSizeOfKB = imageData.length/1024.0;
        compress -= 0.1;
    }
    return [UIImage imageWithData:imageData];
}

+ (UIImage *)gl_compressImage:(UIImage *)image maxSize:(CGFloat)maxSize
{
    if (maxSize <= 0) {
        return nil;
    }
    
    
    CGSize compressSize = image.size;
    //获取缩放比 进行比较
    CGFloat widthScale = compressSize.width*1.0 / maxSize;
    CGFloat heightScale = compressSize.height*1.0 / maxSize;
    
    if (widthScale > 1 && widthScale > heightScale) {
        compressSize = CGSizeMake(image.size.width/widthScale, image.size.height/widthScale);
    }
    else if (heightScale > 1 && heightScale > widthScale){
        compressSize = CGSizeMake(image.size.width/heightScale, image.size.height/heightScale);
    }
    
    //创建图片上下文 并获取剪切尺寸后的图片
    UIGraphicsBeginImageContextWithOptions(compressSize, NO, 1);
    CGRect rect = {CGPointZero,compressSize};
    [image drawInRect:rect];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

#pragma mark == GIF图片
+ (UIImage *)gl_animateGIFWithImagePath:(NSString *)imagePath
{
    NSData *data = [NSData dataWithContentsOfFile:imagePath];
    if (!data) {
        return nil;
    }
    
    //得到动态图片资源 用到create 后面需要释放
    CGImageSourceRef imageSource = CGImageSourceCreateWithData((__bridge CFDataRef)data, NULL);
    
    //得到图片资源的数量
    size_t imageCount = CGImageSourceGetCount(imageSource);
    //如果只有一张图片 则返回
    if (imageCount <= 1) {
        
        UIImage *resultImage = [UIImage imageWithData:data];
        
        return resultImage;
    }
    
    return animatedImageWithAnimateImageSource(imageSource);
}

+ (UIImage *)gl_animateGIFWithImageData:(NSData *)data
{
    if (!data) {
        return nil;
    }
    
    //得到动态图片资源 用到create 后面需要释放
    CGImageSourceRef imageSource = CGImageSourceCreateWithData((__bridge CFDataRef)data, NULL);
    
    //得到图片资源的数量
    size_t imageCount = CGImageSourceGetCount(imageSource);
    //如果只有一张图片 则返回
    if (imageCount <= 1) {
        
        UIImage *resultImage = [UIImage imageWithData:data];
        
        return resultImage;
    }
    
    return animatedImageWithAnimateImageSource(imageSource);
}

+ (UIImage *)gl_animateGIFWithImageUrl:(NSURL *)url
{
    if (!url) {
        return nil;
    }
    //得到动态图片资源 用到create 后面需要释放
    CGImageSourceRef imageSource = CGImageSourceCreateWithURL((__bridge CFURLRef)url, NULL);
      
    return animatedImageWithAnimateImageSource(imageSource);
}

//动态图片处理
static UIImage *animatedImageWithAnimateImageSource(CGImageSourceRef imageSource)
{
    if (imageSource) {
        //得到图片资源的数量
        size_t imageCount = CGImageSourceGetCount(imageSource);
        
        //最终图片资源
        UIImage *resultImage = nil;
        
        //动态图片时间
        NSTimeInterval duration = 0.0;
        //取图片资源
        NSMutableArray *images = [NSMutableArray arrayWithCapacity:imageCount];
        
        for (size_t i = 0; i < imageCount; i ++) {
            //此处用到了create  后面记得释放
            CGImageRef cgImage = CGImageSourceCreateImageAtIndex(imageSource, i, NULL);
            
            if (cgImage) {
                //将图片加入到数组中
                [images addObject:[UIImage imageWithCGImage:cgImage scale:[UIScreen mainScreen].scale orientation:UIImageOrientationUp]];
            }
            
            duration += frameDuration(i, imageSource);
            
            //释放掉 不然会内存泄漏
            CGImageRelease(cgImage);
        }
        
        if (duration == 0.0) {
            duration = 0.1 * imageCount;
        }
        
        
        resultImage = [UIImage animatedImageWithImages:images duration:duration];
        
        CFRelease(imageSource);
        
        return resultImage;
    }
    return nil;
}

static CGFloat frameDuration(NSInteger index,CGImageSourceRef source)
{
    //获取每一帧的信息
    CFDictionaryRef frameProperties = CGImageSourceCopyPropertiesAtIndex(source,index, nil);
    //转换为dic
    NSDictionary *framePropertiesDic = (__bridge NSDictionary *)frameProperties;
    //获取每帧中关于GIF的信息
    NSDictionary *gifProperties = framePropertiesDic[(__bridge NSString *)kCGImagePropertyGIFDictionary];
    /*
     苹果官方文档中的说明
     kCGImagePropertyGIFDelayTime
     The amount of time, in seconds, to wait before displaying the next image in an animated sequence
     
     kCGImagePropertyGIFUnclampedDelayTime
     The amount of time, in seconds, to wait before displaying the next image in an animated sequence. This value may be 0 milliseconds or higher. Unlike the kCGImagePropertyGIFDelayTime property, this value is not clamped at the low end of the range.
     
     看了翻译瞬间蒙了 感觉一样 但是kCGImagePropertyGIFDelayTime 可能为0  所以我觉得可以先判断kCGImagePropertyGIFDelayTime
     */
    CGFloat duration = 0.1;
    
    NSNumber *unclampedPropdelayTime = gifProperties[(__bridge NSString *)kCGImagePropertyGIFUnclampedDelayTime];
    NSNumber *delayTime = gifProperties[(__bridge NSString *)kCGImagePropertyGIFDelayTime];
    
    if (unclampedPropdelayTime) {
        duration = unclampedPropdelayTime.floatValue;
    }else{
        if (delayTime) {
            duration = delayTime.floatValue;
        }
    }
    
    CFRelease(frameProperties);
    
    return duration;
}


#pragma mark == 添加文字 截屏 擦除

+ (UIImage *)gl_addTitleAboveImage:(UIImage *)image addTitleText:(NSString *)text
                   attributeDic:(NSDictionary *)attributeDic point:(CGPoint)point
{
    UIGraphicsBeginImageContextWithOptions(image.size, NO, [UIScreen mainScreen].scale);
    
    CGRect imageRect = CGRectMake(0, 0, image.size.width, image.size.height);
    
    [image drawInRect:imageRect];
    
    [text drawAtPoint:point withAttributes:attributeDic];
    
    //获取上下文中的新图片
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return newImage;
}

+ (UIImage *)gl_addAboveImage:(UIImage *)image addImage:(UIImage *)addImage rect:(CGRect)rect
{
    UIGraphicsBeginImageContextWithOptions(image.size, NO, [UIScreen mainScreen].scale);
    
    CGRect imageRect = CGRectMake(0, 0, image.size.width, image.size.height);
    
    [image drawInRect:imageRect];
    
    [addImage drawInRect:rect];
    
    //获取上下文中的新图片
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return newImage;
}

+ (UIImage *)gl_snapScreenView:(UIView *)view
{
    //开启上下文
    UIGraphicsBeginImageContext(view.bounds.size);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    //渲染图片
    [view.layer renderInContext:context];
    //得到新图片
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    //避免内存泄漏
    view.layer.contents = nil;
    
    return newImage;
}

+ (UIImage *)gl_wipeImageWithView:(UIView *)view movePoint:(CGPoint)point brushSize:(CGSize)size
{
    //开启上下文
    UIGraphicsBeginImageContext(view.bounds.size);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    //此方法不能渲染图片 只针对layer
    //[view.layer drawInContext:context];
    
    //以point为中心，然后size的一半向两边延伸  坐画笔  橡皮擦
    CGRect clearRect = CGRectMake(point.x - size.width/2.0, point.y - size.width/2.0, size.width, size.height);
    
    //渲染图片
    [view.layer renderInContext:context];
    //清除该区域
    CGContextClearRect(context, clearRect);
    //得到新图片
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();

    UIGraphicsEndImageContext();
    //避免内存泄漏
    view.layer.contents = nil;
    
    return newImage;
}

+ (UIImage *)gl_groupHeadPortraitWithContents:(NSArray *)contents size:(CGSize)size
{
    NSAssert(contents.count <=4 && contents.count >0, @"contents can not be empty array");
    switch (contents.count) {
        case 1:
        {
            if ([contents[0] isKindOfClass:[UIImage class]]) {
                return [self gl_circleImage:(UIImage *)contents[0]];
            }else if ([contents[0] isKindOfClass:[NSAttributedString class]]){
                return [self gl_creatImageWithString:contents[0] imageSize:size imageColor:[UIColor grayColor]];
            }
        }
            break;
        case 2:
        {
            //通过自己创建一个context来绘制，通常用于对图片的处理
            UIGraphicsBeginImageContextWithOptions(size, NO, [UIScreen mainScreen].scale);
            //获取上下文
            CGContextRef context = UIGraphicsGetCurrentContext();


            CGFloat radius = size.width/2.0 - 1;
            CGPoint center = CGPointMake(size.width/2.0 - 1, size.height/2.0);
            UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:center radius:radius startAngle:M_PI_2 endAngle:M_PI +  M_PI_2 clockwise:YES];
            [path addLineToPoint:center];
            
            CGPoint center_n = CGPointMake(size.width/2.0 + 1, size.height/2.0);
            UIBezierPath *path_n = [UIBezierPath bezierPathWithArcCenter:center_n radius:radius startAngle:M_PI + M_PI_2 endAngle:2 * M_PI + M_PI_2 clockwise:YES];
            [path_n addLineToPoint:center_n];
            
            if ([contents[0] isKindOfClass:[UIImage class]]) {
                CGContextAddPath(context, path.CGPath);
                
            }else{
                CGContextSetFillColorWithColor(context, [UIColor redColor].CGColor);
                CGContextAddPath(context, path.CGPath);
                
                CGContextFillPath(context);
                
                NSAttributedString *string = (NSAttributedString*)contents[0];
                CGSize stringSize = [string size];
                CGFloat x = (path.bounds.size.width - stringSize.width)/2.0;
                CGFloat y = (path.bounds.size.height - stringSize.height)/2.0;
                
                [string drawInRect:CGRectMake(x, y, stringSize.width, stringSize.height)];
            }
            
            if ([contents[1] isKindOfClass:[UIImage class]]) {
                CGContextAddPath(context, path_n.CGPath);
            }else{
                CGContextSetFillColorWithColor(context, [UIColor orangeColor].CGColor);
                CGContextAddPath(context, path_n.CGPath);
                
                CGContextFillPath(context);
                
                NSAttributedString *string = (NSAttributedString*)contents[1];
                CGSize stringSize = [string size];
                CGFloat x = path_n.currentPoint.x + (path_n.bounds.size.width - stringSize.width)/2.0;
                CGFloat y = (path_n.bounds.size.height - stringSize.height)/2.0;
                
                [string drawInRect:CGRectMake(x, y, stringSize.width, stringSize.height)];
                
                //图片在前的时候 文字在后 路径被清了 导致后面的clip剪切不了路径
                CGContextAddPath(context, path.CGPath);
            }
            
            CGContextClip(context);
            
            if ([contents[0] isKindOfClass:[UIImage class]]) {
                UIImage *img = (UIImage *)contents[0];
                [img drawInRect:path.bounds];
            }
            if ([contents[1] isKindOfClass:[UIImage class]]) {
                UIImage *img = (UIImage *)contents[1];
                [img drawInRect:path_n.bounds];
            }
            UIImage *newimg = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            return newimg;
        }
            break;
        case 3:
        {
            //通过自己创建一个context来绘制，通常用于对图片的处理
            UIGraphicsBeginImageContextWithOptions(size, NO, [UIScreen mainScreen].scale);
            //获取上下文
            CGContextRef context = UIGraphicsGetCurrentContext();
            
            //先确定三个路径
            CGFloat radius = size.width/2.0 - 1;
            CGPoint center = CGPointMake(size.width/2.0 - 1, size.height/2.0);
            UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:center radius:radius startAngle:M_PI_2 endAngle:M_PI +  M_PI_2 clockwise:YES];
            [path addLineToPoint:center];
            
            CGPoint center_s = CGPointMake(size.width/2.0 + 1, size.height/2.0 - 1);
            UIBezierPath *path_s = [UIBezierPath bezierPathWithArcCenter:center_s radius:radius-1 startAngle:M_PI + M_PI_2 endAngle:2 * M_PI clockwise:YES];
            [path_s addLineToPoint:center_s];
            
            
            CGPoint center_t = CGPointMake(size.width/2.0 + 1, size.height/2.0 + 1);
            UIBezierPath *path_t = [UIBezierPath bezierPathWithArcCenter:center_t radius:radius-1 startAngle:2 * M_PI endAngle:2 * M_PI + M_PI_2 clockwise:YES];
            [path_t addLineToPoint:center_t];
            
            NSMutableArray *imageArray = [[NSMutableArray alloc] init];
            NSMutableArray *titleArray = [[NSMutableArray alloc] init];
            for (id object in contents) {
                if ([object isKindOfClass:[UIImage class]]) {
                    [imageArray addObject:object];
                }else{
                    [titleArray addObject:object];
                }
            }
            
            if (imageArray.count == 3) {
                //全部为图片
                CGContextAddPath(context, path.CGPath);
                CGContextAddPath(context, path_s.CGPath);
                CGContextAddPath(context, path_t.CGPath);
                
                CGContextClip(context);
 
                UIImage *img0 = (UIImage *)imageArray[0];
                UIImage *img1 = (UIImage *)imageArray[1];
                UIImage *img2 = (UIImage *)imageArray[2];
                
                [img0 drawInRect:path.bounds];
                [img1 drawInRect:path_s.bounds];
                [img2 drawInRect:path_t.bounds];
            }else if (imageArray.count == 2){
                //文字1
                CGContextSetFillColorWithColor(context, [UIColor orangeColor].CGColor);
                CGContextAddPath(context, path_t.CGPath);
                CGContextFillPath(context);
                
                NSAttributedString *string = (NSAttributedString*)titleArray[0];
                CGSize stringSize = [string size];
                CGFloat x = path_t.currentPoint.x + (path_t.bounds.size.width - stringSize.width)/2.0;
                CGFloat y = path_t.currentPoint.y + (path_t.bounds.size.height - stringSize.height)/2.0;
                
                [string drawInRect:CGRectMake(x, y, stringSize.width, stringSize.height)];
                
                //图片1 图片2
                CGContextAddPath(context, path.CGPath);
                CGContextAddPath(context, path_s.CGPath);
                CGContextClip(context);
                
                UIImage *img0 = (UIImage *)imageArray[0];
                UIImage *img1 = (UIImage *)imageArray[1];
                [img0 drawInRect:path.bounds];
                [img1 drawInRect:path_s.bounds];

            }else if (imageArray.count == 1){
                
                //文字1
                CGContextSetFillColorWithColor(context, [UIColor orangeColor].CGColor);
                CGContextAddPath(context, path_t.CGPath);
                CGContextFillPath(context);
                
                NSAttributedString *string = (NSAttributedString*)titleArray[0];
                CGSize stringSize = [string size];
                CGFloat x = path_t.currentPoint.x + (path_t.bounds.size.width - stringSize.width)/2.0;
                CGFloat y = path_t.currentPoint.y + (path_t.bounds.size.height - stringSize.height)/2.0;
                
                [string drawInRect:CGRectMake(x, y, stringSize.width, stringSize.height)];
                
                
                //文字2
                CGContextSetFillColorWithColor(context, [UIColor purpleColor].CGColor);
                CGContextAddPath(context, path_s.CGPath);
                CGContextFillPath(context);
                
                NSAttributedString *string_s = (NSAttributedString*)titleArray[1];
                CGSize stringSize_s = [string_s size];
                CGFloat x_s = path_s.currentPoint.x + (path_s.bounds.size.width - stringSize_s.width)/2.0;
                CGFloat y_s = (path_s.bounds.size.height - stringSize_s.height)/2.0;
                
                [string_s drawInRect:CGRectMake(x_s, y_s, stringSize_s.width, stringSize_s.height)];
                
                //图片
                CGContextAddPath(context, path.CGPath);
                CGContextClip(context);
                UIImage *img0 = (UIImage *)imageArray[0];
                [img0 drawInRect:path.bounds];
                
            }else{
                for (int i = 0; i < titleArray.count; i ++) {
                    UIColor *color;
                    UIBezierPath *drawPath;
                    
                    NSAttributedString *string_s = (NSAttributedString*)titleArray[i];
                    CGSize stringSize_s = [string_s size];
                    CGFloat x_s = 0;
                    CGFloat y_s = 0;
                    if (i == 0) {
                        color = [UIColor greenColor];
                        drawPath = path;
                        x_s = (drawPath.bounds.size.width - stringSize_s.width)/2.0;
                        y_s = (drawPath.bounds.size.height - stringSize_s.height)/2.0;
                    }else if(i == 1){
                        color = [UIColor purpleColor];
                        drawPath = path_s;
                        x_s = drawPath.currentPoint.x + (drawPath.bounds.size.width - stringSize_s.width)/2.0;
                        y_s = (drawPath.bounds.size.height - stringSize_s.height)/2.0;
                    }else{
                        color = [UIColor redColor];
                        drawPath = path_t;
                        
                        x_s = drawPath.currentPoint.x + (drawPath.bounds.size.width - stringSize_s.width)/2.0;
                        y_s = drawPath.currentPoint.y + (drawPath.bounds.size.height - stringSize_s.height)/2.0;
                    }
                    
                    CGContextSetFillColorWithColor(context, color.CGColor);
                    CGContextAddPath(context, drawPath.CGPath);
                    CGContextFillPath(context);
                    
                
                    
                    [string_s drawInRect:CGRectMake(x_s, y_s, stringSize_s.width, stringSize_s.height)];
                }
            }
            
            UIImage *newimg = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            return newimg;
        }
            break;
        case 4:
        {
            CGSize imageSize = size;
            //通过自己创建一个context来绘制，通常用于对图片的处理
            UIGraphicsBeginImageContextWithOptions(imageSize, NO, [UIScreen mainScreen].scale);
            //获取上下文
            CGContextRef context = UIGraphicsGetCurrentContext();
            
            CGFloat radius = size.width/2.0 - 1;
            CGPoint center = CGPointMake(imageSize.width/2.0 + 1, imageSize.height/2.0 + 1);
            
            //路径
            UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(imageSize.width/2.0 - 1, imageSize.height/2.0 - 1) radius:radius startAngle:M_PI endAngle:M_PI + M_PI_2 clockwise:YES];
            [path addLineToPoint:CGPointMake(imageSize.width/2.0 - 1, imageSize.height/2.0 - 1)];
            
            //路径1
            UIBezierPath *path1 = [UIBezierPath bezierPathWithArcCenter:CGPointMake(imageSize.width/2.0 + 1, imageSize.height/2.0 - 1) radius:radius startAngle:M_PI + M_PI_2 endAngle:2*M_PI clockwise:YES];
            [path1 addLineToPoint:CGPointMake(imageSize.width/2.0 + 1, imageSize.height/2.0 - 1)];
            
            //路径2
            UIBezierPath *path2 = [UIBezierPath bezierPathWithArcCenter:center radius:radius startAngle:0 endAngle:M_PI_2 clockwise:YES];
            [path2 addLineToPoint:center];
            
            //路径3
            UIBezierPath *path3 = [UIBezierPath bezierPathWithArcCenter:CGPointMake(center.x-2, center.y) radius:radius startAngle:M_PI_2 endAngle:M_PI clockwise:YES];
            [path3 addLineToPoint:CGPointMake(center.x-2, center.y)];

            

            


            
            NSMutableArray *imageArray = [[NSMutableArray alloc] init];
            NSMutableArray *titleArray = [[NSMutableArray alloc] init];
            for (id object in contents) {
                if ([object isKindOfClass:[UIImage class]]) {
                    [imageArray addObject:object];
                }else{
                    [titleArray addObject:object];
                }
            }
            
            if (imageArray.count == 4) {
                //图片
                CGContextAddPath(context, path.CGPath);
                CGContextAddPath(context, path1.CGPath);
                CGContextAddPath(context, path2.CGPath);
                CGContextAddPath(context, path3.CGPath);
                CGContextClip(context);
                
                UIImage *img0 = (UIImage *)imageArray[0];
                UIImage *img1 = (UIImage *)imageArray[1];
                UIImage *img2 = (UIImage *)imageArray[2];
                UIImage *img3 = (UIImage *)imageArray[3];
                [img0 drawInRect:path.bounds];
                [img1 drawInRect:path1.bounds];
                [img2 drawInRect:path2.bounds];
                [img3 drawInRect:path3.bounds];
            }else if (imageArray.count == 3){
                for (int i = 0; i < titleArray.count; i ++) {
                    UIColor *color;
                    UIBezierPath *drawPath;
                    
                    NSAttributedString *string_s = (NSAttributedString*)titleArray[i];
                    CGSize stringSize_s = [string_s size];
                    CGFloat x_s = 0;
                    CGFloat y_s = 0;
                    if (i == 0) {
                        color = [UIColor redColor];
                        drawPath = path3;
                        
                        x_s = (drawPath.bounds.size.width - stringSize_s.width)/2.0;
                        y_s = drawPath.currentPoint.y + (drawPath.bounds.size.height - stringSize_s.height)/2.0;
                    }
                    CGContextSetFillColorWithColor(context, color.CGColor);
                    CGContextAddPath(context, drawPath.CGPath);
                    CGContextFillPath(context);
                    
                    [string_s drawInRect:CGRectMake(x_s, y_s, stringSize_s.width, stringSize_s.height)];
                }
                
                CGContextAddPath(context, path.CGPath);
                CGContextAddPath(context, path1.CGPath);
                CGContextAddPath(context, path2.CGPath);
                CGContextClip(context);
                
                UIImage *img0 = (UIImage *)imageArray[0];
                UIImage *img1 = (UIImage *)imageArray[1];
                UIImage *img2 = (UIImage *)imageArray[2];
                [img0 drawInRect:path.bounds];
                [img1 drawInRect:path1.bounds];
                [img2 drawInRect:path2.bounds];
                
            }else if (imageArray.count == 2){
                for (int i = 0; i < titleArray.count; i ++) {
                    UIColor *color;
                    UIBezierPath *drawPath;
                    
                    NSAttributedString *string_s = (NSAttributedString*)titleArray[i];
                    CGSize stringSize_s = [string_s size];
                    CGFloat x_s = 0;
                    CGFloat y_s = 0;
                    if(i == 1){
                        color = [UIColor purpleColor];
                        drawPath = path2;
                        x_s = drawPath.currentPoint.x + (drawPath.bounds.size.width - stringSize_s.width)/2.0;
                        y_s = drawPath.currentPoint.y + (drawPath.bounds.size.height - stringSize_s.height)/2.0;
                    }else{
                        color = [UIColor redColor];
                        drawPath = path3;
                        
                        x_s = (drawPath.bounds.size.width - stringSize_s.width)/2.0;
                        y_s = drawPath.currentPoint.y + (drawPath.bounds.size.height - stringSize_s.height)/2.0;
                    }
                    
                    CGContextSetFillColorWithColor(context, color.CGColor);
                    CGContextAddPath(context, drawPath.CGPath);
                    CGContextFillPath(context);
                    
                    [string_s drawInRect:CGRectMake(x_s, y_s, stringSize_s.width, stringSize_s.height)];
                }

                
                CGContextAddPath(context, path.CGPath);
                CGContextAddPath(context, path1.CGPath);
                CGContextClip(context);
                
                UIImage *img0 = (UIImage *)imageArray[0];
                UIImage *img1 = (UIImage *)imageArray[1];
                [img0 drawInRect:path.bounds];
                [img1 drawInRect:path1.bounds];
                
            }else if (imageArray.count == 1){
                
                for (int i = 0; i < titleArray.count; i ++) {
                    UIColor *color;
                    UIBezierPath *drawPath;
                    
                    NSAttributedString *string_s = (NSAttributedString*)titleArray[i];
                    CGSize stringSize_s = [string_s size];
                    CGFloat x_s = 0;
                    CGFloat y_s = 0;
                    if(i == 0){
                        color = [UIColor orangeColor];
                        drawPath = path1;
                        x_s = drawPath.currentPoint.x + (drawPath.bounds.size.width - stringSize_s.width)/2.0;
                        y_s = (drawPath.bounds.size.height - stringSize_s.height)/2.0;
                    }else if(i == 1){
                        color = [UIColor purpleColor];
                        drawPath = path2;
                        x_s = drawPath.currentPoint.x + (drawPath.bounds.size.width - stringSize_s.width)/2.0;
                        y_s = drawPath.currentPoint.y + (drawPath.bounds.size.height - stringSize_s.height)/2.0;
                    }else{
                        color = [UIColor redColor];
                        drawPath = path3;
                        
                        x_s = (drawPath.bounds.size.width - stringSize_s.width)/2.0;
                        y_s = drawPath.currentPoint.y + (drawPath.bounds.size.height - stringSize_s.height)/2.0;
                    }
                    
                    CGContextSetFillColorWithColor(context, color.CGColor);
                    CGContextAddPath(context, drawPath.CGPath);
                    CGContextFillPath(context);
                    
                    [string_s drawInRect:CGRectMake(x_s, y_s, stringSize_s.width, stringSize_s.height)];
                }
                
                CGContextAddPath(context, path.CGPath);
                CGContextClip(context);
                
                UIImage *img0 = (UIImage *)imageArray[0];
                [img0 drawInRect:path.bounds];
            }else{
                for (int i = 0; i < titleArray.count; i ++) {
                    UIColor *color;
                    UIBezierPath *drawPath;
                    
                    NSAttributedString *string_s = (NSAttributedString*)titleArray[i];
                    CGSize stringSize_s = [string_s size];
                    CGFloat x_s = 0;
                    CGFloat y_s = 0;
                    if (i == 0) {
                        color = [UIColor greenColor];
                        drawPath = path;
                        x_s = (drawPath.bounds.size.width - stringSize_s.width)/2.0;
                        y_s = (drawPath.bounds.size.height - stringSize_s.height)/2.0;
                    }else if(i == 1){
                        color = [UIColor orangeColor];
                        drawPath = path1;
                        x_s = drawPath.currentPoint.x + (drawPath.bounds.size.width - stringSize_s.width)/2.0;
                        y_s = (drawPath.bounds.size.height - stringSize_s.height)/2.0;
                    }else if(i == 2){
                        color = [UIColor purpleColor];
                        drawPath = path2;
                        x_s = drawPath.currentPoint.x + (drawPath.bounds.size.width - stringSize_s.width)/2.0;
                        y_s = drawPath.currentPoint.y + (drawPath.bounds.size.height - stringSize_s.height)/2.0;
                    }else{
                        color = [UIColor redColor];
                        drawPath = path3;
                        
                        x_s = (drawPath.bounds.size.width - stringSize_s.width)/2.0;
                        y_s = drawPath.currentPoint.y + (drawPath.bounds.size.height - stringSize_s.height)/2.0;
                    }
                    
                    CGContextSetFillColorWithColor(context, color.CGColor);
                    CGContextAddPath(context, drawPath.CGPath);
                    CGContextFillPath(context);

                    [string_s drawInRect:CGRectMake(x_s, y_s, stringSize_s.width, stringSize_s.height)];
                }
            }
            UIImage *newimg = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            return newimg;
        }
            break;
        default:
            break;
    }
    return nil;
}


+ (UIImage *)gl_creatImageWithString:(NSAttributedString *)string imageSize:(CGSize)imageSize imageColor:(UIColor *)imageColor
{
    //通过自己创建一个context来绘制，通常用于对图片的处理
    UIGraphicsBeginImageContextWithOptions(imageSize, NO, [UIScreen mainScreen].scale);
    //获取上下文
    CGContextRef context = UIGraphicsGetCurrentContext();
    //设置填充颜色
    CGContextSetFillColorWithColor(context, imageColor.CGColor);
    //直接按rect的范围覆盖
    CGContextAddEllipseInRect(context, CGRectMake(0, 0, imageSize.width, imageSize.height));
    CGContextFillPath(context);

    CGSize stringSize = [string size];
    CGFloat x = (imageSize.width - stringSize.width)/2.0;
    CGFloat y = (imageSize.height - stringSize.height)/2.0;
    
    [string drawInRect:CGRectMake(x, y, stringSize.width, stringSize.height)];
    
    UIImage *newimg = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newimg;
}

@end
