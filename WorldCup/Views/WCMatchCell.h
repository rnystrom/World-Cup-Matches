//
//  WCMatchCell.h
//  WorldCup
//
//  Created by Ryan Nystrom on 6/22/14.
//  Copyright (c) 2014 Ryan Nystrom. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WCMatchCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *homeLabel;
@property (weak, nonatomic) IBOutlet UILabel *awayLabel;
@property (weak, nonatomic) IBOutlet UILabel *homeScoreLabel;
@property (weak, nonatomic) IBOutlet UILabel *awayScoreLabel;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UIImageView *awayImageView;
@property (weak, nonatomic) IBOutlet UIImageView *homeImageView;

@end
