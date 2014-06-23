//
//  WCEvent.h
//  WorldCup
//
//  Created by Ryan Nystrom on 6/20/14.
//  Copyright (c) 2014 Ryan Nystrom. All rights reserved.
//

#import <Mantle.h>
#import "WCJSONBinding.h"

@interface WCEvent : MTLModel
<WCJSONBinding>

@property (nonatomic) NSNumber *apiID;
@property (nonatomic) NSString *player;
@property (nonatomic) NSNumber *time;
@property (nonatomic) NSString *typeName;

@end
