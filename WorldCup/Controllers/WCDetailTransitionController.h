//
//  WCDetailTransitionController.h
//  WorldCup
//
//  Created by Ryan Nystrom on 6/24/14.
//  Copyright (c) 2014 Ryan Nystrom. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WCDetailTransitionController : NSObject
<UIViewControllerTransitioningDelegate>

@property (nonatomic, weak) UIView *homeView;
@property (nonatomic, weak) UIView *awayView;

@end
