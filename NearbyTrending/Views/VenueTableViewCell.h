//
//  VenueTableViewCell.h
//  NearbyTrending
//
//  Created by Anil Bunkar on 10/01/18.
//  Copyright © 2018 Anil Bunkar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Venue.h"

@interface VenueTableViewCell : UITableViewCell

@property (nonatomic, strong) IBOutlet UILabel *nameLabel;
@property (nonatomic, strong) IBOutlet UILabel *distanceLabel;
@property (nonatomic, strong) IBOutlet UILabel *addressLabel;

- (void) setVenue: (Venue *) venueObj;
+ (NSString *) reuseIdentifier;

@end
