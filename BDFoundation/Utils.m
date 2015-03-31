//
//  Utils.m
//  investigation
//
//  Created by sungeo on 14/12/4.
//  Copyright (c) 2014年 buddysoft. All rights reserved.
//

#import "Utils.h"
#import <UIKit/UIKit.h>

@implementation Utils

+ (id)viewControllerWithIdentifier:(NSString *)identifier{
    UIStoryboard * mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    return [mainStoryboard instantiateViewControllerWithIdentifier:identifier];
}

+ (void)warningWithMessage:(NSString *)message{
    UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"提醒" message:message delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [alertView show];
}

+ (void)warningWithTitle:(NSString *)title message:(NSString *)message{
    UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
    [alertView show];
}

+ (void)errorWithMessage:(NSString *)message{
    UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"出错了" message:message delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [alertView show];
}

+ (void)hideExtraCellsForTableView:(UITableView *)tableView{
    // 隐藏多余的cell
    UIView * view = [[UIView alloc] init];
    view.backgroundColor = [UIColor clearColor];
    [tableView setTableFooterView:view];
}

+ (void)customizeBackNavigationItemTitle:(NSString *)title forViewController:(UIViewController *)vc{
    vc.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:title style:UIBarButtonItemStylePlain target:nil action:nil];
}

+ (void)customizeNavigationBarForApplication:(UIApplication *)application withColor:(UIColor *)color{
    // 自定义导航栏背景色、文字颜色
    // http://beyondvincent.com/2013/11/03/2013-11-03-120-customize-navigation-status-bar-ios-7/#6
    // 导航栏背景色
    [[UINavigationBar appearance] setBarTintColor:color];
    
    // 导航按钮颜色：返回或item按钮颜色
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    
    // Title文字颜色
    [[UINavigationBar appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor], NSForegroundColorAttributeName, nil]];
}

+ (void)customizeStatusBarForApplication:(UIApplication *)application withStyle:(UIStatusBarStyle)style{
    // 自定义状态栏颜色（记得先修改plist，上面链接中有描述）
    [application setStatusBarHidden:NO];
    [application setStatusBarStyle:style];

}


+ (NSString *)readableTimeFromSeconds:(NSTimeInterval)interval{
    NSString * timeString = @"";
    int seconds = (int)interval;
    int hours = seconds / (60 *60);
    if (hours > 0) {
        timeString = [@(hours) stringValue];
        timeString = [timeString stringByAppendingString:@"小时"];
        
        seconds -= hours * (60 * 60);
    }
    
    int minutes = seconds / 60;
    if (minutes > 0) {
        timeString = [timeString stringByAppendingString:[@(minutes) stringValue]];
        timeString = [timeString stringByAppendingString:@"分钟"];
        
        seconds -= minutes * 60;
    }
    
    if (seconds > 0) {
        timeString = [timeString stringByAppendingString:[@(seconds) stringValue]];
        timeString = [timeString stringByAppendingString:@"秒"];
    }
    
    return timeString;
}

+ (NSString *)colonSeperatedTime:(NSTimeInterval)interval{
    NSString * timeString = @"";
    int seconds = (int)interval;
    int hours = seconds / (60 *60);
    if (hours > 0) {
        timeString = [NSString stringWithFormat:@"%02d:", hours];
        seconds -= hours * (60 * 60);
    }
    
    int minutes = seconds / 60;
    seconds -= minutes * 60;
    timeString = [NSString stringWithFormat:@"%@%02d:%02d", timeString, minutes, seconds];
    
    return timeString;
}


@end
