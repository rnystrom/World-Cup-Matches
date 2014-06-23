//
//  WCMatchesController.m
//  WorldCup
//
//  Created by Ryan Nystrom on 6/20/14.
//  Copyright (c) 2014 Ryan Nystrom. All rights reserved.
//

#import "WCMatchesController.h"
#import "WCDataStore.h"
#import "WCMatch.h"
#import <ReactiveCocoa.h>
#import "WCMatchCell.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface WCMatchesController ()

@property (nonatomic) NSArray *sortedDates;
@property (nonatomic) NSDictionary *matchDates;
@property (nonatomic) NSString *todayString;

@end

@implementation WCMatchesController

NSString * const MatchCellIdentifier = @"MatchCellIdentifier";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSDateFormatter *formatter = [WCMatch dateFormatter];
    @synchronized(formatter) {
        self.todayString = [formatter stringFromDate:[NSDate date]];
    }
    
    [self.tableView registerClass:WCMatchCell.class forCellReuseIdentifier:MatchCellIdentifier];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundColor = [UIColor colorWithWhite:0.92 alpha:1];
    
    self.title = @"World Cup 2014";
    
    WCDataStore *store = [WCDataStore sharedStore];
    
    [[RACObserve(store, matches)
     filter:^BOOL (id matches) {
         return matches != nil;
     }]
     subscribeNext:^(id matches) {
        [self performSelectorOnMainThread:@selector(updateMatches) withObject:nil waitUntilDone:NO];
    }];
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
    
    self.navigationItem.leftBarButtonItem = [self refreshButton];
    
    // http://stackoverflow.com/questions/19022210/preferredstatusbarstyle-isnt-called
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // in -viewWillAppear to update date if it changes
    UIImage *calendar = [self calendarImage];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:calendar style:UIBarButtonItemStyleBordered target:self action:@selector(onToday:)];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

#pragma mark - Actions

- (void)onRefresh:(id)sender {
    UIActivityIndicatorView *activity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    [activity startAnimating];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:activity];
    
    [[WCDataStore sharedStore] fetchAllMatches:^(NSArray *matches, NSError *error) {
        [self.navigationItem performSelectorOnMainThread:@selector(setLeftBarButtonItem:) withObject:[self refreshButton] waitUntilDone:NO];
    }];
}

- (void)onToday:(id)sender {
    [self scrollToTodayAnimated:YES];
}

- (void)scrollToTodayAnimated:(BOOL)animated {
    NSInteger todayIdx = [self.sortedDates indexOfObject:self.todayString];
    
    if (todayIdx < [self.sortedDates count]) {
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:todayIdx] atScrollPosition:UITableViewScrollPositionTop animated:animated];
    }
}

- (void)refresh {
    [[WCDataStore sharedStore] fetchAllMatches:nil];
}

#pragma mark - Getters

- (UIImage *)calendarImage {
    UIImage *blank = [UIImage imageNamed:@"calendar-blank"];
    
    NSCalendar *currentCalendar = [NSCalendar currentCalendar];
    NSDateComponents *weekdayComponents = [currentCalendar components:NSDayCalendarUnit fromDate:[NSDate date]];
    NSInteger day = [weekdayComponents day];
    
    NSString *dayString = [NSString stringWithFormat:@"%i",day];
    
    NSMutableParagraphStyle *paragStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    [paragStyle setAlignment:NSTextAlignmentCenter];
    
    NSDictionary *textAttributes = @{
                                     NSFontAttributeName: [UIFont fontWithName:@"ProximaNova-Bold" size:11],
                                     NSParagraphStyleAttributeName: paragStyle,
                                     NSForegroundColorAttributeName: [UIColor whiteColor]
                                     };
    
    NSStringDrawingContext *drawingContext = [[NSStringDrawingContext alloc] init];
    drawingContext.minimumScaleFactor = 0.5; // Half the font size
    
    CGRect drawRect = CGRectMake(0.0, 0.0, blank.size.width, blank.size.height);
    
    UIGraphicsBeginImageContextWithOptions(drawRect.size, NO, [UIScreen mainScreen].scale);
    
    [blank drawInRect:drawRect];
    
    drawRect.origin.y = 12;
    
    [dayString drawWithRect:drawRect
                    options:NSStringDrawingUsesLineFragmentOrigin
                 attributes:textAttributes
                    context:drawingContext];
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return image;
}

- (UIBarButtonItem *)refreshButton {
    return [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(onRefresh:)];
}

#pragma mark - Data Observers

- (void)updateMatches {
    if (self.refreshControl.isRefreshing) {
        [self.refreshControl endRefreshing];
    }
    
    NSMutableDictionary *dates = [[NSMutableDictionary alloc] init];
    NSMutableArray *days = [[NSMutableArray alloc] init];
    NSArray *matches = [WCDataStore sharedStore].matches;
    
    // used for sorting groups
    matches = [matches sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"date" ascending:YES]]];
    
    for (WCMatch *match in matches) {
        NSString *day = [match dayString];
        NSMutableArray *existing = dates[day];
        if (! existing) {
            existing = [[NSMutableArray alloc] init];
            
            // use instead of -allKeys on dictionary to maintain sort
            [days addObject:day];
        }
        [existing addObject:match];
        dates[day] = existing;
    }
    
    self.sortedDates = days;
    self.matchDates = dates;
    
    [self.tableView reloadData];
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self scrollToTodayAnimated:NO];
    });
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.sortedDates count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSString *key = self.sortedDates[section];
    NSArray *matches = self.matchDates[key];
    
    return [matches count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    WCMatchCell *cell = [tableView dequeueReusableCellWithIdentifier:MatchCellIdentifier forIndexPath:indexPath];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    NSString *key = self.sortedDates[indexPath.section];
    NSArray *matches = self.matchDates[key];
    WCMatch *match = matches[indexPath.row];
    
    WCTeam *home = match.home.team;
    WCTeam *away = match.away.team;
    
    cell.homeLabel.text = home.countryName;
    cell.awayLabel.text = away.countryName;
    cell.homeScoreLabel.text = match.home.goals.stringValue;
    cell.awayScoreLabel.text = match.away.goals.stringValue;
    
    if (match.status == WCMatchStatusCompleted) {
        cell.statusLabel.text = @"FT";
        
        WCTeam *winner = [match winner];
        UIView *label, *score;
        
        if (winner == home) {
            label = cell.homeLabel;
            score = cell.homeScoreLabel;
        }
        else {
            label = cell.awayLabel;
            score = cell.awayScoreLabel;
        }
        
        label.alpha = 0.35f;
        score.alpha = 0.35f;
    }
    else if (match.status == WCMatchStatusInProgress) {
        cell.statusLabel.text = @"Live";
    }
    else if (match.status == WCMatchStatusFuture) {
        static NSDateFormatter *timeFormatter = nil;
        
        if (! timeFormatter) {
            timeFormatter = [[NSDateFormatter alloc] init];
            timeFormatter.dateStyle = NSDateFormatterNoStyle;
            timeFormatter.timeStyle = NSDateFormatterShortStyle;
        }
        
        cell.statusLabel.text = [timeFormatter stringFromDate:match.date];
        cell.homeScoreLabel.text = @"--";
        cell.awayScoreLabel.text = @"--";
    }
    
    NSString *imageBaseURL = @"http://img.fifa.com/images/flags/4/%@.png";
    NSString *homeImage = [NSString stringWithFormat:imageBaseURL,home.code];
    NSString *awayImage = [NSString stringWithFormat:imageBaseURL,away.code];
    
    [cell.homeImageView setImageWithURL:[NSURL URLWithString:homeImage]];
    [cell.awayImageView setImageWithURL:[NSURL URLWithString:awayImage]];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 25;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    NSString *title = [self.sortedDates[section] uppercaseString];
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), 25)];
    view.backgroundColor = [UIColor colorWithWhite:0.95 alpha:1];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectInset(view.bounds, 10, 0)];
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor colorWithWhite:0.5 alpha:1];
    label.font = [UIFont fontWithName:@"ProximaNova-Semibold" size:13];
    label.text = title;
    [view addSubview:label];
    
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 90;
}

@end
