//
//  UIImage+JGSBase.m
//  JGSourceBase
//
//  Created by 梅继高 on 2021/3/6.
//

#import "UIImage+JGSBase.h"
#import "JGSBase+JGSPrivate.h"
//#import <ImageIO/ImageIO.h>
#import <Accelerate/Accelerate.h>

CGFloat JGSDegreesToRadians(CGFloat degrees) { return degrees * M_PI / 180.f; }

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

- (UIImage *)jg_imageWithMask:(UIImage *)mask {
    
    CGImageRef maskRef = mask.CGImage;
    CGImageRef temp = CGImageMaskCreate(CGImageGetWidth(maskRef), CGImageGetHeight(maskRef), CGImageGetBitsPerComponent(maskRef), CGImageGetBitsPerPixel(maskRef), CGImageGetBytesPerRow(maskRef), CGImageGetDataProvider(maskRef), NULL, false);
    CGImageRef masked = CGImageCreateWithMask(self.CGImage, temp);
    UIImage *result = [UIImage imageWithCGImage:masked];
    CGImageRelease(temp);
    CGImageRelease(masked);
    
    return result;
}

- (UIImage *)jg_blurryImage:(CGFloat)radius {
    
    CGImageRef img = self.CGImage;
    vImage_Buffer inBuffer, outBuffer;
    void *inDataBuffer, *outDataBuffer;
    
    CGDataProviderRef inProvider = CGImageGetDataProvider(img);
    CFDataRef inBitmapData = CGDataProviderCopyData(inProvider);
    size_t bufferSize = CGImageGetBytesPerRow(img) * CGImageGetHeight(img);
    
    inDataBuffer = malloc(bufferSize);
    memcpy(inDataBuffer, (void *)CFDataGetBytePtr(inBitmapData), bufferSize);
    
    inBuffer.data = inDataBuffer;
    inBuffer.width = CGImageGetWidth(img);
    inBuffer.height = CGImageGetHeight(img);
    inBuffer.rowBytes = CGImageGetBytesPerRow(img);
    
    outDataBuffer = malloc(bufferSize);
    outBuffer.data = outDataBuffer;
    outBuffer.width = CGImageGetWidth(img);
    outBuffer.height = CGImageGetHeight(img);
    outBuffer.rowBytes = CGImageGetBytesPerRow(img);
    
    CGFloat inputRadius = radius * self.scale;
    if (inputRadius - 2. < __FLT_EPSILON__) {
        inputRadius = 2.;
    }
    uint32_t blurRadius = floor((inputRadius * 3. * sqrt(2 * M_PI) / 4 + 0.5) / 2);
    blurRadius |= 1; // force radius to be odd so that the three box-blur methodology works.
    
    NSInteger tempBufferSize = vImageBoxConvolve_ARGB8888(&inBuffer, &outBuffer, NULL, 0, 0, blurRadius, blurRadius, NULL, kvImageGetTempBufferSize | kvImageEdgeExtend);
    void *tempBuffer = malloc(tempBufferSize);
    
    vImageBoxConvolve_ARGB8888(&inBuffer, &outBuffer, tempBuffer, 0, 0, blurRadius, blurRadius, NULL, kvImageEdgeExtend);
    vImageBoxConvolve_ARGB8888(&outBuffer, &inBuffer, tempBuffer, 0, 0, blurRadius, blurRadius, NULL, kvImageEdgeExtend);
    vImageBoxConvolve_ARGB8888(&inBuffer, &outBuffer, tempBuffer, 0, 0, blurRadius, blurRadius, NULL, kvImageEdgeExtend);
    
    free(tempBuffer);
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef ctx = CGBitmapContextCreate(outBuffer.data, outBuffer.width, outBuffer.height, 8, outBuffer.rowBytes, colorSpace, CGImageGetBitmapInfo(self.CGImage));
    CGImageRef imageRef = CGBitmapContextCreateImage(ctx);
    UIImage *returnImage = [UIImage imageWithCGImage:imageRef];
    
    //clean up
    CGContextRelease(ctx);
    CGColorSpaceRelease(colorSpace);
    
    free(inDataBuffer);
    free(outDataBuffer);
    CFRelease(inBitmapData);
    
    CGImageRelease(imageRef);
    
    return returnImage;
}

#pragma mark - Resize
- (instancetype)jg_imageCorrectedOrientation {
    return [self jg_imageCorrectedOrientation:UIImageOrientationUp];
}

- (instancetype)jg_imageCorrectedOrientation:(UIImageOrientation)imageOrientation {
    return [UIImage imageWithCGImage:self.CGImage scale:self.scale orientation:imageOrientation];
}

- (UIImage *)jg_rotateWithAngle:(CGFloat)angle {
    
    @autoreleasepool {
        // calculate the size of the rotated view's containing box for our drawing space
        // REV @ppg 这里可能被异步调用,然后崩溃, 非线程安全
        UIView *rotatedViewBox = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.size.width, self.size.height)];
        CGAffineTransform t = CGAffineTransformMakeRotation(JGSDegreesToRadians(angle));
        rotatedViewBox.transform = t;
        //处理旋转后精度问题，导致1个point的白边
        CGFloat w = rotatedViewBox.frame.size.width;
        CGFloat h = rotatedViewBox.frame.size.height;
        if (ABS((NSInteger)w - w) <= 0.001) {
            w = (NSInteger)w;
        }
        if (ABS((NSInteger)h - h) <= 0.001) {
            h = (NSInteger)h;
        }
        
        CGSize rotatedSize = CGSizeMake(w, h);
        
        // Create the bitmap context
        UIGraphicsBeginImageContext(rotatedSize);
        CGContextRef bitmap = UIGraphicsGetCurrentContext();
        
        // Move the origin to the middle of the image so we will rotate and scale around the center.
        CGContextTranslateCTM(bitmap, rotatedSize.width / 2, rotatedSize.height / 2);
        
        //   // Rotate the image context
        CGContextRotateCTM(bitmap, JGSDegreesToRadians(angle));
        
        // Now, draw the rotated/scaled image into the context
        CGContextScaleCTM(bitmap, 1.0, -1.0);
        CGContextDrawImage(bitmap, CGRectMake(-self.size.width / 2, -self.size.height / 2, self.size.width, self.size.height), self.CGImage);
        
        UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return newImage;
    }
}

#pragma mark - Crop
- (UIImage *)jg_cropImageWithRect:(CGRect)rect {
    
    CGImageRef imageRef = CGImageCreateWithImageInRect(self.CGImage, rect);
    UIImage *croppedImage = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    return croppedImage;
}

- (UIImage *)jg_cropImageWithInsets:(UIEdgeInsets)insets {
    
    CGRect rect = CGRectMake(insets.left, insets.top, self.size.width - insets.left - insets.right, self.size.height - insets.top - insets.bottom);
    return [self jg_cropImageWithRect:rect];
}

- (UIImage *)jg_cropImageWithScale:(CGFloat)scale {
    
    if (scale == 1.0f) {
        return self;
    }
    
    CGFloat zoomReciprocal = 1.0f / scale;
    CGPoint offsetPoint = CGPointMake(self.size.width * ((1.0f - zoomReciprocal) / 2.0f), self.size.height * ((1.0f - zoomReciprocal) / 2.0f));
    CGRect croppedRect = CGRectMake(offsetPoint.x, offsetPoint.y, self.size.width * zoomReciprocal, self.size.height * zoomReciprocal);
    CGImageRef croppedImageRef = CGImageCreateWithImageInRect(self.CGImage, croppedRect);
    UIImage *croppedImage = [[UIImage alloc] initWithCGImage:croppedImageRef scale:[self scale] orientation:[self imageOrientation]];
    CGImageRelease(croppedImageRef);
    
    return croppedImage;
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
        JGSPrivateLog(@"could not scale image");
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
            //JGSPrivateLog();
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
                //JGSPrivateLog(@"%f", scale);
            }
        }
        else {
            
            // 16:9 范围图，限制图片最大宽或高
            CGFloat maxWh = 1280.f;
            if (MAX(newImage.size.width, newImage.size.height) > maxWh) {
                
                CGFloat scale = maxWh / MAX(newImage.size.width, newImage.size.height);
                newImage = [self jg_imageWithScale:scale];
                //JGSPrivateLog(@"%f", scale);
            }
        }
        
        //图片大小压缩
        CGFloat scale = 1.f;
        NSData *imageData = UIImageJPEGRepresentation(newImage, minQuality);
        while ([imageData length] > kb * kbToB) {
            
            scale -= delta;
            newImage = [newImage jg_imageWithScale:scale];
            imageData = UIImageJPEGRepresentation(newImage, minQuality);
            //JGSPrivateLog(@"%f", scale);
        }
        
        //图片质量压缩，起始压缩比例
        CGFloat quality = 0.9f;
        CGFloat deltaIncrease = delta * 0.1;
        imageData = UIImageJPEGRepresentation(newImage, quality);
        while ([imageData length] > kb * kbToB) {
            
            //JGSPrivateLog(@"%f, %zd", quality, [imageData length]);
            NSInteger dataLen = [imageData length];
            quality -= (delta + deltaIncrease);
            deltaIncrease = deltaIncrease * (1 + delta * 0.01);
            imageData = UIImageJPEGRepresentation(newImage, quality);
            
            if (dataLen <= [imageData length] || quality <= 0) {
                
                //达到最小压缩比
                break;
            }
        }
        //JGSPrivateLog(@"%f, %zd", quality, [imageData length]);
        
        return imageData;
    }
}

+ (nullable instancetype)jg_imageWithPixelsData:(unsigned char *)pixelsData width:(CGFloat)width height:(CGFloat)height {
    
    CGColorSpaceRef space = CGColorSpaceCreateDeviceRGB();
    // REV @sp 最后一个参数可能有问题
    CGContextRef ctx = CGBitmapContextCreate(pixelsData, width, height, 8, width * 4, space, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    CGImageRef cgImg = CGBitmapContextCreateImage(ctx);
    CGContextRelease(ctx);
    CGColorSpaceRelease(space);
    UIImage *image = [[UIImage alloc] initWithCGImage:cgImg];
    CGImageRelease(cgImg);
    
    return image;
}

+ (nullable instancetype)jg_imageWithSampleBuffer:(CMSampleBufferRef)sampleBuffer {
    
    // Get a CMSampleBuffer's Core Video image buffer for the media data
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    // Lock the base address of the pixel buffer
    CVPixelBufferLockBaseAddress(imageBuffer, 0);
    
    // Get the number of bytes per row for the pixel buffer
    void *baseAddress = CVPixelBufferGetBaseAddress(imageBuffer);
    
    // Get the number of bytes per row for the pixel buffer
    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);
    // Get the pixel buffer width and height
    size_t width = CVPixelBufferGetWidth(imageBuffer);
    size_t height = CVPixelBufferGetHeight(imageBuffer);
    
    // Create a device-dependent RGB color space
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    // Create a bitmap graphics context with the sample buffer data
    CGContextRef context = CGBitmapContextCreate(baseAddress, width, height, 8, bytesPerRow, colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
    // Create a Quartz image from the pixel data in the bitmap graphics context
    CGImageRef quartzImage = CGBitmapContextCreateImage(context);
    // Unlock the pixel buffer
    CVPixelBufferUnlockBaseAddress(imageBuffer, 0);
    
    // Free up the context and color space
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    
    // Create an image object from the Quartz image
    UIImage *image = [UIImage imageWithCGImage:quartzImage];
    
    // Release the Quartz image
    CGImageRelease(quartzImage);
    
    return (image);
}

#pragma mark - 图像数据
- (unsigned char *)jg_pixelsData {
    
    CGFloat pixWidth = CGImageGetWidth(self.CGImage);
    CGFloat pixHeight = CGImageGetHeight(self.CGImage);
    unsigned char *orgPixel = malloc(pixWidth * pixHeight * 4);
    
    NSUInteger bytesPerPixel = 4;
    NSUInteger bytesPerRow = bytesPerPixel * pixWidth;
    NSUInteger bitsPerComponent = 8;
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    // REV @sp 最后一个参数可能有问题
    CGContextRef context = CGBitmapContextCreate(orgPixel, pixWidth, pixHeight, bitsPerComponent, bytesPerRow, colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    CGContextDrawImage(context, CGRectMake(0, 0, pixWidth, pixHeight), self.CGImage);
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    
    return orgPixel;
}

- (unsigned char *)jg_pixelsGrayData {
    
    unsigned char *orgPixel = [self jg_pixelsData];
    unsigned char *pIndex = orgPixel;
    size_t iWidth = CGImageGetWidth(self.CGImage);
    size_t iHeight = CGImageGetHeight(self.CGImage);
    // REV @hc 可以考虑用dispatch_apply并发来做
    for (int i = 0; i < iHeight; ++i) {
        for (int j = 0; j < iWidth; ++j) {
            unsigned char value = (pIndex[j * 4 + 0] + pIndex[j * 4 + 1] + pIndex[j * 4 + 2]) / 3.0f;
            pIndex[j * 4 + 0] = value;
            pIndex[j * 4 + 1] = value;
            pIndex[j * 4 + 2] = value;
        }
        pIndex += (iWidth * 4);
    }
    return orgPixel;
}

#pragma mark - End

@end
