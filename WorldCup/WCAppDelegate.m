//
//  WCAppDelegate.m
//  WorldCup
//
//  Created by Ryan Nystrom on 6/20/14.
//  Copyright (c) 2014 Ryan Nystrom. All rights reserved.
//

#import "WCAppDelegate.h"
#import "WCMatchesController.h"
#import <KZPropertyMapper/KZPropertyMapper.h>
#import "WCDataStore.h"
#import "WCRouter.h"

@implementation WCAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [[WCRouter defaultRouter] setupScene];
    
    [KZPropertyMapper logIgnoredValues:NO];
    
    [[UINavigationBar appearance] setTitleTextAttributes:@{
                                                           NSForegroundColorAttributeName: [UIColor whiteColor],
                                                           NSFontAttributeName: [UIFont fontWithName:@"ProximaNova-Semibold" size:18],
                                                           }];
    [[UINavigationBar appearance] setBarTintColor:[UIColor colorWithRed:131/255.f green:193/255.f blue:66/255.f alpha:1]];
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    
    return YES;
}

- (void)applicationWillTerminate:(UIApplication *)application {
    [[WCDataStore sharedStore] prepareForTermination];
}

@end
