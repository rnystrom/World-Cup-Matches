//
//  WCRouter.m
//  WorldCup
//
//  Created by Ryan Nystrom on 6/21/14.
//  Copyright (c) 2014 Ryan Nystrom. All rights reserved.
//

#import "WCRouter.h"
#import "WCMatchesController.h"
#import "WCAppDelegate.h"

@interface WCRouter ()

@end

@implementation WCRouter

#pragma mark - Singleton

+ (instancetype)defaultRouter {
    static id _defaultRouter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _defaultRouter = [[self alloc] init];
    });
    return _defaultRouter;
}

- (void)setupScene {
    WCAppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    
    // taken from App Delegate boilerplate
    appDelegate.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    UIWindow *window = appDelegate.window;
    
    window.rootViewController = [self matchesController];
    
    window.backgroundColor = [UIColor whiteColor];
    [window makeKeyAndVisible];
}

#pragma mark - Getter

- (UIViewController *)matchesController {
    WCMatchesController *matches = [[WCMatchesController alloc] init];
    UINavigationController *matchesNav = [[UINavigationController alloc] initWithRootViewController:matches];
    matchesNav.tabBarItem.title = @"Matches";
    return matchesNav;
}

@end
