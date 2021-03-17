//
//  UIImage+JGSBase.m
//  JGSourceBase
//
//  Created by 梅继高 on 2021/3/6.
//

#import "UIImage+JGSBase.h"
#import "JGSBase.h"

@implementation UIImage (JGSBase)

#pragma mark - Color
+ (instancetype)jg_imageWithColor:(UIColor *)color {
    return [self jg_imageWithColor:color size:CGSizeMake(1, 1)];
}

+ (instancetype)jg_imageWithColor:(UIColor *)color size:(CGSize)size {
    
    CGFloat width = MAX(1, size.width);
    CGFloat height = MAX(1, size.height);
    CGRect rect = CGRectMake(0, 0, width, height);
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, [UIScreen mainScreen].scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return [img resizableImageWithCapInsets:UIEdgeInsetsMake(height * 0.5, width * 0.5, height * 0.5, width * 0.5) resizingMode:UIImageResizingModeStretch];
}

#pragma mark - Modify
- (instancetype)jg_imageByApplingColor:(UIColor *)color {
    
    UIGraphicsBeginImageContextWithOptions(self.size, NO, self.scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(context, 0, self.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    CGContextSetBlendMode(context, kCGBlendModeNormal);
    
    CGRect rect = CGRectMake(0, 0, self.size.width, self.size.height);
    CGContextClipToMask(context, rect, self.CGImage);
    [color setFill];
    CGContextFillRect(context, rect);
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

- (instancetype)jg_imageByApplyingAlpha:(CGFloat)alpha {
    
    UIGraphicsBeginImageContextWithOptions(self.size, NO, 0.0f);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGRect area = CGRectMake(0, 0, self.size.width, self.size.height);
    CGContextScaleCTM(ctx, 1, -1);
    CGContextTranslateCTM(ctx, 0, -area.size.height);
    CGContextSetBlendMode(ctx, kCGBlendModeMultiply);
    CGContextSetAlpha(ctx, alpha);
    CGContextDrawImage(ctx, area, self.CGImage);
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

- (instancetype)jg_imageCorrectedOrientation {
    return [self jg_imageCorrectedOrientation:UIImageOrientationUp];
}

- (instancetype)jg_imageCorrectedOrientation:(UIImageOrientation)imageOrientation {
    return [UIImage imageWithCGImage:self.CGImage scale:self.scale orientation:imageOrientation];
}

#pragma mark - Resize
- (instancetype)jg_centerResizeImage {
    
    CGSize size = [self size];
    CGFloat resizeX = (size.width - 0) * 0.5;
    CGFloat resizeY = (size.height - 0) * 0.5;
    UIEdgeInsets inset = UIEdgeInsetsMake(resizeY, resizeX, resizeY, resizeX);
    
    return [self resizableImageWithCapInsets:inset];
}

- (instancetype)jg_stretchImageWithLeftCap:(CGFloat)left topCap:(CGFloat)top {
    
    CGSize size = [self size];
    CGFloat right = size.width - left - 1;
    CGFloat bottom = size.height - top - 1;
    UIEdgeInsets inset = UIEdgeInsetsMake(top, left, bottom, right);
    
    return [self resizableImageWithCapInsets:inset];
}

- (instancetype)jg_tileImage {
    return [self resizableImageWithCapInsets:UIEdgeInsetsZero resizingMode:UIImageResizingModeTile];
}

- (instancetype)jg_imageScaleAspectFit:(CGSize)targetSize {
    return [self jg_imageScaleWithCropping:NO size:targetSize];
}

- (instancetype)jg_imageScaleAspectFill:(CGSize)targetSize {
    return [self jg_imageScaleWithCropping:YES size:targetSize];
}

- (instancetype)jg_imageScaleWithCropping:(BOOL)cropping size:(CGSize)targetSize {
    
    CGSize imageSize = self.size;
    CGSize scaleSize = targetSize;
    CGPoint thumbnailPoint = CGPointMake(0.0, 0.0);
    
    if (CGSizeEqualToSize(imageSize, targetSize) == NO) {
        
        CGFloat scaleFactor = 1.0;
        CGFloat widthFactor = targetSize.width / imageSize.width;
        CGFloat heightFactor = targetSize.height / imageSize.height;
        if (widthFactor > heightFactor) {
            scaleFactor = cropping ? widthFactor : heightFactor;
        } else {
            scaleFactor = cropping ? heightFactor : widthFactor;
        }
        
        scaleSize = CGSizeMake(imageSize.width * scaleFactor, imageSize.height * scaleFactor);
        
        // center the image
        thumbnailPoint = CGPointMake((targetSize.width - scaleSize.width) * 0.5, (targetSize.height - scaleSize.height) * 0.5);
    }
    
    UIGraphicsBeginImageContext(targetSize);
    CGRect drawRect = CGRectMake(thumbnailPoint.x, thumbnailPoint.y, scaleSize.width, scaleSize.height);
    [self drawInRect:drawRect];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    if (newImage == nil) {
        JGSLog(@"could not scale image");
    }
    
    return newImage;
}

#pragma mark - Compress
- (UIImage *)jg_imageWithScale:(CGFloat)scale {
    
    if (scale == 1.0 || scale <= 0) {
        return self;
    }
    
    CGFloat newWidth = self.size.width * scale;
    CGFloat newHeight = self.size.height * scale;
    
    CGRect clipRect = CGRectMake(0, 0, newWidth, newHeight);
    
    UIGraphicsBeginImageContextWithOptions(clipRect.size, NO, [UIScreen mainScreen].scale);
    [self drawInRect:clipRect];
    UIImage *newImg = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImg;
}

- (NSData *)jg_compressSizeAndQualityDataWithExpectKBSize:(NSInteger)kb {
    return [self jg_compressSizeAndQualityDataWithExpectKBSize:kb minQuality:0];
}

- (NSData *)jg_compressSizeAndQualityDataWithExpectKBSize:(NSInteger)kb minQuality:(CGFloat)minQuality {
    
    if (minQuality <= 0) {
        minQuality = 0.4;
    }
    else if (minQuality > 1) {
        minQuality = 0.8;
    }
    
    @autoreleasepool {
        
        CGFloat kbToB = 1000.f;
        CGFloat delta = 0.099;
        
        UIImage *newImage = [UIImage imageWithCGImage:self.CGImage scale:self.scale orientation:self.imageOrientation];
        if ([UIImageJPEGRepresentation(newImage, 1.f) length] <= kb * kbToB) {
            JGSLog();
            return UIImageJPEGRepresentation(newImage, 1.f);
        }
        
        CGFloat imgWHScale = newImage.size.width / newImage.size.height;
        if (imgWHScale > 16.0 / 9.0 || imgWHScale < 9.0 / 16.0) {
            
            // 长横图、长竖图，限制图片最小宽或高
            CGFloat minWh = 720.f;
            if (imgWHScale > 4.0 / 1.0 || imgWHScale < 1.0 / 4.0) {
                
                minWh = 480.f;
            }
            else if (imgWHScale > 3.0 / 1.0 || imgWHScale < 1.0 / 3.0) {
                
                minWh = 540.f;
            }
            
            if (MIN(newImage.size.width, newImage.size.height) > minWh) {
                
                CGFloat scale = minWh / MIN(newImage.size.width, newImage.size.height);
                newImage = [self jg_imageWithScale:scale];
                JGSLog(@"%f", scale);
            }
        }
        else {
            
            // 16:9 范围图，限制图片最大宽或高
            CGFloat maxWh = 1280.f;
            if (MAX(newImage.size.width, newImage.size.height) > maxWh) {
                
                CGFloat scale = maxWh / MAX(newImage.size.width, newImage.size.height);
                newImage = [self jg_imageWithScale:scale];
                JGSLog(@"%f", scale);
            }
        }
        
        //图片大小压缩
        CGFloat scale = 1.f;
        NSData *imageData = UIImageJPEGRepresentation(newImage, minQuality);
        while ([imageData length] > kb * kbToB) {
            
            scale -= delta;
            newImage = [newImage jg_imageWithScale:scale];
            imageData = UIImageJPEGRepresentation(newImage, minQuality);
            JGSLog(@"%f", scale);
        }
        
        //图片质量压缩，起始压缩比例
        CGFloat quality = 0.9f;
        CGFloat deltaIncrease = delta * 0.1;
        imageData = UIImageJPEGRepresentation(newImage, quality);
        while ([imageData length] > kb * kbToB) {
            
            JGSLog(@"%f, %zd", quality, [imageData length]);
            NSInteger dataLen = [imageData length];
            quality -= (delta + deltaIncrease);
            deltaIncrease = deltaIncrease * (1 + delta * 0.01);
            imageData = UIImageJPEGRepresentation(newImage, quality);
            
            if (dataLen <= [imageData length] || quality <= 0) {
                
                //达到最小压缩比
                break;
            }
        }
        JGSLog(@"%f, %zd", quality, [imageData length]);
        
        return imageData;
    }
}

#pragma mark - End

@end
