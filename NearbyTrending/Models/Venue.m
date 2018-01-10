//
//  Venue.m
//  NearbyTrending
//
//  Created by Anil Bunkar on 09/01/18.
//  Copyright © 2018 Anil Bunkar. All rights reserved.
//

#import "Venue.h"

@implementation Venue

- (void) parseDataFromObect:(NSDictionary *)venueObject {
    
    self.venueId = [venueObject valueForKey:@"id"];
    self.address = [venueObject valueForKeyPath:@"location.address"];
    self.latitude = [venueObject valueForKeyPath:@"location.lat"];
    self.longitude = [venueObject valueForKeyPath:@"location.lng"];
    self.name = [venueObject valueForKey:@"name"];
    self.checkinsCount = [venueObject valueForKeyPath:@"stats.checkinsCount"];
    self.distanceInMeters = [venueObject valueForKeyPath:@"location.distance"];
}

//encoder and decoder to save objects in archieves
- (id)initWithCoder:(NSCoder *)decoder {
    if((self = [super init])) {
        self.venueId = [decoder decodeObjectForKey:@"id"];
        self.address = [decoder decodeObjectForKey:@"address"];
        self.latitude = [decoder decodeObjectForKey:@"latitude"];
        self.longitude = [decoder decodeObjectForKey:@"longitude"];
        self.name = [decoder decodeObjectForKey:@"name"];
        self.checkinsCount = [decoder decodeObjectForKey:@"checkins"];
        self.distanceInMeters = [decoder decodeObjectForKey:@"distance"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:self.venueId forKey:@"id"];
    [encoder encodeObject:self.address?self.address:@"" forKey:@"address"];
    [encoder encodeObject:self.latitude?self.latitude:@0 forKey:@"latitude"];
    [encoder encodeObject:self.longitude?self.longitude : @0 forKey:@"longitude"];
    [encoder encodeObject:self.name forKey:@"name"];
    [encoder encodeObject:self.checkinsCount?self.checkinsCount:@0 forKey:@"checkins"];
    [encoder encodeObject:self.distanceInMeters?self.distanceInMeters:@0 forKey:@"distance"];
}


@end
