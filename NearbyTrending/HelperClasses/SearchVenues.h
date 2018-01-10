//
//  SearchVenues.h
//  NearbyTrending
//
//  Created by Anil Bunkar on 09/01/18.
//  Copyright © 2018 Anil Bunkar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "APIObjectDelegate.h"
#import "FSCachingManager.h"
#import <CoreLocation/CoreLocation.h>

@interface SearchVenues : NSObject
@property (nonatomic, strong) FSCachingManager *cachingManager;
@property (nonatomic, strong) NSURLSessionDataTask *dataTask;
@property (nonatomic, strong) NSMutableArray *searchResults;
@property (nonatomic) CLLocationCoordinate2D currentLocation;
- (void) searchVenuesForKey: (NSString *)query withCallbackDelegate:(id<APIObjectDelegate>)callbackDelegate;

@end
