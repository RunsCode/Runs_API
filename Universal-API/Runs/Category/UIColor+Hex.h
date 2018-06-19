//
//  UIColor+Hex.h
//

#import <UIKit/UIKit.h>

@interface UIColor (Hex) 

+ (UIColor*)colorWithCSS:(NSString*)css;
+ (UIColor*)colorWithCSS:(NSString*)css alpha:(CGFloat)alpha;
+ (UIColor*)colorWithHex:(NSUInteger)hex;
+ (UIColor *)colorWithHex:(uint)hex alpha:(CGFloat)alpha;

- (uint)hex;
- (NSString*)hexString;
- (NSString*)cssString;


@end
