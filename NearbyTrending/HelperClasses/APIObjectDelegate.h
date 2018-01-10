//
//  APIObjectDelegate.h
//  NearbyTrending
//
//  Created by Anil Bunkar on 09/01/18.
//  Copyright © 2018 Anil Bunkar. All rights reserved.
//

#ifndef APIObjectDelegate_h
#define APIObjectDelegate_h

@protocol APIObjectDelegate <NSObject>

@required
- (void) apiCallCompletedSuccesfullyForKlass:(Class)Klass;
- (void) apiCallFailedForForKlass:(Class)Klass withError:(NSError *)error;

@end

#endif /* APIObjectDelegate_h */
