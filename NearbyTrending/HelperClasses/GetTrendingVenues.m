//
//  GetTrendingVenues.m
//  NearbyTrending
//
//  Created by Anil Bunkar on 09/01/18.
//  Copyright © 2018 Anil Bunkar. All rights reserved.
//

#import "GetTrendingVenues.h"
#import "Venue.h"

#define CLIENT_ID @"EYOIRHOPWNQS0PE4NXLZCQSWOWDOUSFIYA54HKOQDS0HNPYY"
#define CLIEND_SECRET @"B2EOJYC4KGPTOAUVUBM1AJYEDVZDY14GNOQT40AMQYOP02V4"

#define BASE_URL @"https://api.foursquare.com/v2/venues"

@implementation GetTrendingVenues

- (NSMutableArray *) trendingVenues {
    if (!_trendingVenues) {
        _trendingVenues = [[NSMutableArray alloc] init];
    }
    return _trendingVenues;
}

- (void) getTrendingVenuesNear:(NSString *)latLon withCallbackDelegate:(id<APIObjectDelegate>)callbackDelegate {
    
    NSNumber *limit = @50;
    NSNumber *radius = @2000; //radius upto 2000m
    NSString *urlString = [NSString stringWithFormat:@"%@/trending?ll=%@&limit=%@&client_id=%@&client_secret=%@&v=%@&radius=%@", BASE_URL, latLon, limit, CLIENT_ID, CLIEND_SECRET, [self getVersionParam], radius];
    NSURL *trendingURL = [NSURL URLWithString:urlString];
    NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc] initWithURL:trendingURL];
    urlRequest.HTTPMethod = @"GET";
    [urlRequest addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [urlRequest addValue:@"application/json" forHTTPHeaderField:@"Accept"];

    __weak GetTrendingVenues *weakSelf = self;
    NSURLSessionDataTask *dataTask = [[NSURLSession sharedSession] dataTaskWithRequest:urlRequest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        if (error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([callbackDelegate respondsToSelector:@selector(apiCallFailedForForKlass:withError:)]) {
                    [callbackDelegate apiCallFailedForForKlass:[GetTrendingVenues class] withError:error];
                }
            });
        } else {
            
            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            //get metacode
            NSNumber *code = [json valueForKeyPath:@"meta.code"];
            if (code.integerValue == 200) {
                //call successful, parse data now
                [weakSelf.trendingVenues removeAllObjects];
                NSArray *venuesArrayObject = [json valueForKeyPath:@"response.venues"];
                for (NSDictionary *venueDict in venuesArrayObject) {
                    Venue *venue = [[Venue alloc] init];
                    [venue parseDataFromObect:venueDict];
                    [weakSelf.trendingVenues addObject:venue];
                }
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    if ([callbackDelegate respondsToSelector:@selector(apiCallCompletedSuccesfullyForKlass:)]) {
                        [callbackDelegate apiCallCompletedSuccesfullyForKlass:[GetTrendingVenues class]];
                    }
                });
                
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if ([callbackDelegate respondsToSelector:@selector(apiCallFailedForForKlass:withError:)]) {
                        [callbackDelegate apiCallFailedForForKlass:[GetTrendingVenues class] withError:error];
                    }
                });
            }
            
        }
        
    }];
    [dataTask resume];
    
}

- (NSString  *) getVersionParam {
    //he Foursquare API no longer supports requests that do not pass in a version parameter. Version param is YYYYMMDD
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"yyyyddMM"];
    NSString *dateString = [dateFormatter stringFromDate:[NSDate date]];
    return dateString;
}

@end
