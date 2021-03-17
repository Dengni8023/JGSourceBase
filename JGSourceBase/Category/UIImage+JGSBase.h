//
//  UIImage+JGSBase.h
//  JGSourceBase
//
//  Created by 梅继高 on 2021/3/6.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIImage (JGSBase)

#pragma mark - Color
+ (instancetype)jg_imageWithColor:(UIColor *)color;
+ (instancetype)jg_imageWithColor:(UIColor *)color size:(CGSize)size;

#pragma mark - Modify
/// 改变图片颜色
/// @param color 目标颜色
- (instancetype)jg_imageByApplingColor:(UIColor *)color;

/// 设置图片透明度
/// @param alpha 目标透明度
- (instancetype)jg_imageByApplyingAlpha:(CGFloat)alpha;

#pragma mark - Resize
/// 图片中线拉伸
- (instancetype)jg_centerResizeImage;

/// 图片拉伸
/// @param left 左侧Inset
/// @param top 顶部Inset
- (instancetype)jg_stretchImageWithLeftCap:(CGFloat)left topCap:(CGFloat)top;

/// 图片平铺拉伸
- (instancetype)jg_tileImage;

/// 图片大小修改
- (instancetype)jg_imageScaleAspectFit:(CGSize)targetSize;
- (instancetype)jg_imageScaleAspectFill:(CGSize)targetSize;
- (instancetype)jg_imageScaleWithCropping:(BOOL)cropping size:(CGSize)targetSize;

/// 图片方向修正
- (instancetype)jg_imageCorrectedOrientation;
- (instancetype)jg_imageCorrectedOrientation:(UIImageOrientation)imageOrientation;

#pragma mark - Compress
/**
 * 图片大小缩放
 * @param scale 缩放比例
 */
- (UIImage *)jg_imageWithScale:(CGFloat)scale;

/**
 * 图片大小和质量压缩，大小等比压缩，内存消耗比较大
 * 同时压缩图片大小和质量，返回Data大小 <= 传入kb
 * @param kb 压缩期望大小，单位kb
 * @return NSData 压缩后数据
 */
- (NSData *)jg_compressSizeAndQualityDataWithExpectKBSize:(NSInteger)kb;

/**
 * 图片大小和质量压缩，大小等比压缩，内存消耗比较大
 * 同时压缩图片大小和质量，返回Data大小 <= 传入kb
 * @param kb 压缩期望大小，单位kb
 * @param minQuality 最小压缩质量，默认0，minQuality < 0默认0，minQuality >＝ 1默认0.8，达到minQuality出入后持续压缩图片大小
 * @return NSData 压缩后数据
 */
- (NSData *)jg_compressSizeAndQualityDataWithExpectKBSize:(NSInteger)kb minQuality:(CGFloat)minQuality;

@end

NS_ASSUME_NONNULL_END
