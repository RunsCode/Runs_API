//
//  RunsAttributesLabel.m
//  OU_iPhone
//
//  Created by runs on 2017/11/22.
//  Copyright © 2017年 Olacio. All rights reserved.
//

#import "RunsAttributesLabel.h"

@implementation RunsAttributesLabel

- (void)setSystemFontOfSize:(CGFloat)systemFontOfSize {
    _systemFontOfSize = systemFontOfSize;
    if (_bold) {
        self.font = [UIFont boldSystemFontOfSize:systemFontOfSize];
        return;
    }
    self.font = [UIFont systemFontOfSize:systemFontOfSize];
}

@end
