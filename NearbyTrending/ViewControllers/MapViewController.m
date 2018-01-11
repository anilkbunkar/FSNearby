//
//  MapViewController.m
//  NearbyTrending
//
//  Created by Anil Bunkar on 11/01/18.
//  Copyright © 2018 Anil Bunkar. All rights reserved.
//

#import "MapViewController.h"
#import <MapKit/MapKit.h>

@interface MapViewController ()
@property (nonatomic, strong) IBOutlet MKMapView *mapView;
@property (nonatomic, strong) Venue *venueObj;
@end

@implementation MapViewController

- (id) initWithVenue:(Venue *)venue {
    self = [super init];
    if (self) {
        _venueObj = venue;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self setTitle:_venueObj.name];
    [self setupMapView];
    [self setBarButtonItem];
}

- (void) setupMapView {
    CLLocationCoordinate2D location = CLLocationCoordinate2DMake(_venueObj.latitude.doubleValue, _venueObj.longitude.doubleValue);
    MKCoordinateRegion coordinateRegion = MKCoordinateRegionMakeWithDistance(location, 2000, 2000);
    [self.mapView setRegion:coordinateRegion animated:YES];
    
    // add a pin to the map
//    self.mapView.delegate = self;
    MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
    [annotation setCoordinate:location];
    [annotation setTitle:_venueObj.name];
    [self.mapView addAnnotation:annotation];
}

- (void) setBarButtonItem {
    UIBarButtonItem *directionsButton = [[UIBarButtonItem alloc] initWithTitle:@"Direction"
                                                                      style:UIBarButtonItemStylePlain
                                                                     target:self
                                                                     action:@selector(showDirectionInMap)];
    
    self.navigationItem.rightBarButtonItem = directionsButton;

}

- (void) showDirectionInMap {
    CLLocationCoordinate2D location = CLLocationCoordinate2DMake(_venueObj.latitude.doubleValue, _venueObj.longitude.doubleValue);
    MKPlacemark *placeMark = [[MKPlacemark alloc] initWithCoordinate:location];
    MKMapItem *mapItem = [[MKMapItem alloc] initWithPlacemark:placeMark];
    mapItem.name = _venueObj.name;
    [mapItem openInMapsWithLaunchOptions:@{MKLaunchOptionsDirectionsModeKey:MKLaunchOptionsDirectionsModeDriving}];

}

@end
