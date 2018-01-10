//
//  FSCachingManager.h
//  NearbyTrending
//
//  Created by Anil Bunkar on 10/01/18.
//  Copyright © 2018 Anil Bunkar. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FSCachingManager : NSObject

@property (nonatomic, strong) NSMutableDictionary *cachedDictionary;

- (void) cacheResults: (NSArray *) resultsArray forQuery: (NSString *) query;
- (NSArray *) getCachedResultsForQuery: (NSString *) query;

@end
