//
//  OUFrame.m
//  OU_iPad
//
//  Created by runs on 2017/8/30.
//  Copyright © 2017年 Olacio. All rights reserved.
//

#import "OUFrame.h"

static CGSize const RelativeSize = (CGSize){800,600};

@implementation CoordinateTrandfromProtocol

- (instancetype)remote {
    [self remoteAdapter];
    return self;
}

- (void)remoteAdapter {
    //sub class will override
}

- (instancetype)local {
    [self localAdapter];
    return self;
}

- (void)localAdapter {
    //sub class will override
}

@end

@interface OUPoint ()
@property(nonatomic, assign) BOOL isLocalization;
@end

@implementation OUPoint

+ (NSArray *)mj_ignoredPropertyNames {
    return @[@"itemSize",@"cgPoint",@"isLocalization"];
}

+ (instancetype)pointWithPoint:(CGPoint)point {
    return [[self class] pointWithPoint:point itemSize:nil];
}

+ (instancetype)pointWithPoint:(CGPoint)point itemSize:(OUSize *)size {
    OUPoint *p = [[self class] new];
    p.x = point.x;
    p.y = point.y;
    p.itemSize = size;
    return p;
}

+ (instancetype)pointWithX:(CGFloat)x y:(CGFloat)y {
    return [[self class] pointWithX:x y:y itemSize:nil];
}

+ (instancetype)pointWithX:(CGFloat)x y:(CGFloat)y itemSize:(OUSize *)size {
    OUPoint *p = [[self class] new];
    p.x = x;
    p.y = y;
    p.itemSize = size;
    return p;
}

+ (instancetype)pointWithFrame:(CGRect)frame {
    return [[self class] pointWithFrame:frame itemSize:nil];
}

+ (instancetype)pointWithFrame:(CGRect)frame itemSize:(OUSize *)size {
    OUPoint *p = [[self class] pointWithX:frame.origin.x y:frame.origin.y itemSize:size];
    return p;
}

+ (CGSize)itemSize {
    return [OUSize itemSize];
}

- (void)localAdapter {
    if (_isLocalization) return;
    if (!self.itemSize) return;
    //远端800*600 转成本地
    self.x = _x/RelativeSize.width * self.itemSize.width;
    self.y = _y/RelativeSize.height * self.itemSize.height;
    //
    _isLocalization = YES;
}

- (void)remoteAdapter {
    if (!self.itemSize) return;
    //本地转成800*600
    self.x = _x/self.itemSize.width * RelativeSize.width;
    self.y = _y/self.itemSize.height * RelativeSize.height;
}

- (CGPoint)cgPoint {
    return (CGPoint){_x, _y};
}

@end



@implementation OUSize

+ (NSArray *)mj_ignoredPropertyNames {
    return @[@"itemSize",@"cgSize"];
}

+ (instancetype)sizeAdapterImageSize:(CGSize)size {
    OUSize *s = [OUSize new];
    CGSize maxSize = self.class.itemSize;
    CGFloat rate = size.width / size.height;
    if (size.width >= size.height) {
        
        s.width = size.width > maxSize.width ? maxSize.width : size.width;
        s.height = s.width / rate;
        
    }else if (size.width < size.height) {
        
        s.height = size.height > maxSize.height ? maxSize.height : size.height;
        s.width = s.height * rate;
    }
    return s;
}

+ (instancetype)sizeWithSize:(CGSize)size {
    return [OUSize sizeWithSize:size itemSize:nil];
}

+ (instancetype)sizeWithSize:(CGSize)size itemSize:(OUSize *)size {
    OUSize *s = [OUSize new];
    s.width = size.width;
    s.height = size.height;
    s.itemSize = size;
    return s;
}

+ (instancetype)sizeWithFrame:(CGRect)frame {
    return [OUSize sizeWithFrame:frame itemSize:nil];
}

+ (instancetype)sizeWithFrame:(CGRect)frame itemSize:(OUSize *)size {
    return [OUSize sizeWithSize:frame.size itemSize:size];
}

+ (instancetype)sizeWithWidth:(CGFloat)w height:(CGFloat)h {
    return [OUSize sizeWithWidth:w height:h itemSize:nil];
}

+ (instancetype)sizeWithWidth:(CGFloat)w height:(CGFloat)h itemSize:(OUSize *)size {
    OUSize *s = [OUSize new];
    s.width = w;
    s.height = h;
    s.itemSize = size;
    return s;
}

+ (instancetype)sizeWithOrigin:(CGPoint)origin end:(CGPoint)end {
    return [OUSize sizeWithOrigin:origin end:end itemSize:nil];
}

+ (instancetype)sizeWithOrigin:(CGPoint)origin end:(CGPoint)end itemSize:(OUSize *)size {
    OUSize *s = [OUSize new];
    s.width = end.x - origin.x;//fabs(end.x - origin.x);
    s.height = end.y - origin.y;//fabs(end.y - origin.y);
    s.itemSize = size;
    return s;
}

+ (instancetype)sizeWithFirst:(OUPoint *)first last:(OUPoint *)last {
    return [OUSize sizeWithFirst:first last:last itemSize:nil];
}

+ (instancetype)sizeWithFirst:(OUPoint *)first last:(OUPoint *)last itemSize:(OUSize *)size {
    OUSize *s = [OUSize new];
    s.width = last.x - first.y;//fabs(last.x - first.y);
    s.height = last.y - first.y;//fabs(last.y - first.y);
    s.itemSize = size;
    return s;
}

+ (instancetype)rateSize {
    NSDictionary *local = [NSUserDefaults.standardUserDefaults objectForKey:kCoursewareItemValue];
    CGFloat width = [local[self.widthKey] doubleValue];
    CGFloat height = [local[self.heightKey] doubleValue];
    OUSize *localSize = [OUSize sizeWithWidth:width height:height];
    return localSize;
}

+ (CGSize)itemSize {
    NSDictionary *local = [NSUserDefaults.standardUserDefaults objectForKey:kCoursewareItemValue];
    CGFloat width = [local[self.widthKey] doubleValue];
    CGFloat height = [local[self.heightKey] doubleValue];
    CGSize localSize = (CGSize){width, height};
    return localSize;
}

+ (NSString *)widthKey {
    return @"width";
}

+ (NSString *)heightKey {
    return @"height";
}

- (CGSize)cgSize {
    return (CGSize){_width, _height};
}

- (instancetype)local {
    [self localAdapter];
    return self;
}

- (instancetype)remote {
    [self remoteAdapter];
    return self;
}

- (void)localAdapter {
    if (!self.itemSize) return;
    //远端size 转换本地size
    self.width = _width/RelativeSize.width * self.itemSize.width;
    self.height = _height/RelativeSize.height * self.itemSize.height;
}

- (void)remoteAdapter {
    if (!self.itemSize) return;
    //本地size 转换远端size
    self.width = _width/self.itemSize.width * RelativeSize.width;
    self.height = _height/self.itemSize.height * RelativeSize.height;
}

@end

@implementation OUFrame

+ (NSArray *)mj_ignoredPropertyNames {
    return @[@"itemSize"];
}

@end
