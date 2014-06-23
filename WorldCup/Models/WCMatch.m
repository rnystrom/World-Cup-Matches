//
//  WCMatch.m
//  WorldCup
//
//  Created by Ryan Nystrom on 6/20/14.
//  Copyright (c) 2014 Ryan Nystrom. All rights reserved.
//

#import "WCMatch.h"

@implementation WCMatch

+ (NSDateFormatter *)dateFormatter {
    static NSDateFormatter *dateFormatter = nil;
    
    if (! dateFormatter) {
        dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateStyle = NSDateFormatterFullStyle;
        dateFormatter.timeStyle = NSDateFormatterNoStyle;
    }
    
    return dateFormatter;
}

- (void)bindWithJSON:(NSDictionary *)json {
    self.away = [self matchTeamFromJSON:json teamKey:@"away_team" eventKey:@"away_team_events"];
    self.home = [self matchTeamFromJSON:json teamKey:@"home_team" eventKey:@"home_team_events"];
    
    // only need 1 object
    static NSDateFormatter *dateFormatter = nil;
    if (! dateFormatter) {
        dateFormatter = [[NSDateFormatter alloc] init];
        // "datetime": "2014-06-20T16:00:00.000-03:00",
        dateFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss.SSSSSSZ";
    }
    
    // NSDateFormatters are not thread safe
    @synchronized(dateFormatter) {
        // http://stackoverflow.com/a/12011366
        NSDate *date;
        NSError *error;
        NSDateFormatter *formatter = dateFormatter;
        [formatter getObjectValue:&date forString:json[@"datetime"] range:nil error:&error];
        
        if (error) {
            NSLog(@"%@",error);
        }
        
        self.date = date;
    }
    
    [KZPropertyMapper mapValuesFrom:json toInstance:self usingMapping:@{
                                                                        @"location": KZProperty(locationName),
                                                                        @"match_number": KZProperty(matchNumber),
                                                                        @"status": KZProperty(statusString)
                                                                        }];
    
    self.status = [self statusFromString:self.statusString];
}

- (WCMatchStatus)statusFromString:(NSString *)string {
    if ([string isEqualToString:@"completed"]) {
        return WCMatchStatusCompleted;
    }
    else if ([string isEqualToString:@"in progress"]) {
        return WCMatchStatusInProgress;
    }
    else if ([string isEqualToString:@"future"]) {
        return WCMatchStatusFuture;
    }
    
    return WCMatchStatusUnknown;
}

- (WCMatchTeam *)matchTeamFromJSON:(id)json teamKey:(NSString *)teamKey eventKey:(NSString *)eventKey {
    NSString *tbdString = [NSString stringWithFormat:@"%@_tbd",teamKey];
    id teamJSON = json[teamKey];
    if ([teamJSON isKindOfClass:[NSArray class]] && [[teamJSON firstObject] isEqualToString:tbdString]) {
        return nil;
    }
    
    WCMatchTeam *matchTeam = [[WCMatchTeam alloc] init];
    
    WCTeam *team = [[WCTeam alloc] init];
    [team bindWithJSON:teamJSON];
    matchTeam.team = team;
    
    NSMutableArray *events = [[NSMutableArray alloc] init];
    for (NSDictionary *eventJSON in json[eventKey]) {
        WCEvent *event = [[WCEvent alloc] init];
        [event bindWithJSON:eventJSON];
        [events addObject:event];
    }
    matchTeam.events = events;
    
    NSString *goalsKeyPath = [NSString stringWithFormat:@"%@.goals",teamKey];
    matchTeam.goals = [json valueForKeyPath:goalsKeyPath];
    
    return matchTeam;
}

- (WCTeam *)winner {
    if (self.away.goals > self.home.goals) {
        return self.away.team;
    }
    else if (self.home.goals > self.away.goals) {
        return self.home.team;
    }
    return nil;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@ vs %@",self.home.team,self.away.team];
}

- (BOOL)isEqual:(id)object {
    if ([object isKindOfClass:WCMatch.class]) {
        WCMatch *other = object;
        return [self.matchNumber isEqual:other.matchNumber];
    }
    return NO;
}

- (NSString *)dayString {
    NSDateFormatter *formatter = [self.class dateFormatter];
    NSString *date;
    @synchronized(formatter) {
        date = [formatter stringFromDate:self.date];
    }
    return date;
}

@end
