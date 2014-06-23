//
//  WCTeam.h
//  WorldCup
//
//  Created by Ryan Nystrom on 6/20/14.
//  Copyright (c) 2014 Ryan Nystrom. All rights reserved.
//

#import <Mantle.h>
#import "WCJSONBinding.h"

@interface WCTeam : MTLModel
<WCJSONBinding>

@property (nonatomic) NSString *code;
@property (nonatomic) NSString *countryName;

@end