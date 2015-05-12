//
//  AppDelegate.m
//  TrainingTimer
//
//  Created by sungeo on 15/3/21.
//  Copyright (c) 2015年 buddysoft. All rights reserved.
//

#import "AppDelegate.h"
#import "TrainingData.h"
#import "ViewController.h"
#import "BDFoundation.h"
#import "HiitSettingViewController.h"
#import "StartViewController.h"
#import "UIColor+TrainingTimer.h"
#import "TrainingSetting.h"
#import "TrainingProcess.h"
#import "EmptyViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)launchScreen{
    EmptyViewController * vc = [[EmptyViewController alloc] initWithNibName:@"EmptyViewController" bundle:nil];
    self.window.rootViewController = vc;
    
    return YES;
}


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // 是否打开测试模式：时间会飞快流逝，走完预设所有训练过程
    TrainingDebug = YES;
//    return [self launchScreen];
    
    [UIColor loadSchema];
    
    [Utils customizeStatusBarForApplication:application withStyle:UIStatusBarStyleLightContent];
    [Utils customizeNavigationBarForApplication:application withColor:[UIColor barBackgroundColor]];
    
    // 加载数据
    [[TrainingData defaultInstance] loadDataes];
    
    UIViewController * root = self.window.rootViewController;
    if ([root isKindOfClass:[UINavigationController class]]) {
        UINavigationController * nav = (UINavigationController *)root;
//        HiitSettingViewController * vc = [[HiitSettingViewController alloc] init];
        StartViewController * vc = [[StartViewController alloc] init];
        [nav setViewControllers:@[vc]];
    }
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
