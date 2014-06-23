//
//  WCMatchTeam.m
//  WorldCup
//
//  Created by Ryan Nystrom on 6/20/14.
//  Copyright (c) 2014 Ryan Nystrom. All rights reserved.
//

#import "WCMatchTeam.h"

@implementation WCMatchTeam

- (BOOL)isEqual:(id)object {
    if ([object isKindOfClass:WCMatchTeam.class]) {
        WCMatchTeam *other = object;
        return [self.team isEqual:other.team] && [self.events isEqual:other.events] && [self.goals isEqual:other.goals];
    }
    return NO;
}

@end
