//
//  OfflineReverseGeocoder.h
//  OfflineReverseGeocoder
//
//  Created by Zachry Thayer on 11/4/11.
//  Copyright (c) 2011 Zachry Thayer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

#define kORGCountryKey @"Country"
#define kORGCountryCodeKey @"CountryCode"

#define kORGRegionKey @"Region"
#define kORGRegionCodeKey @"RegionCode"

@interface OfflineReverseGeocoder : NSObject

@property (nonatomic, strong) NSDictionary *geologicalRegions;

- (NSDictionary*)reverseGeocodeLocation:(CLLocationCoordinate2D)location;

@end
