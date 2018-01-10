//
//  UserLocationManager.m
//  NearbyTrending
//
//  Created by Anil Bunkar on 10/01/18.
//  Copyright © 2018 Anil Bunkar. All rights reserved.
//

#import "UserLocationManager.h"

@implementation UserLocationManager

- (CLLocationManager *) locationManager {
    if (!_locationManager) {
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.delegate = self;
    }
    return _locationManager;
}

- (void) checkLocationStatus {
    //if location services have been disabled
    //on the device
    if ([CLLocationManager locationServicesEnabled] == NO) {
        if ([self.delegate respondsToSelector:@selector(locationServicesNotEnabledOnDevice)]) {
            [self.delegate locationServicesNotEnabledOnDevice];
        }
        
    } else {
        //if location services are enabled
        //on the device

        CLAuthorizationStatus authorizationStatus= [CLLocationManager authorizationStatus];
        //if location services have been revoked for the app
        if(authorizationStatus == kCLAuthorizationStatusDenied || authorizationStatus == kCLAuthorizationStatusRestricted) {
            if ([self.delegate respondsToSelector:@selector(locationServiceNotEnabledForTheApp)]) {
                [self.delegate locationServiceNotEnabledForTheApp];
            }
            
        } else if (authorizationStatus == kCLAuthorizationStatusAuthorizedWhenInUse) {
            //get location
            [self.locationManager startUpdatingLocation];
//            if ([self.delegate respondsToSelector:@selector(setUserCurrentLocation:)]) {
//                CLLocation *currentLocation = self.locationManager.location;
//                [self.delegate setUserCurrentLocation:currentLocation];
//            }

        } else {
            //if we haven't asked the user for location permissions
            [self.locationManager requestWhenInUseAuthorization];

        }
    }
    
}

#pragma mark CLLocationManagerDelegate methods
- (void) locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    if (locations.count) {
        _currentLocation = [locations lastObject].coordinate;
        //to avoid unnecessary calls, stop updating locations
        [manager stopUpdatingLocation];
        if ([self.delegate respondsToSelector:@selector(setUserCurrentLocation:)]) {
            [self.delegate setUserCurrentLocation:_currentLocation];
        }
    }
}

- (void) locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    if (status == kCLAuthorizationStatusDenied) {
        if ([self.delegate respondsToSelector:@selector(locationServiceNotEnabledForTheApp)]) {
            [self.delegate locationServiceNotEnabledForTheApp];
        }

    }else if (status == kCLAuthorizationStatusAuthorizedWhenInUse) {
        [self.locationManager startUpdatingLocation];
        
    }

}
@end
