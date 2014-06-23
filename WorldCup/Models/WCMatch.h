//
//  WCMatch.h
//  WorldCup
//
//  Created by Ryan Nystrom on 6/20/14.
//  Copyright (c) 2014 Ryan Nystrom. All rights reserved.
//

#import <Mantle.h>
#import "WCMatchTeam.h"
#import "WCJSONBinding.h"

typedef NS_ENUM(NSInteger, WCMatchStatus) {
    WCMatchStatusCompleted,
    WCMatchStatusInProgress,
    WCMatchStatusFuture,
    WCMatchStatusUnknown
};

@interface WCMatch : MTLModel
<WCJSONBinding>

+ (NSDateFormatter *)dateFormatter;

@property (nonatomic) WCMatchTeam *away;
@property (nonatomic) WCMatchTeam *home;

@property (nonatomic) NSDate *date;
@property (nonatomic) NSString *locationName;
@property (nonatomic) NSNumber *matchNumber;
@property (nonatomic) NSString *statusString;
@property (nonatomic) WCMatchStatus status;

- (WCTeam *)winner;

- (NSString *)dayString;

@end
