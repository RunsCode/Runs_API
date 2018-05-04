//
//  NSString+Assistant.h
//  OU_iPad
//
//  Created by runs on 2017/12/7.
//  Copyright © 2017年 Olacio. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Assistant)
@property (nonatomic, strong) RunsHttpAssistant *httpAssistant;
- (void)rs_relaseAssisant;
@end
