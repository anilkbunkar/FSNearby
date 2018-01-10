//
//  HomeViewController.m
//  NearbyTrending
//
//  Created by Anil Bunkar on 09/01/18.
//  Copyright © 2018 Anil Bunkar. All rights reserved.
//

#import "HomeViewController.h"
#import "APIObjectDelegate.h"
#import "SearchVenues.h"
#import "GetTrendingVenues.h"
#import "VenueTableViewCell.h"
#import "UserLocationManager.h"

#define TRENDING_TABLE_TAG 101
#define SEARCH_TABLE_TAG 102

@interface HomeViewController () <UITableViewDelegate, UITableViewDataSource, APIObjectDelegate, UISearchBarDelegate, LocationManagerDelegate>

@property (nonatomic, strong) IBOutlet UITableView *trendingTableView;
@property (nonatomic, strong) IBOutlet UITableView *searchTableView;
@property (nonatomic, strong) IBOutlet UIActivityIndicatorView *activityIndicatorView;
@property (nonatomic, strong) IBOutlet UISearchBar *searchBar;
@property (nonatomic, strong) NSString *searchText;
@property (nonatomic, strong) IBOutlet NSLayoutConstraint *searchTableBottomConstraint;
@property (nonatomic, strong) IBOutlet NSLayoutConstraint *searchTableHeightConstraint;
@property (nonatomic, strong) GetTrendingVenues *trendingVenuesObj;
@property (nonatomic, strong) SearchVenues *searchVenuesObj;
@property (nonatomic) CLLocationCoordinate2D currentLocationCoordinates;
@property (nonatomic, strong) UserLocationManager *locationManager;
@property (nonatomic, strong) UIActivityIndicatorView *loaderView;

@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.trendingTableView.rowHeight = UITableViewAutomaticDimension;
    [self.trendingTableView registerNib:[UINib nibWithNibName:[VenueTableViewCell reuseIdentifier] bundle:nil] forCellReuseIdentifier:[VenueTableViewCell reuseIdentifier]];
    [self.searchTableView registerNib:[UINib nibWithNibName:[VenueTableViewCell reuseIdentifier] bundle:nil] forCellReuseIdentifier:[VenueTableViewCell reuseIdentifier]];
    self.trendingTableView.tag = TRENDING_TABLE_TAG;
    self.searchTableView.tag = SEARCH_TABLE_TAG;
    

    //setting default location to New york, no results for gurgaon
    _currentLocationCoordinates = CLLocationCoordinate2DMake(40.7243, -74.0018);

    //check user location
    [self.locationManager checkLocationStatus];
    [self setBarButtonItems];
}

- (void) setBarButtonItems {
    UIBarButtonItem *clickMeButton = [[UIBarButtonItem alloc] initWithTitle:@"Click Me"
                                                                    style:UIBarButtonItemStylePlain
                                                                   target:self
                                                                   action:@selector(clickMeTapped)];
    
    self.navigationItem.leftBarButtonItem = clickMeButton;
    
    _loaderView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [_loaderView setHidesWhenStopped:YES];
    UIBarButtonItem *loaderItem = [[UIBarButtonItem alloc] initWithCustomView:_loaderView];
    self.navigationItem.rightBarButtonItem = loaderItem;
}

- (void) clickMeTapped {
    //Since there were no results for gurgaon coordinate, giving some location options
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:@"Choose one of following to see results" preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *currentLocation = [UIAlertAction actionWithTitle:@"Current Location"
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction * _Nonnull action) {
                                                          [self.locationManager checkLocationStatus];

                                                      }];
    UIAlertAction *newYork = [UIAlertAction actionWithTitle:@"New York, USA"
                                                          style:UIAlertActionStyleDefault
                                                        handler:^(UIAlertAction * _Nonnull action) {
                                                            _currentLocationCoordinates = CLLocationCoordinate2DMake(40.7243, -74.0018);
                                                            NSString *latLonString = [NSString stringWithFormat:@"%f,%f",_currentLocationCoordinates.latitude, _currentLocationCoordinates.longitude];
                                                            [self.activityIndicatorView startAnimating];
                                                            [self.trendingVenuesObj getTrendingVenuesNear:latLonString withCallbackDelegate:self];

                                                        }];
    
    UIAlertAction *siliconValley = [UIAlertAction actionWithTitle:@"Silicon Valley, USA"
                                                            style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * _Nonnull action) {
                                                              _currentLocationCoordinates = CLLocationCoordinate2DMake(37.3875, 122.0575);
                                                              NSString *latLonString = [NSString stringWithFormat:@"%f,%f",_currentLocationCoordinates.latitude, _currentLocationCoordinates.longitude];
                                                              [self.activityIndicatorView startAnimating];
                                                              [self.trendingVenuesObj getTrendingVenuesNear:latLonString withCallbackDelegate:self];

                                                          }];

    UIAlertAction *cancelButton = [UIAlertAction actionWithTitle:NSLocalizedString(@"CANCEL", nil)
                                                           style:UIAlertActionStyleCancel
                                                         handler:nil];
    
    [alert addAction:currentLocation];
    [alert addAction:newYork];
    [alert addAction:siliconValley];
    [alert addAction:cancelButton];
    
    [self presentViewController:alert
                       animated:YES
                     completion:nil];

}

- (UserLocationManager *) locationManager {
    if (!_locationManager) {
        _locationManager = [[UserLocationManager alloc] init];
        _locationManager.delegate = self;
    }
    return _locationManager;
}

- (GetTrendingVenues *) trendingVenuesObj {
    if (!_trendingVenuesObj) {
        _trendingVenuesObj = [[GetTrendingVenues alloc] init];
    }
    return _trendingVenuesObj;
}

- (SearchVenues *) searchVenuesObj {
    if (!_searchVenuesObj) {
        _searchVenuesObj = [[SearchVenues alloc] init];
    }
    return _searchVenuesObj;
}

#pragma mark tableView methods
- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        VenueTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[VenueTableViewCell reuseIdentifier] forIndexPath:indexPath];
        if (tableView.tag == TRENDING_TABLE_TAG) {
            [cell setVenue:[self.trendingVenuesObj.trendingVenues objectAtIndex:indexPath.row]];

        } else {
            [cell setVenue:[self.searchVenuesObj.searchResults objectAtIndex:indexPath.row]];

        }
        return cell;

    }
    return [[UITableViewCell alloc] init];
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES]; 
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView.tag == TRENDING_TABLE_TAG) {
        return self.trendingVenuesObj.trendingVenues.count;
    } else {
        return self.searchVenuesObj.searchResults.count;
    }
}

#pragma mark APIObjectDelegate methods
- (void) apiCallCompletedSuccesfullyForKlass:(Class)Klass {
    if (Klass == [SearchVenues class]) {
        [_loaderView stopAnimating];
        [self.searchTableView reloadData];
        
    } else if (Klass == [GetTrendingVenues class]) {
        [self.activityIndicatorView stopAnimating];
        [self.trendingTableView reloadData];
    }
}

- (void) apiCallFailedForForKlass:(Class)Klass withError:(NSError *)error {
    if (Klass == [SearchVenues class]) {
        
    } else if (Klass == [GetTrendingVenues class]) {
        [self.activityIndicatorView stopAnimating];
        [self showAlertWithMessage:@"Oops! something went wrong"];
    }
}

- (void) showAlertWithMessage: (NSString *)message {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@""
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK"
                                                       style:UIAlertActionStyleDefault
                                                     handler:nil];
    [alert addAction:okAction];
    [self presentViewController:alert animated:YES completion:nil];
    
}
#pragma mark UISearchBarDelegate method
- (void) searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [_searchBar resignFirstResponder];
    [_searchBar setShowsCancelButton:NO animated:YES];
    [_searchBar setText:@""];
    _searchText = @"";
    [self handleSearch];
    [self shouldShowSearchTable:NO];
}

- (void) searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    [searchBar setShowsCancelButton:YES animated:YES];
    [self shouldShowSearchTable:YES];

}

- (void) searchBarTextDidEndEditing:(UISearchBar *)searchBar {
    
}

- (void) searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    if (searchText.length > 0) {
        _searchText = searchText;
        [self handleSearch];
    } else{
        _searchText = @"";
        [self handleSearch];
    }
    [self toggleTableVisible];
}

- (void) toggleTableVisible {
    
}

- (void) shouldShowSearchTable: (BOOL) shouldShow {

    if (shouldShow) {
        [self.searchTableView setHidden:NO];
        self.searchTableHeightConstraint.active = NO;
        self.searchTableBottomConstraint.active = YES;
        self.searchTableBottomConstraint.constant = 0;
        [UIView animateWithDuration:0.2 animations:^{
            [self.view setNeedsLayout];
            [self.view layoutIfNeeded];
        } completion:^(BOOL finished) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.searchTableView reloadData];
            });
        }];
        
    } else {
        self.searchTableBottomConstraint.active = NO;
        self.searchTableHeightConstraint.active = YES;
        self.searchTableHeightConstraint.constant = 0;
        [UIView animateWithDuration:0.2 animations:^{
            [self.view setNeedsLayout];
            [self.view layoutIfNeeded];
        } completion:^(BOOL finished) {
            [self.searchVenuesObj.searchResults removeAllObjects];
            [self.searchTableView setHidden:YES];
        }];
    }
}

- (void) handleSearch {
    if (_searchText.length > 2) {
        [_loaderView startAnimating];
        self.searchVenuesObj.currentLocation = _currentLocationCoordinates;
        [self.searchVenuesObj searchVenuesForKey:_searchText withCallbackDelegate:self];
    }
}

//scrollViewDelegateMethod
- (void) scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    //hide keyboard when user scroll the tableview
    [self.view endEditing:YES];
}

#pragma mark LocationManagerDelegate methods
- (void) setUserCurrentLocation:(CLLocationCoordinate2D)currentLocation {
    //set current location and reload results
    _currentLocationCoordinates = currentLocation;
    NSString *latLonString = [NSString stringWithFormat:@"%f,%f",_currentLocationCoordinates.latitude, _currentLocationCoordinates.longitude];

    [self.activityIndicatorView startAnimating];
    [self.trendingVenuesObj getTrendingVenuesNear:latLonString withCallbackDelegate:self];
}

- (void) locationServiceNotEnabledForTheApp {
    //Show popup to go to settings and change location permission or continue browsing in default location
    [self showAlertWithMessage:@"Please enable location services to browse nearby places"];
}

- (void) locationServicesNotEnabledOnDevice {
    //Show popup to go to settings and change location permission or continue browsing in default location
    [self showAlertWithMessage:@"Looks like location services have been disabled for the device"];

}

- (void) showLocationAlertPopupWithMessage: (NSString *) messageText {
    UIAlertController *servicesDisabledAlert = [UIAlertController alertControllerWithTitle:@"Location Alert!"
                                                                                   message:messageText
                                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *goToSettings = [UIAlertAction actionWithTitle:@"Go to Settings"
                                                           style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * _Nonnull action) {
                                                             [[UIApplication sharedApplication] openURL:[NSURL  URLWithString:UIApplicationOpenSettingsURLString] options:@{} completionHandler:^(BOOL success) {
                                                                 
                                                             }];
                                                         }];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Continue browsing (Default Cupertino)"
                                                     style:UIAlertActionStyleCancel
                                                   handler:^(UIAlertAction * _Nonnull action) {
                                                       //continue browsing in default locations
                                                       NSString *latLonString = [NSString stringWithFormat:@"%f,%f",_currentLocationCoordinates.latitude, _currentLocationCoordinates.longitude];
                                                       [self.activityIndicatorView startAnimating];
                                                       [self.trendingVenuesObj getTrendingVenuesNear:latLonString withCallbackDelegate:self];

                                                   }];
    
    [servicesDisabledAlert addAction:goToSettings];
    [servicesDisabledAlert addAction:cancel];
    [self presentViewController:servicesDisabledAlert animated:YES completion:nil];

}

@end
