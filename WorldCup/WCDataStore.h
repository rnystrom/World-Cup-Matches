//
//  WCDataStore.h
//  WorldCup
//
//  Created by Ryan Nystrom on 6/20/14.
//  Copyright (c) 2014 Ryan Nystrom. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WCDataStore : NSObject

+ (instancetype)sharedStore;

@property (nonatomic, strong) NSArray *matches;

- (NSSet *)teams;

- (void)fetchAllMatches:(void (^)(NSArray*,NSError*))completion;

- (void)prepareForTermination;

@end
