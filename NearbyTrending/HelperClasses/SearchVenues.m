//
//  SearchVenues.m
//  NearbyTrending
//
//  Created by Anil Bunkar on 09/01/18.
//  Copyright © 2018 Anil Bunkar. All rights reserved.
//

#import "SearchVenues.h"
#import "Venue.h"
#import "FSCachingManager.h"

#define CLIENT_ID @"EYOIRHOPWNQS0PE4NXLZCQSWOWDOUSFIYA54HKOQDS0HNPYY"
#define CLIEND_SECRET @"B2EOJYC4KGPTOAUVUBM1AJYEDVZDY14GNOQT40AMQYOP02V4"

#define BASE_URL @"https://api.foursquare.com/v2/venues"

@implementation SearchVenues

- (id) init {
    self = [super init];
    if (self) {
        //initialize caching manager
        _cachingManager = [[FSCachingManager alloc] init];
    }
    return self;
}

- (NSMutableArray *) searchResults {
    if (!_searchResults) {
        _searchResults = [[NSMutableArray alloc] init];
    }
    return _searchResults;
}

- (void) searchVenuesForKey:(NSString *)query withCallbackDelegate:(id<APIObjectDelegate>)callbackDelegate {
    //cancel existing searches
    if (_dataTask) {
        [_dataTask cancel];
    }
    NSString *latLonString = [NSString stringWithFormat:@"%f,%f",_currentLocation.latitude, _currentLocation.longitude];
    
    //we'll table first digit after the decimal in lat and lon so that if user have not moved from location significantly, we show the cached results but if he has moved significantly, show new results
    NSString *queryStringForCache = [NSString stringWithFormat:@"%@_%.1f_%.1f",query, _currentLocation.latitude, _currentLocation.longitude];

    //check if results are available in cache
    NSArray *cachedResults = [self.cachingManager getCachedResultsForQuery:queryStringForCache];
    if (cachedResults) {
        [self.searchResults removeAllObjects];
        [self.searchResults addObjectsFromArray:cachedResults];
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([callbackDelegate respondsToSelector:@selector(apiCallCompletedSuccesfullyForKlass:)]) {
                [callbackDelegate apiCallCompletedSuccesfullyForKlass:[SearchVenues class]];
            }
        });
        return;
    }
    
    NSNumber *limit = @100;
    NSNumber *radius = @100000; //max can be 100kms
    NSString *urlString = [NSString stringWithFormat:@"%@/search?ll=%@&query=%@&limit=%@&client_id=%@&client_secret=%@&v=%@&radius=%@", BASE_URL, latLonString, query, limit, CLIENT_ID, CLIEND_SECRET, [self getVersionParam], radius];
    NSURL *trendingURL = [NSURL URLWithString:urlString];
    NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc] initWithURL:trendingURL];
    urlRequest.HTTPMethod = @"GET";
    
    __weak SearchVenues *weakSelf = self;
    _dataTask = [[NSURLSession sharedSession] dataTaskWithRequest:urlRequest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        if (error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                
                if ([callbackDelegate respondsToSelector:@selector(apiCallFailedForForKlass:withError:)]) {
                    [callbackDelegate apiCallFailedForForKlass:[SearchVenues class] withError:error];
                }
            });
        } else {
            
            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            //get metacode
            NSNumber *code = [json valueForKeyPath:@"meta.code"];
            if (code.integerValue == 200) {
                //call successful, parse data now
                NSArray *venuesArrayObject = [json valueForKeyPath:@"response.venues"];
                NSMutableArray *tempArray = [[NSMutableArray alloc] init];
                for (NSDictionary *venueDict in venuesArrayObject) {
                    Venue *venue = [[Venue alloc] init];
                    [venue parseDataFromObect:venueDict];
                    [tempArray addObject:venue];
                }
                [weakSelf.searchResults removeAllObjects];
                [weakSelf.searchResults addObjectsFromArray:tempArray];
                //cache current search results
                [weakSelf.cachingManager cacheResults:tempArray forQuery:queryStringForCache];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    if ([callbackDelegate respondsToSelector:@selector(apiCallCompletedSuccesfullyForKlass:)]) {
                        [callbackDelegate apiCallCompletedSuccesfullyForKlass:[SearchVenues class]];
                    }
                });
                
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if ([callbackDelegate respondsToSelector:@selector(apiCallFailedForForKlass:withError:)]) {
                        [callbackDelegate apiCallFailedForForKlass:[SearchVenues class] withError:error];
                    }
                });
            }
            
        }

    }];
    [_dataTask resume];
     
}

- (NSString  *) getVersionParam {
    //he Foursquare API no longer supports requests that do not pass in a version parameter. Version param is YYYYMMDD
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"yyyyddMM"];
    NSString *dateString = [dateFormatter stringFromDate:[NSDate date]];
    return dateString;
}

@end
