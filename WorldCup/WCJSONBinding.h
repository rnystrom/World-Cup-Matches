//
//  WCJSONBinding.h
//  WorldCup
//
//  Created by Ryan Nystrom on 6/20/14.
//  Copyright (c) 2014 Ryan Nystrom. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <KZPropertyMapper/KZPropertyMapper.h>

@protocol WCJSONBinding <NSObject>

@required
- (void)bindWithJSON:(NSDictionary *)json;

@end
