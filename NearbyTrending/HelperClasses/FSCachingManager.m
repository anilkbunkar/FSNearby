//
//  FSCachingManager.m
//  NearbyTrending
//
//  Created by Anil Bunkar on 10/01/18.
//  Copyright © 2018 Anil Bunkar. All rights reserved.
//

#import "FSCachingManager.h"

@implementation FSCachingManager

- (id) init {
    self = [super init];
    if (self) {
        [self bringTheCachedResultsToMemory];
    }
    return self;
}

- (void) bringTheCachedResultsToMemory {
    //to serve queries faster, bring the results in the memory and delete the expired cached data
    NSString *appFile = [self getFilePath];
    NSDictionary* cachedDictionary = [NSKeyedUnarchiver unarchiveObjectWithFile:appFile];

    if (cachedDictionary) {
        NSMutableDictionary *validCacheDictionary = [[NSMutableDictionary alloc] init];
        
        //go through cache and keep the valid, will remove cache older than 3 days
        for (NSString *key in cachedDictionary.allKeys) {
            NSDictionary *resultDict = [cachedDictionary objectForKey:key];
            
            if (resultDict) {
                NSString *timestampString = [resultDict objectForKey:@"timestamp"];
                if ([self shouldKeepCacheWithTimeStamp:[timestampString doubleValue]]) {
                    NSArray *resultsArray = [resultDict objectForKey:@"results"];
                    
                    NSDictionary *tempDict = @{@"timestamp":timestampString,
                                               @"results":resultsArray
                                               };
                    [validCacheDictionary setObject:tempDict forKey:key];
                }
            }
            
        }
        _cachedDictionary = [[NSMutableDictionary alloc] initWithDictionary:validCacheDictionary];
        
    } else {
        _cachedDictionary = [[NSMutableDictionary alloc] init];
    }
    
}

- (BOOL) shouldKeepCacheWithTimeStamp: (NSTimeInterval) timeStamp {
    NSTimeInterval expiryLimit = 3*24*60*60; // 3 days
    NSTimeInterval currentTimestamp = [[NSDate date] timeIntervalSince1970];
    
    if (currentTimestamp - timeStamp > expiryLimit) {
        return NO;
    }
    return YES;
}


- (NSString *) getFilePath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *appFile = [documentsDirectory stringByAppendingPathComponent:@"nearbyTrendingCaching.txt"];

    return appFile;
}

- (void) cacheResults: (NSArray *) resultsArray forQuery: (NSString *) query {
    //cache results
    NSString *appFile = [self getFilePath];
    if (resultsArray && query) {
        //We are storing timestamp to check the validity of cache
        NSString *timestampString = [NSString stringWithFormat:@"%.f",[[NSDate date] timeIntervalSince1970]];
        NSDictionary *tempDict = @{@"timestamp":timestampString,
                                   @"results":resultsArray
                                   };
        [self.cachedDictionary setObject:tempDict forKey:query];
        [NSKeyedArchiver archiveRootObject:self.cachedDictionary toFile:appFile];
    }

}

- (NSArray *) getCachedResultsForQuery: (NSString *) query {
    //IMP => lat, lon have been appended in the end of query so that if someone moves from Gurgaon to Delhi and search for "coffee", should not get results for earlier location
    
    //check if we have cached results for query, if present, update the timestamp. If not present, return nil
    if (_cachedDictionary) {
        NSDictionary *tempDict = [_cachedDictionary objectForKey:query]; //it contains keys => timestmap & results
        if ([tempDict objectForKey:@"results"]) {
            return [tempDict objectForKey:@"results"];
        }
    }
    return nil;
}
@end
