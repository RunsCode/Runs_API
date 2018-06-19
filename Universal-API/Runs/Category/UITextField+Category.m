//
//  UITextField+Category.m
//  OU_iPhone
//
//  Created by runs on 2017/12/11.
//  Copyright © 2017年 Olacio. All rights reserved.
//

#import "UITextField+Category.h"
#import <objc/runtime.h>
NSString * const UITextFieldEventEditingDidDeleteBackward = @"UITextFieldEventEditingDidDeleteBackward";

@implementation UITextField (Category)

+ (void)load {
    Method originalMethod = class_getInstanceMethod(self, @selector(deleteBackward));
    Method swizzledMethod = class_getInstanceMethod(self, @selector(rs_deleteBackward));
    method_exchangeImplementations(originalMethod, swizzledMethod);
}

- (void)rs_deleteBackward {
    [self rs_deleteBackward];
    
    if ([self.delegate respondsToSelector:@selector(textFieldDidDeleteBackward:)]) {
        id<RunsTextFieldDelegate> delegate = (id<RunsTextFieldDelegate>)self.delegate;
        [delegate textFieldDidDeleteBackward:self];
    }
    
    [NSNotificationCenter.defaultCenter postNotificationName:UITextFieldEventEditingDidDeleteBackward object:self];
}

- (void)rs_subscribeWithEvent:(UIControlEvents)event {
    [self addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
}

- (void)textFieldDidChange:(UITextField *)textField {
    if ([self.delegate respondsToSelector:@selector(textFieldDidChangeEvent:)]) {
        id<RunsTextFieldDelegate> delegate = (id<RunsTextFieldDelegate>)self.delegate;
        [delegate textFieldDidChangeEvent:self];
    }
}

@end
