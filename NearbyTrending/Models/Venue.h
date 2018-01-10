//
//  Venue.h
//  NearbyTrending
//
//  Created by Anil Bunkar on 09/01/18.
//  Copyright © 2018 Anil Bunkar. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Venue : NSObject
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSNumber *checkinsCount;
@property (nonatomic, strong) NSString *address;
@property (nonatomic, strong) NSNumber *distanceInMeters;
@property (nonatomic, strong) NSNumber *latitude;
@property (nonatomic, strong) NSNumber *longitude;
@property (nonatomic, strong) NSNumber *venueId;

- (void) parseDataFromObect: (NSDictionary *)venueObject;

@end
