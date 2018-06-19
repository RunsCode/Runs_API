//
//  OUFrame.h
//  OU_iPad
//
//  Created by runs on 2017/8/30.
//  Copyright © 2017年 Olacio. All rights reserved.
//

#import <Foundation/Foundation.h>
/**
 * 前闭后开区间
 */
@interface OURange : NSObject<NSCopying, NSCoding>
@property (nonatomic, assign) long long loc;
@property (nonatomic, assign) long long len;
+ (instancetype)rangWithLocation:(long long)loc length:(long long)len;
- (BOOL)containElement:(NSInteger)element;
@end

@class OUSize;
@interface CoordinateTransformProtocol : NSObject
@property (nonatomic, strong) OUSize *itemSize;

- (instancetype)local;//WithItemSize:(OUSize *)size;
- (instancetype)remote;//WithItemSize:(OUSize *)size;

- (void)localAdapter;
- (void)remoteAdapter;

@end


@interface OUPoint : CoordinateTransformProtocol

@property (nonatomic, assign) CGFloat x;
@property (nonatomic, assign) CGFloat y;
@property (nonatomic, assign) CGPoint cgPoint;

+ (instancetype)pointWithPoint:(CGPoint)point;
+ (instancetype)pointWithPoint:(CGPoint)point itemSize:(OUSize *)size;

+ (instancetype)pointWithX:(CGFloat)x y:(CGFloat)y ;
+ (instancetype)pointWithX:(CGFloat)x y:(CGFloat)y itemSize:(OUSize *)size;

+ (instancetype)pointWithFrame:(CGRect)frame;
+ (instancetype)pointWithFrame:(CGRect)frame itemSize:(OUSize *)size;

@end


@interface OUSize : CoordinateTransformProtocol

@property (nonatomic, assign) CGFloat width;
@property (nonatomic, assign) CGFloat height;
@property (nonatomic, assign) CGSize cgSize;

/**
 适应宽高比 以最长边长为基准

 @param size size
 @return size
 */
+ (instancetype)sizeAdapterImageSize:(CGSize)size;

+ (instancetype)sizeWithSize:(CGSize)size;
+ (instancetype)sizeWithSize:(CGSize)size itemSize:(OUSize *)itemSize;

+ (instancetype)sizeWithFrame:(CGRect)frame;
+ (instancetype)sizeWithFrame:(CGRect)frame itemSize:(OUSize *)itemSize;

+ (instancetype)sizeWithWidth:(CGFloat)w height:(CGFloat)h;
+ (instancetype)sizeWithWidth:(CGFloat)w height:(CGFloat)h itemSize:(OUSize *)itemSize;

+ (instancetype)sizeWithOrigin:(CGPoint)origin end:(CGPoint)end;
+ (instancetype)sizeWithOrigin:(CGPoint)origin end:(CGPoint)end itemSize:(OUSize *)itemSize;

+ (instancetype)sizeWithFirst:(OUPoint *)first last:(OUPoint *)last;
+ (instancetype)sizeWithFirst:(OUPoint *)first last:(OUPoint *)last itemSize:(OUSize *)itemSize;

+ (instancetype)rateSize;
+ (NSString *)widthKey;
+ (NSString *)heightKey;
+ (CGSize)itemSize;

@end


@interface OUFrame : NSObject

@property (nonatomic, strong) OUPoint *origin;
@property (nonatomic, strong) OUSize *size;

@end

