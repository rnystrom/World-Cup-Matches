//
//  WCClient.h
//  WorldCup
//
//  Created by Ryan Nystrom on 6/20/14.
//  Copyright (c) 2014 Ryan Nystrom. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WCClient : NSObject

- (void)fetchMatchesWithCompletion:(void (^)(id,NSError*))completion;
- (void)fetchMatchesTodayWithCompletion:(void (^)(id,NSError*))completion;
- (void)fetchMatchesCurrentWithCompletion:(void (^)(id,NSError*))completion;
- (void)fetchGroupsWithCompletion:(void (^)(id,NSError*))completion;
- (void)fetchCountry:(NSString *)countryCode completion:(void (^)(id,NSError*))completion;

@end
