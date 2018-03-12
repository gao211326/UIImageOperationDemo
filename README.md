>碧玉妆成一树高，万条垂下绿丝绦。
不知细叶谁裁出，二月春风似剪刀

##### 前言
岁月无情，转眼间年已过完，本打算在年前写一篇视频编辑处理方面的文章，奈何时间...旧事未完，新事又来，在最近的项目中，需要实现如下图中的效果
![xiaoguo.png](https://upload-images.jianshu.io/upload_images/2525768-1997c72e041633fc.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
由于时间紧迫，本打算找个现成的..居然没找到，好吧！那就自己动手，丰衣足食吧。

##### 思路
由于服务器只返回图片或者人员名字，所以想全部通过图片来拼接的方式不可行，为了性能，就采取了`Quartz 2D`中`CGContextRef`的方式来进行绘制。最开始我的思路是先绘制一个大圆圈，然后再绘制几条白色的线条，来实现目标，但是问题来了，就是文字的背景颜色，于是放弃该方案，最终选择通过返回的数据的个数来绘制不同的弧面（最多4个），在绘制弧面的时候，让弧度之间的空白处作为白色线条。

##### first
在思路确定好后，就准备开始动手进行敲键盘了，为了先试试效果，先写了一个纯文字来绘制图片的`API`，如下
```
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
```
来，看看效果
![wenzi.jpeg](https://upload-images.jianshu.io/upload_images/2525768-359d0fd147286843.jpeg?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
恩！感觉不错，心里一阵窃喜！这里入参为`NSAttributedString `变量类型，方便自己设置大小颜色等效果

##### second
绘制圆形图片，这个在之前的文章中已经实现该功能，所以就节省了步骤，代码如下
```
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

```

怀抱激动的心情，于是写下了如下代码
```
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
            
            
            CGContextAddPath(context, path_n.CGPath);
            
            CGContextSetFillColorWithColor(context, [UIColor redColor].CGColor);
            CGContextAddPath(context, path.CGPath);
            
            CGContextFillPath(context);
            
            NSAttributedString *string = (NSAttributedString*)contents[0];
            CGSize stringSize = [string size];
            CGFloat x = (path.bounds.size.width - stringSize.width)/2.0;
            CGFloat y = (path.bounds.size.height - stringSize.height)/2.0;
            
            [string drawInRect:CGRectMake(x, y, stringSize.width, stringSize.height)];

            
            CGContextClip(context);

            if ([contents[1] isKindOfClass:[UIImage class]]) {
                UIImage *img = (UIImage *)contents[1];
                [img drawInRect:path_n.bounds];
            }
            UIImage *newimg = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            return newimg;
```
然而在运行的那一刻，瞬间泪崩
![Simulator Screen Shot - iPhone X - 2018-03-12 at 16.39.34.png](https://upload-images.jianshu.io/upload_images/2525768-8cca5a462ffc35dc.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
什么鬼，不是说好的半圆么....这个问题让我真是苦恼，仔细检查代码，发现没啥问题呀，路径也是半圆的路径，正在一筹莫展的时候，突然在网上看到一个问题`CGContextStrokePath, CGContextFillPath, CGContextEOFillPath, CGContext- DrawPath. 描边或者填充操作都会清除这个路径`，清除路径，也就是说当我执行`CGContextClip`的时候，路径已经不在了，所以我想要的半圆也就没了。看到这，我立刻改了下代码，如下
```
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
            
            
            CGContextSetFillColorWithColor(context, [UIColor redColor].CGColor);
            CGContextAddPath(context, path.CGPath);
            
            CGContextFillPath(context);
            
            NSAttributedString *string = (NSAttributedString*)contents[0];
            CGSize stringSize = [string size];
            CGFloat x = (path.bounds.size.width - stringSize.width)/2.0;
            CGFloat y = (path.bounds.size.height - stringSize.height)/2.0;
            
            [string drawInRect:CGRectMake(x, y, stringSize.width, stringSize.height)];

            CGContextAddPath(context, path_n.CGPath);
            
            CGContextClip(context);

            if ([contents[1] isKindOfClass:[UIImage class]]) {
                UIImage *img = (UIImage *)contents[1];
                [img drawInRect:path_n.bounds];
            }
            UIImage *newimg = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            return newimg;
```
将`CGContextAddPath(context, path_n.CGPath);`添加半圆的路径移动到`CGContextFillPath(context);`后面`CGContextClip(context);
`前面，再一执行，瞬间效果就对了
![Simulator Screen Shot - iPhone X - 2018-03-12 at 16.39.54.png](https://upload-images.jianshu.io/upload_images/2525768-77f6a4326edd9f22.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

##### last
在上面的问题都解决好之后，剩余的问题就都不是问题了，就是一些简单逻辑和坐标的计算，代码如下
```
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
```
由于时间关系，代码比较长，中间文字的绘制的坐标稍微有点偏，算的上是我目前为止封装的比较长的`API`了，各位看官得耐心了，多多包涵~
下面还是看看效果图
![four.png](https://upload-images.jianshu.io/upload_images/2525768-5393329b90f0a719.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
![three](https://upload-images.jianshu.io/upload_images/2525768-966756d9cc1d7830.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

