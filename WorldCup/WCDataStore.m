//
//  WCDataStore.m
//  WorldCup
//
//  Created by Ryan Nystrom on 6/20/14.
//  Copyright (c) 2014 Ryan Nystrom. All rights reserved.
//

#import "WCDataStore.h"
#import "WCClient.h"
#import "WCMatch.h"

NSString * const kWCDataStoreArchivedMatchesKey = @"kWCDataStoreArchivedMatchesKey";

@interface WCDataStore ()

@property (nonatomic) WCClient *client;

@end

@implementation WCDataStore

#pragma mark - Singleton

+ (instancetype)sharedStore {
    static id _sharedStore = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedStore = [[self alloc] init];
    });
    return _sharedStore;
}

#pragma mark - Init

- (instancetype)init {
    if (self = [super init]) {
        _client = [[WCClient alloc] init];
        
        [self restorePersistedProperties];
        
        // immediately get the latest match information
        [self fetchAllMatches:nil];
    }
    return self;
}

#pragma mark - Network Requests

- (void)fetchAllMatches:(void (^)(NSArray*,NSError*))completion {
    [self.client fetchMatchesWithCompletion:^(id json, NSError *error) {
        NSMutableArray *matches = [[NSMutableArray alloc] init];
        
        for (id matchJSON in json) {
            // prevents unplayed, unscheduled games from showing up
            id away = matchJSON[@"away_team"];
            id home = matchJSON[@"home_team"];
            
            if (! [away isKindOfClass:NSArray.class] && ! [home isKindOfClass:NSArray.class]) {
                WCMatch *match = [[WCMatch alloc] init];
                [match bindWithJSON:matchJSON];
                
                [matches addObject:match];
            }
        }
        
        self.matches = matches;
        
        if (completion) {
            completion(matches, error);
        }
    }];
}

#pragma mark - Getters

- (NSSet *)teams {
    NSArray *matches = self.matches;
    
    NSArray *aways = [matches valueForKeyPath:@"away.team"];
    NSArray *home = [matches valueForKeyPath:@"home.team"];
    NSArray *allTeams = [aways arrayByAddingObjectsFromArray:home];
    
    return [NSSet setWithArray:allTeams];
}

#pragma mark - Persistance

- (void)restorePersistedProperties {
    _matches = [self unarchivedObjectWithKey:kWCDataStoreArchivedMatchesKey];
}

- (void)prepareForTermination {
    [self archiveObject:self.matches key:kWCDataStoreArchivedMatchesKey];
    
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (id)unarchivedObjectWithKey:(NSString *)key {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSData *data = [defaults objectForKey:key];
    id object;
    
    if ([data length]) {
        object = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    }
    
    return object;
}

// NOTE: [NSUserDefaults synchronize] is not called in this method
- (void)archiveObject:(id)object key:(NSString *)key {
    NSAssert([object conformsToProtocol:@protocol(NSCoding)], @"Object %@ does not conform to NSCoding",object);
    
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:object];
    
    if ([data length]) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:data forKey:key];
    }
}

@end
