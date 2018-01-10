//
//  GetTrendingVenues.h
//  NearbyTrending
//
//  Created by Anil Bunkar on 09/01/18.
//  Copyright © 2018 Anil Bunkar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "APIObjectDelegate.h"

@interface GetTrendingVenues : NSObject
@property (nonatomic, strong) NSMutableArray *trendingVenues;
- (void) getTrendingVenuesNear:(NSString *)latLon withCallbackDelegate:(id<APIObjectDelegate>)callbackDelegate;

@end
