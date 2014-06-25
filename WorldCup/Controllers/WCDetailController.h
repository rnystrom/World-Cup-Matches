//
//  WCDetailController.h
//  WorldCup
//
//  Created by Ryan Nystrom on 6/23/14.
//  Copyright (c) 2014 Ryan Nystrom. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WCMatch;

@interface WCDetailController : UIViewController

@property (nonatomic) WCMatch *match;

@property (nonatomic) UIImageView *backgroundFadeView;

// exposed for transitions
@property (weak, nonatomic) IBOutlet UIImageView *homeFlagImageView;
@property (weak, nonatomic) IBOutlet UIImageView *awayFlagImageView;
@property (nonatomic) UIView *eventsContainer;

@end
