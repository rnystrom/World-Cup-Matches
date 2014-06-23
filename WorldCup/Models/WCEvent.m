//
//  WCEvent.m
//  WorldCup
//
//  Created by Ryan Nystrom on 6/20/14.
//  Copyright (c) 2014 Ryan Nystrom. All rights reserved.
//

#import "WCEvent.h"

@implementation WCEvent

- (void)bindWithJSON:(NSDictionary *)json {
    [KZPropertyMapper mapValuesFrom:json toInstance:self usingMapping:@{
                                                                        @"id": KZProperty(apiID),
                                                                        @"player": KZProperty(player),
                                                                        @"time": KZProperty(time),
                                                                        @"type_of_event": KZProperty(typeName)
                                                                        }];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@ had %@ at %@ minutes",self.player,self.typeName,self.time];
}

- (BOOL)isEqual:(id)object {
    if ([object isKindOfClass:WCEvent.class]) {
        WCEvent *other = object;
        return [self.apiID isEqual:other.apiID];
    }
    return NO;
}

@end
