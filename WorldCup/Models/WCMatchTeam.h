//
//  WCMatchTeam.h
//  WorldCup
//
//  Created by Ryan Nystrom on 6/20/14.
//  Copyright (c) 2014 Ryan Nystrom. All rights reserved.
//

#import <Mantle.h>
#import "WCTeam.h"
#import "WCEvent.h"

@interface WCMatchTeam : MTLModel

@property (nonatomic) WCTeam *team;
@property (nonatomic) NSArray *events;
@property (nonatomic) NSNumber *goals;

@end
