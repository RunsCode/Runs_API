//
//  RunsHollowView.m
//  Runs
//
//  Created by runs on 2018/8/6.
//  Copyright © 2018 Olacio. All rights reserved.
//

#import "RunsHollowView.h"

@interface RunsHollowView ()
@property (nonatomic, strong) UIBezierPath *bezierPath;
@end

@implementation RunsHollowView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _expandPixel = 0;
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame radius:(CGFloat)cornerRadius hollowFrame:(CGRect)hollowFrame {
    if (CGRectIsEmpty(frame)) return nil;
    self = [self initWithFrame:frame];
    if (self) {
        UIBezierPath *path = [self pathWithFrame:hollowFrame radius:cornerRadius];
        if (path) {
            [self.bezierPath appendPath:path];
        }
    }
    return self;
}

- (instancetype)initWithMaskedView:(UIView *)view radius:(CGFloat)cornerRadius hollowFrame:(CGRect)hollowFrame {
    if (!view) return nil;
    self = [self initWithFrame:view.frame];
    if (self) {
        UIBezierPath *path = [self pathWithFrame:hollowFrame radius:cornerRadius];
        if (path) {
            [self.bezierPath appendPath:path];
        }
    }
    return self;
}

- (instancetype)initWithMaskedView:(UIView *)view radius:(CGFloat)cornerRadius hollowItemView:(UIView *)itmeView {
    if (!view) return nil;
    self = [self initWithFrame:view.frame];
    if (self) {
        UIBezierPath *path = [self pathWithFrame:itmeView.frame radius:cornerRadius];
        if (path) {
            [self.bezierPath appendPath:path];
        }
    }
    return self;

}

- (instancetype)initWithFrame:(CGRect)frame radius:(CGFloat)cornerRadius frames:(NSValue *)frames, ... {
    if (CGRectIsEmpty(frame)) return nil;
    self = [self initWithFrame:frame];
    if (self) {
        if (CGRectIsEmpty(frame)) return self;
        UIBezierPath *path = [self pathWithFrame:frames.CGRectValue radius:cornerRadius];
        va_list argsList;
        [self.bezierPath appendPath:path];
        va_start(argsList, frames);
        NSValue *arg;
        while ((arg = va_arg(argsList, id))) {
            if (CGRectIsEmpty(arg.CGRectValue)) continue;
            UIBezierPath *p = [self pathWithFrame:arg.CGRectValue radius:cornerRadius];
            [_bezierPath appendPath:p];
        }
        va_end(argsList);
    }
    return self;
}

- (instancetype)initWithMaskedView:(UIView *)view radius:(CGFloat)cornerRadius items:(UIView *)items, ... {
    if (!view) return nil;
    self = [self initWithFrame:view.frame];
    if (self) {
        if (!view) return self;
        UIBezierPath *path = [self pathWithFrame:items.frame radius:cornerRadius];
        [self.bezierPath appendPath:path];
        va_list argsList;
        va_start(argsList, items);
        UIView *arg;
        while ((arg = va_arg(argsList, id))) {
            if (!view) continue;
            UIBezierPath *p = [self pathWithFrame:arg.frame radius:cornerRadius];
            [_bezierPath appendPath:p];
        }
        va_end(argsList);
    }
    return self;
}

- (CGRect (^)(CGRect, CGFloat))expand {
    return ^ (CGRect frame, CGFloat expand) {
        return CGRectMake(frame.origin.x - (expand * 0.5) , frame.origin.y - (expand * 0.5), frame.size.width + expand, frame.size.height + expand);
    };
}

- (RunsHollowView * (^)(CGRect frame))appendFrame {
    return  ^(CGRect frame) {
        return self.append(frame, 0);
    };
}

- (RunsHollowView * (^)(UIView *))appendView {
    return ^(UIView *view) {
        return self.append(view.frame, 0);
    };
}

- (RunsHollowView * (^)(CGRect, CGFloat))append {
    return ^(CGRect frame, CGFloat radius) {
        UIBezierPath *path = [self pathWithFrame:frame radius:radius];
        if (path) [self.bezierPath appendPath:path];
        return self;
    };
}

- (void)display {
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    shapeLayer.path = _bezierPath.CGPath;
    self.layer.mask = shapeLayer;
}

- (UIBezierPath *)pathWithFrame:(CGRect)frame radius:(CGFloat)radius {
    if (CGRectIsEmpty(frame)) return nil;
    
    if (radius <= 0 || radius <= frame.size.width * 0.5) {
        return [self rectanglePath:frame radius:radius];
    }
    return [self roundPath:frame radius:radius];
}

- (UIBezierPath *)rectanglePath:(CGRect)frame radius:(CGFloat)radius {
    frame = self.expand(frame, _expandPixel);
    return [UIBezierPath bezierPathWithRoundedRect:frame cornerRadius:radius].bezierPathByReversingPath;
}

- (UIBezierPath *)roundPath:(CGRect)frame radius:(CGFloat)radius {
    frame = self.expand(frame, _expandPixel);
    CGPoint origin = frame.origin;
    CGSize size = frame.size;
    CGPoint center = CGPointMake(origin.x + (size.width * 0.5), origin.y + (size.height * 0.5));
    return [UIBezierPath bezierPathWithArcCenter:center radius:radius startAngle:0 endAngle:2*M_PI clockwise:NO];
}

- (UIBezierPath *)bezierPath {
    if (_bezierPath) return _bezierPath;
    _bezierPath = [UIBezierPath bezierPathWithRect:self.frame];
    return _bezierPath;
}

@end
