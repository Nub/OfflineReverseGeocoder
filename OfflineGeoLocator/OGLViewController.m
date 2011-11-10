//
//  OGLViewController.m
//  OfflineGeoLocator
//
//  Created by Zachry Thayer on 11/4/11.
//  Copyright (c) 2011 Zachry Thayer. All rights reserved.
//

#import "OGLViewController.h"
#import "JSONKit.h"
#import "OfflineReverseGeocoder.h"

@implementation OGLViewController

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)loadView
{
    
    NSDictionary *geoDict = [[NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"ORGsubset" ofType:@"json"] encoding:NSUTF8StringEncoding error:nil] objectFromJSONString];
    
    OfflineReverseGeocoder *quickie = [[OfflineReverseGeocoder alloc] init];
    quickie.geologicalRegions = geoDict;
    
    CLLocationCoordinate2D test = CLLocationCoordinate2DMake(-33.86340000,+151.21100000);
    
    NSDictionary *reverseGeodation = [quickie reverseGeocodeLocation:test];
    
    NSLog(@"%@", reverseGeodation);
    
    UIView *crapView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 300, 300)];
    crapView.backgroundColor = [UIColor whiteColor];
    
    UILabel *location = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 300, 40)];
    [location setNumberOfLines:2];
    location.text = [NSString stringWithFormat:@"Longitude:%f\nLatitude:%f", test.longitude, test.latitude];
    
    UILabel *country = [[UILabel alloc] initWithFrame:CGRectMake(10, 50, 300, 20)];
    country.text = [NSString stringWithFormat:@"%@ - %@",[reverseGeodation objectForKey:kORGCountryKey], [reverseGeodation objectForKey:kORGCountryCodeKey]];
    
    UILabel *region = [[UILabel alloc] initWithFrame:CGRectMake(10, 70, 300, 20)];
    region.text = [NSString stringWithFormat:@"%@ - %@",[reverseGeodation objectForKey:kORGRegionKey], [reverseGeodation objectForKey:kORGRegionCodeKey]];

    [crapView addSubview:location];
    [crapView addSubview:country];
    [crapView addSubview:region];
    
    self.view = crapView;
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

@end
