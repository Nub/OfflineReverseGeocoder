//
//  OfflineReverseGeocoder.m
//  OfflineReverseGeocoder
//
//  Created by Zachry Thayer on 11/4/11.
//  Copyright (c) 2011 Zachry Thayer. All rights reserved.
//

#import "OfflineReverseGeocoder.h"

@interface OfflineReverseGeocoder ()


- (UIBezierPath*)bezierPathForGeographicalPolygon:(NSArray*)polygonPoints;
- (BOOL)point:(CGPoint)point isInPolygon:(NSArray*)polygon;

- (NSString*)countryForLocation:(CLLocationCoordinate2D)location;
- (NSString*)regionForLocation:(CLLocationCoordinate2D)location inCountry:(NSString*)country;

@end

@implementation OfflineReverseGeocoder

@synthesize geologicalRegions;

- (NSDictionary*)reverseGeocodeLocation:(CLLocationCoordinate2D)location{
    
    NSString *thisCountryName = [self countryForLocation:location];
    
    if (!thisCountryName) {
        return nil;
    }
    
    NSMutableDictionary *reverseGeocode = [NSMutableDictionary dictionary];
    
    [reverseGeocode setObject:thisCountryName forKey:kORGCountryKey];
    
    NSDictionary *allCountries = [geologicalRegions objectForKey:@"Countries"];
    NSDictionary *thisCountry = [allCountries objectForKey:thisCountryName];
    NSString *thisCountryCode = [thisCountry objectForKey:@"Code"];
    
    [reverseGeocode setObject:thisCountryCode forKey:kORGCountryCodeKey];
    
     NSString *thisRegionName = [self regionForLocation:location inCountry:thisCountryName];
    
    if (thisRegionName){
        
        [reverseGeocode setObject:thisRegionName forKey:kORGRegionKey];
        
        NSDictionary *thisCountriesRegions = [thisCountry objectForKey:@"Regions"];
        NSDictionary *thisRegion = [thisCountriesRegions objectForKey:thisRegionName];
        NSString *thisRegionCode = [thisRegion objectForKey:@"Code"];
        
        if (thisRegionCode) {
            [reverseGeocode setObject:thisRegionCode forKey:kORGRegionCodeKey];
        }
        
    }else{
        // No region found
    }
    
    return reverseGeocode;
    
}

#pragma mark - Private Helpers

- (NSString*)countryForLocation:(CLLocationCoordinate2D)location{
    
    NSDictionary *allCountries = [geologicalRegions objectForKey:@"Countries"];
    
    if (!allCountries) {
        return nil;
    }
    
    for (NSString *thisCountryKey in allCountries) {
        
        NSLog(@"%@", thisCountryKey);
        
        NSDictionary *thisCountry = [allCountries objectForKey:thisCountryKey];
        
        NSDictionary *thisCountryBoundingBox = [thisCountry objectForKey:@"BoundingBox"];
        
        CGFloat minX = [[thisCountryBoundingBox objectForKey:@"minX"] floatValue];
        CGFloat maxX = [[thisCountryBoundingBox objectForKey:@"maxX"] floatValue];
        CGFloat minY = [[thisCountryBoundingBox objectForKey:@"minY"] floatValue];
        CGFloat maxY = [[thisCountryBoundingBox objectForKey:@"maxY"] floatValue];
                        
        if (location.latitude > minY && location.latitude < maxY &&
            location.longitude > minX && location.longitude < maxX) {
            
              return thisCountryKey;
            
        }
        
        
    }
    
    return nil;//Nothing was found
    
}

- (NSString*)regionForLocation:(CLLocationCoordinate2D)location inCountry:(NSString*)country{
    
    NSDictionary *allCountries = [geologicalRegions objectForKey:@"Countries"];
    NSDictionary *thisCountry = [allCountries objectForKey:country];
    
    if (!thisCountry) {
        return nil;
    }
    
    NSDictionary *thisCountriesRegions = [thisCountry objectForKey:@"Regions"];
    
    for (NSString *thisRegionKey in thisCountriesRegions) {
        NSDictionary *thisRegion = [thisCountriesRegions objectForKey:thisRegionKey];
        
        CGPoint locationCGPoint = CGPointMake(location.latitude, location.longitude);
        
        UIBezierPath *thisRegionPath = [self bezierPathForGeographicalPolygon:[thisRegion objectForKey:@"Polygon"]];
                
        if ([thisRegionPath containsPoint:locationCGPoint]) {
            thisRegionPath = nil;//ARC release
            
            return thisRegionKey;//Return valid match
            
        }
       
        
        /*if ([self point:locationCGPoint isInPolygon:[thisRegion objectForKey:@"Polygon"]]) {
            return thisRegionKey;//Return valid match

        }*/
        
    }
    
    
    return nil;//Nothing was found
}

- (UIBezierPath*)bezierPathForGeographicalPolygon:(NSArray*)polygonPoints{
    
    if (!polygonPoints) {
        return nil;
    }
    
    if ([polygonPoints count] < 3) {
        return nil;
    }
    
    UIBezierPath *bezierPath = [[UIBezierPath alloc] init];
    
    BOOL firstPoint = YES;
    
    for (NSDictionary *thisPoint in polygonPoints) {
        
        NSNumber *latitudeNumber = [thisPoint objectForKey:@"lat"];
        NSNumber *longitudeNumber = [thisPoint objectForKey:@"lon"];

        CGFloat latitude = [latitudeNumber floatValue];
        CGFloat longitude = [longitudeNumber floatValue];
        CGPoint locationCGPoint = CGPointMake(longitude, latitude);
        
        if (firstPoint) {
            [bezierPath moveToPoint:locationCGPoint];
            firstPoint = NO;
        }else{
            [bezierPath addLineToPoint:locationCGPoint];
        }
        
    }
    
    [bezierPath closePath];
    
    return bezierPath;
}

- (BOOL)point:(CGPoint)point isInPolygon:(NSArray*)polygon{
    
    if (!polygon) {
        return NO;
    }
    
    int polySides = [polygon count];
    
    if (polySides < 3) {
        return NO;
    }
    
    float *polyX = (CGFloat*)malloc(sizeof(float) * polySides);
    float *polyY = (CGFloat*)malloc(sizeof(float) * polySides);
    
    float x = point.x;
    float y = point.y;
    
    int p = 0;
    for (NSDictionary *thisPoint in polygon) {
        
        NSNumber *latitudeNumber = [thisPoint objectForKey:@"lat"];
        NSNumber *longitudeNumber = [thisPoint objectForKey:@"lon"];
        
        polyX[p] = [latitudeNumber floatValue];
        polyY[p] = [longitudeNumber floatValue];
        
        p++;
        
    }
    
        
    int i, j, c = 0;
    for (i = 0, j = polySides-1; i < polySides; j = i++) {
        if ( ((polyY[i]>y) != (polyY[j]>y)) &&
            (x < (polyX[j]-polyX[i]) * (y-polyY[i]) / (polyY[j]-polyY[i]) + polyX[i]) )
            c = !c;
    }
    
    free(polyX);
    free(polyY);
    
    return (BOOL)c;
        
}

@end
