//
//  WCDetailController.m
//  WorldCup
//
//  Created by Ryan Nystrom on 6/23/14.
//  Copyright (c) 2014 Ryan Nystrom. All rights reserved.
//

#import "WCDetailController.h"
#import "WCMatchEventView.h"
#import "WCMatch.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface WCDetailController ()

@property (nonatomic) UIScrollView *scrollView;

@property (weak, nonatomic) IBOutlet UILabel *homeNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *homeScoreLabel;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UILabel *awayNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *awayScoreLabel;

@property (nonatomic) UIView *headerContainer;

@end

@implementation WCDetailController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.backgroundFadeView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:self.backgroundFadeView];
    
    self.scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    self.scrollView.backgroundColor = [UIColor clearColor];
    self.scrollView.alwaysBounceVertical = YES;
    [self.view addSubview:self.scrollView];
    
    UIButton *close = [UIButton buttonWithType:UIButtonTypeCustom];
    [close setImage:[UIImage imageNamed:@"close"] forState:UIControlStateNormal];
    [close addTarget:self action:@selector(onClose:) forControlEvents:UIControlEventTouchUpInside];
    // yup, hardcoding, so sue me
    CGFloat buttonWidth = 44;
    close.frame = CGRectMake(CGRectGetWidth(self.view.bounds) - buttonWidth - 5 /*padding*/, 20 /*status bar*/, buttonWidth, buttonWidth);
    [self.view addSubview:close];
    
    UINib *nib = [UINib nibWithNibName:@"WCMatchDetailHeaderView" bundle:nil];
    self.headerContainer = [[nib instantiateWithOwner:self options:nil] firstObject];
    self.headerContainer.backgroundColor = [UIColor clearColor];
    [self.scrollView addSubview:self.headerContainer];
    
    CGRect headerFrame = self.headerContainer.frame;
    headerFrame.origin.y = buttonWidth + 20; // derp
    self.headerContainer.frame = headerFrame;
    
    [self setupHeader];
    [self eventsContainer];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)onClose:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (NSArray *)events {
    NSArray *homeEvents = self.match.home.events;
    NSArray *awayEvents = self.match.away.events;
    NSArray *merged = [homeEvents arrayByAddingObjectsFromArray:awayEvents];
    return [merged sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"time" ascending:YES]]];
}

- (void)setupHeader {
    self.homeNameLabel.text = self.match.home.team.countryName;
    self.homeScoreLabel.text = self.match.home.goals.stringValue;
    
    self.awayNameLabel.text = self.match.away.team.countryName;
    self.awayScoreLabel.text = self.match.away.goals.stringValue;
    
    if (self.match.status == WCMatchStatusCompleted) {
        self.statusLabel.text = @"FT";
    }
    else if (self.match.status == WCMatchStatusInProgress) {
        self.statusLabel.text = @"Live";
    }
    else if (self.match.status == WCMatchStatusFuture) {
        static NSDateFormatter *timeFormatter = nil;
        
        if (! timeFormatter) {
            timeFormatter = [[NSDateFormatter alloc] init];
            timeFormatter.dateStyle = NSDateFormatterNoStyle;
            timeFormatter.timeStyle = NSDateFormatterShortStyle;
        }
        
        self.statusLabel.text = [timeFormatter stringFromDate:self.match.date];
        self.homeScoreLabel.text = nil;
        self.awayScoreLabel.text = nil;
    }
    
    NSString *imageBaseURL = @"http://img.fifa.com/images/flags/4/%@.png";
    NSString *homeImage = [NSString stringWithFormat:imageBaseURL,self.match.home.team.code];
    NSString *awayImage = [NSString stringWithFormat:imageBaseURL,self.match.away.team.code];
    
    [self.homeFlagImageView setImageWithURL:[NSURL URLWithString:homeImage]];
    [self.awayFlagImageView setImageWithURL:[NSURL URLWithString:awayImage]];
}

- (UIView *)eventsContainer {
    if (! _eventsContainer) {
        NSArray *events = [self events];
        
        CGRect headerFrame = self.headerContainer.frame;
        
        CGFloat eventHeight = [WCMatchEventView eventViewHeight];
        CGFloat eventTotalHeight = eventHeight * events.count;
        CGFloat headerBottom = headerFrame.origin.y + headerFrame.size.height;
        
        CGRect containerFrame = CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), eventTotalHeight);
        containerFrame.origin.y = headerBottom;
        
        _eventsContainer = [[UIView alloc] initWithFrame:containerFrame];
        
        CGRect eventFrame = CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), eventHeight);
        
        for (WCEvent *event in events) {
            UINib *nib = [UINib nibWithNibName:@"WCMatchEventView" bundle:nil];
            WCMatchEventView *eventView = [[nib instantiateWithOwner:self options:nil] firstObject];
            eventView.backgroundColor = [UIColor clearColor];
            
            eventView.frame = eventFrame;
            
            BOOL isHome = [self.match.home.events containsObject:event];
            NSString *homeText, *awayText;
            
            if (isHome) {
                homeText = event.player;
            }
            else {
                awayText = event.player;
            }
            
            eventView.homePlayerLabel.text = homeText;
            eventView.awayPlayerLabel.text = awayText;
            eventView.eventLabel.text = event.typeName;
            eventView.timeLabel.text = [NSString stringWithFormat:@"%@'",event.time];
            
            [self.eventsContainer addSubview:eventView];
            
            eventFrame.origin.y += eventFrame.size.height;
        }
        
        [self.scrollView addSubview:_eventsContainer];
        [self.scrollView setContentSize:CGSizeMake(0, eventTotalHeight + headerBottom)];
    }
    return _eventsContainer;
}

@end
