//
//  WCTeam.m
//  WorldCup
//
//  Created by Ryan Nystrom on 6/20/14.
//  Copyright (c) 2014 Ryan Nystrom. All rights reserved.
//

#import "WCTeam.h"

@implementation WCTeam

- (void)bindWithJSON:(NSDictionary *)json {
    [KZPropertyMapper mapValuesFrom:json toInstance:self usingMapping:@{
                                                                        @"code": KZProperty(code),
                                                                        @"country": KZProperty(countryName)
                                                                        }];
}

- (NSString *)description {
    return self.countryName;
}

- (BOOL)isEqual:(id)object {
    if ([object isKindOfClass:WCTeam.class]) {
        WCTeam *other = object;
        return [self.code isEqualToString:other.code] && [self.countryName isEqualToString:other.countryName];
    }
    return NO;
}

@end
