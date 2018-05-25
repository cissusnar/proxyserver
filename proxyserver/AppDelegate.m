//
//  AppDelegate.m
//  proxyserver
//
//  Created by cissu on 2017/11/7.
//  Copyright © 2017年 k. All rights reserved.
//

#import "AppDelegate.h"
#import "FirstViewController.h"
#import "SecondViewController.h"
#import <YYKit/YYKit.h>

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [self.window makeKeyAndVisible];
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        //! baidu的正确用法 😂
        NSLog(@"request network : %@", @([NSData dataWithContentsOfURL:[NSURL URLWithString:@"http://baidu.com"]].length));
    });
    
    [self mainViewControllerInit];
    return YES;
}

- (void)mainViewControllerInit
{
    UITabBarController *tabBarController = [UITabBarController new];
    
    FirstViewController * mainController = [FirstViewController new];
    UIViewController * vc1 = [[UINavigationController alloc] initWithRootViewController:mainController];
    vc1.tabBarItem.title = @"闪跃";
    vc1.tabBarItem.image = [UIImage imageNamed:@"ic_flash_on"];
    
    tabBarController.viewControllers = @[vc1];
    
    tabBarController.tabBar.tintColor = [UIColor orangeColor];
    tabBarController.tabBar.translucent = YES;
    self.window.rootViewController = tabBarController;
    
    UINavigationBar *navigationBar = [UINavigationBar appearance];
    navigationBar.tintColor = [UIColor blackColor];
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
