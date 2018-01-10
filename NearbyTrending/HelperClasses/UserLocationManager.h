//
//  UserLocationManager.h
//  NearbyTrending
//
//  Created by Anil Bunkar on 10/01/18.
//  Copyright © 2018 Anil Bunkar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@protocol LocationManagerDelegate <NSObject>

@optional
- (void) locationServicesNotEnabledOnDevice;
- (void) locationServiceNotEnabledForTheApp;
- (void) setUserCurrentLocation: (CLLocationCoordinate2D) currentLocation;

@end

@interface UserLocationManager : NSObject <CLLocationManagerDelegate>
@property (nonatomic, weak) id<LocationManagerDelegate> delegate;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic) CLLocationCoordinate2D currentLocation;

- (void) checkLocationStatus;

@end
