//
//  VenueTableViewCell.m
//  NearbyTrending
//
//  Created by Anil Bunkar on 10/01/18.
//  Copyright © 2018 Anil Bunkar. All rights reserved.
//

#import "VenueTableViewCell.h"

@implementation VenueTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void) setVenue:(Venue *)venueObj {
    [self.nameLabel setText:venueObj.name];
    if (venueObj.distanceInMeters.floatValue > 1000) {
        [self.distanceLabel setText:[NSString stringWithFormat:@"%.1f kms",venueObj.distanceInMeters.floatValue/1000]];

    } else {
        [self.distanceLabel setText:[NSString stringWithFormat:@"%@ m",venueObj.distanceInMeters.stringValue]];
    }
        
    if (venueObj.address.length) {
        [self.addressLabel setText:venueObj.address];
    } else {
        [self.addressLabel setText:@""];
    }
}

+ (NSString *) reuseIdentifier {
    return NSStringFromClass([self class]);
}

@end
