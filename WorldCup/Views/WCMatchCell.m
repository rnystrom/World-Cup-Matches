//
//  WCMatchCell.m
//  WorldCup
//
//  Created by Ryan Nystrom on 6/22/14.
//  Copyright (c) 2014 Ryan Nystrom. All rights reserved.
//

#import "WCMatchCell.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface WCMatchCell ()

@property (nonatomic) UIView *containerView;

@end

@implementation WCMatchCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        // http://stackoverflow.com/questions/14375552/interface-builder-keeps-reseting-the-width-of-my-custom-uitableviewcell
        UINib *nib = [UINib nibWithNibName:@"WCMatchContainerView" bundle:nil];
        UIView *containerView = [[nib instantiateWithOwner:self options:nil] firstObject];
        containerView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addSubview:containerView];
        
        NSDictionary *views = NSDictionaryOfVariableBindings(containerView);
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-10.0-[containerView]-10.0-|" options:0 metrics:nil views:views]];
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-5.0-[containerView]-5.0-|" options:0 metrics:nil views:views]];
        
        self.containerView = containerView;
        
        UIColor *background = [UIColor colorWithWhite:0.95 alpha:1];
        self.contentView.backgroundColor = background;
        
        // google "card" style
        self.containerView.layer.cornerRadius = 4;
        self.containerView.layer.shadowColor = [UIColor colorWithWhite:0.85 alpha:1].CGColor;
        self.containerView.layer.shadowOffset = CGSizeMake(0, 1);
        self.containerView.layer.shadowRadius = 0;
        self.containerView.layer.shadowOpacity = 1;
        
        UIColor *flagBorderColor = [UIColor colorWithWhite:0.9 alpha:1];
        self.homeImageView.layer.borderWidth = 1;
        self.homeImageView.layer.borderColor = flagBorderColor.CGColor;
        self.awayImageView.layer.borderWidth = 1;
        self.awayImageView.layer.borderColor = flagBorderColor.CGColor;
    }
    return self;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    
    self.containerView.layer.shadowPath = [UIBezierPath bezierPathWithRoundedRect:self.containerView.bounds cornerRadius:4].CGPath;
    
    [self.homeImageView cancelCurrentImageLoad];
    [self.awayImageView cancelCurrentImageLoad];
    
    self.homeScoreLabel.alpha = 1;
    self.homeLabel.alpha = 1;
    self.awayScoreLabel.alpha = 1;
    self.awayLabel.alpha = 1;
}

@end
