//
//  OUFrame.m
//  OU_iPad
//
//  Created by runs on 2017/8/30.
//  Copyright © 2017年 Olacio. All rights reserved.
//

#import "OUFrame.h"

static CGSize const RelativeSize = (CGSize){800,600};

@implementation OURange
MJCodingImplementation
+ (instancetype)rangWithLocation:(long long)loc length:(long long)len {
    return [[self alloc] initWithLocation:loc length:len];
}

- (instancetype)initWithLocation:(long long)loc length:(long long)len {
    self = [super init];
    if (self) {
        _loc = loc;
        _len = len;
    }
    return self;
}

- (id)copyWithZone:(nullable NSZone *)zone {
    OURange *model = (OURange *) [[[self class] allocWithZone:zone] init];
    model.len = self.len;
    model.loc = self.loc;
    return model;
}

- (BOOL)containElement:(NSInteger)element {
    long long value = _loc + _len;
    //前闭后开区间
    return _loc <= element && element < value;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"{ %lld, %lld }", _loc, _len];
}

- (BOOL)isEqual:(id)object {
    if (self == object) {
        return YES;
    }
    
    OURange *range = (OURange *)object;
    if (![range isKindOfClass:OURange.class]) {
        return NO;
    }
    return _len == range.len && _loc == range.loc;
}

- (NSUInteger)hash {
    return (NSUInteger)((_loc << 8 ) ^ _len);
}

@end

@implementation CoordinateTransformProtocol

- (OUSize *)itemSize {
    return [OUSize rateSize];
}

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
    OUPoint *p = [[[self class] alloc] init];
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

- (void)localAdapter {
    if (_isLocalization) return;
    if (!self.itemSize) return;
    //远端800*600 转成本地
    self.x = _x/RelativeSize.width * self.itemSize.width;
    self.y = _y/RelativeSize.height * self.itemSize.height;
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
    
//    RunsLogEX(@"图片限定范围在 : %.2f x %.2f", maxSize.width, maxSize.height)
    
    CGFloat rate = size.width / size.height;
    if (size.width >= size.height) {
//        RunsLogEX(@"该图片 宽度大 高度小")
        s.width = size.width > maxSize.width ? maxSize.width : size.width;
        s.height = s.width / rate;
    
        if (s.height > maxSize.height) {
            //避免高度超出限定范围
            s.height = maxSize.height;
            s.width = s.height * rate;
        }
        
    }else if (size.width < size.height) {
        
//        RunsLogEX(@"该图片 宽度小 高度大")
        s.height = size.height > maxSize.height ? maxSize.height : size.height;
        s.width = s.height * rate;
        
        if (s.width > maxSize.width) {
            //避免宽度度超出限定范围
            s.width = maxSize.width;
            s.height = s.width / rate;
        }
    }
    return s;
}

+ (instancetype)sizeWithSize:(CGSize)size {
    return [OUSize sizeWithSize:size itemSize:nil];
}

+ (instancetype)sizeWithSize:(CGSize)size itemSize:(OUSize *)itemSize {
    OUSize *s = [OUSize new];
    s.width = size.width;
    s.height = size.height;
    s.itemSize = itemSize;
    return s;
}

+ (instancetype)sizeWithFrame:(CGRect)frame {
    return [OUSize sizeWithFrame:frame itemSize:nil];
}

+ (instancetype)sizeWithFrame:(CGRect)frame itemSize:(OUSize *)itemSize {
    return [OUSize sizeWithSize:frame.size itemSize:itemSize];
}

+ (instancetype)sizeWithWidth:(CGFloat)w height:(CGFloat)h {
    return [OUSize sizeWithWidth:w height:h itemSize:nil];
}

+ (instancetype)sizeWithWidth:(CGFloat)w height:(CGFloat)h itemSize:(OUSize *)itemSize {
    OUSize *s = [OUSize new];
    s.width = w;
    s.height = h;
    s.itemSize = itemSize;
    return s;
}

+ (instancetype)sizeWithOrigin:(CGPoint)origin end:(CGPoint)end {
    return [OUSize sizeWithOrigin:origin end:end itemSize:nil];
}

+ (instancetype)sizeWithOrigin:(CGPoint)origin end:(CGPoint)end itemSize:(OUSize *)itemSize {
    OUSize *s = [OUSize new];
    s.width = end.x - origin.x;//fabs(end.x - origin.x);
    s.height = end.y - origin.y;//fabs(end.y - origin.y);
    s.itemSize = itemSize;
    return s;
}

+ (instancetype)sizeWithFirst:(OUPoint *)first last:(OUPoint *)last {
    return [OUSize sizeWithFirst:first last:last itemSize:nil];
}

+ (instancetype)sizeWithFirst:(OUPoint *)first last:(OUPoint *)last itemSize:(OUSize *)itemSize {
    OUSize *s = [OUSize new];
    s.width = last.x - first.y;//fabs(last.x - first.y);
    s.height = last.y - first.y;//fabs(last.y - first.y);
    s.itemSize = itemSize;
    return s;
}

+ (instancetype)rateSize {
    NSDictionary *local = [NSUserDefaults.standardUserDefaults objectForKey:kCoursewareItemValue];
    CGFloat width = [local[self.widthKey] doubleValue];
    CGFloat height = [local[self.heightKey] doubleValue];
    OUSize *localSize = [OUSize sizeWithWidth:width height:height];
    if (0 == width || height == 0) {
        localSize = [OUSize sizeWithWidth:OC_SCREEN_MIN_LENGTH * AREA_UN_RATE height:OC_SCREEN_MIN_LENGTH];
    }
    return localSize;
}

+ (CGSize)itemSize {
    NSDictionary *local = [NSUserDefaults.standardUserDefaults objectForKey:kCoursewareItemValue];
    CGFloat width = [local[self.widthKey] doubleValue];
    CGFloat height = [local[self.heightKey] doubleValue];
    CGSize localSize = (CGSize){width, height};
    
    if (0 == width || height == 0) {
        localSize = CGSizeMake(OC_SCREEN_MIN_LENGTH * AREA_UN_RATE , OC_SCREEN_MIN_LENGTH);
    }
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
