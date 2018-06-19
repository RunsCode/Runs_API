//
//  UITextField+Category.h
//  OU_iPhone
//
//  Created by runs on 2017/12/11.
//  Copyright © 2017年 Olacio. All rights reserved.
//

#import <UIKit/UIKit.h>

FOUNDATION_EXTERN NSString * const UITextFieldEventEditingDidDeleteBackward;

@protocol RunsTextFieldDelegate <UITextFieldDelegate>
@optional
- (void)textFieldDidDeleteBackward:(UITextField *)textField;
- (void)textFieldDidChangeEvent:(UITextField *)textField;
@end

@interface UITextField (Category)
@property(nonatomic, weak) id<RunsTextFieldDelegate> delegate;
- (void)rs_subscribeWithEvent:(UIControlEvents)event;
@end
