//
//  WCTeamsController.m
//  WorldCup
//
//  Created by Ryan Nystrom on 6/21/14.
//  Copyright (c) 2014 Ryan Nystrom. All rights reserved.
//

#import "WCTeamsController.h"
#import "WCDataStore.h"
#import <ReactiveCocoa.h>
#import "WCTeam.h"

@interface WCTeamsController ()

@property (nonatomic, strong) NSArray *sortedTeams;

@end

@implementation WCTeamsController

NSString * const TeamCellIdentifier = @"TeamCellIdentifier";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:TeamCellIdentifier];
    
    self.title = @"Teams";
    
    WCDataStore *store = [WCDataStore sharedStore];
    
    [[RACObserve(store, matches)
      filter:^BOOL (id matches) {
          return matches != nil;
      }]
     subscribeNext:^(id matches) {
         [self performSelectorOnMainThread:@selector(updateTeams) withObject:nil waitUntilDone:NO];
     }];
}

#pragma mark - Data Observers

- (void)updateTeams {
    NSSet *teams = [[WCDataStore sharedStore] teams];
    
    self.sortedTeams = [teams sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"countryName" ascending:YES]]];
    
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.sortedTeams count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:TeamCellIdentifier forIndexPath:indexPath];
    
    WCTeam *team = self.sortedTeams[indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"%@",team];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

@end
