//
//  WCMatchEventView.h
//  WorldCup
//
//  Created by Ryan Nystrom on 6/23/14.
//  Copyright (c) 2014 Ryan Nystrom. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WCMatchEventView : UIView

+ (CGFloat)eventViewHeight;

@property (weak, nonatomic) IBOutlet UILabel *eventLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *homePlayerLabel;
@property (weak, nonatomic) IBOutlet UILabel *awayPlayerLabel;

@end
