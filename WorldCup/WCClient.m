//
//  WCClient.m
//  WorldCup
//
//  Created by Ryan Nystrom on 6/20/14.
//  Copyright (c) 2014 Ryan Nystrom. All rights reserved.
//

#import "WCClient.h"

@interface WCClient()

@property (nonatomic) NSURLSession *session;

@end

@implementation WCClient

- (instancetype)init {
    if (self = [super init]) {
        _session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    }
    return self;
}

- (void)fetch:(NSString *)location params:(NSDictionary *)params completion:(void (^)(id,NSError*))completion {
    [self.class setNetworkActivityIndicatorVisible:YES];
    
    NSMutableString *paramString = [[NSMutableString alloc] init];
    [params enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [paramString appendFormat:@"%@=%@&",key,obj];
    }];
    
    NSString *urlString = [NSString stringWithFormat:@"http://worldcup.sfg.io/%@",location];
    
    if ([paramString length]) {
        urlString = [urlString stringByAppendingFormat:@"?%@",paramString];
    }
    
    NSURL *url = [NSURL URLWithString:urlString];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    NSURLSessionDataTask *task = [self.session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        [self.class setNetworkActivityIndicatorVisible:NO];
        
        if (error) {
            NSLog(@"%@",error);
            
            if (completion) {
                completion(nil, error);
            }
        }
        else {
            NSError *error2 = nil;
            id json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
            
            if (error2) {
                NSLog(@"%@",error2);
            }
            
            if (completion) {
                completion(json, error2);
            }
        }
    }];
    [task resume];
}

- (void)fetchMatchesWithCompletion:(void (^)(id,NSError*))completion {
    [self fetch:@"matches" params:nil completion:completion];
}

- (void)fetchMatchesTodayWithCompletion:(void (^)(id,NSError*))completion {
    [self fetch:@"matches/today" params:nil completion:completion];
}

- (void)fetchMatchesCurrentWithCompletion:(void (^)(id,NSError*))completion {
    [self fetch:@"matches/current" params:nil completion:completion];
}

- (void)fetchGroupsWithCompletion:(void (^)(id,NSError*))completion {
    [self fetch:@"group_results" params:nil completion:completion];
}

- (void)fetchCountry:(NSString *)countryCode completion:(void (^)(id,NSError*))completion {
    [self fetch:@"matches/country" params:@{@"fifa_code": countryCode} completion:completion];
}

// http://oleb.net/blog/2009/09/managing-the-network-activity-indicator/
+ (void)setNetworkActivityIndicatorVisible:(BOOL)setVisible {
    static NSUInteger kNetworkIndicatorCount = 0;
    
    if (setVisible) {
        kNetworkIndicatorCount++;
    }
    else {
        kNetworkIndicatorCount--;
    }
    
    // The assertion helps to find programmer errors in activity indicator management.
    // Since a negative NumberOfCallsToSetVisible is not a fatal error,
    // it should probably be removed from production code.
    NSAssert(kNetworkIndicatorCount >= 0, @"Network Activity Indicator was asked to hide more often than shown");
    
    // Display the indicator as long as our static counter is > 0.
    dispatch_async(dispatch_get_main_queue(), ^{
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:(kNetworkIndicatorCount > 0)];
    });
}

@end
