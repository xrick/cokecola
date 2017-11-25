//
//  ZSLocationManager.m
//  coke
//
//  Created by John on 2011/2/11.
//  Copyright 2011 Zoaks Co., Ltd. All rights reserved.
//

#import "ZSLocationManager.h"


@implementation ZSLocationManager
@synthesize longitude, latitude;
- (id) init
{
	self = [super init];
	if (self != nil) {
		/* 雪花飄 最近任務地點 */
		latitude = 24.992704;
		longitude = 121.544016;
		/* 照相機 可樂瓶資訊 */
//		longitude = 121.544858;
//		latitude = 24.995084;
		/* 可樂辨識 優惠訊息 */
//		longitude = 121.544545;
//		latitude = 24.997875;
		
		ZSLog(@"lon : %f, lat : %f", longitude, latitude);

#if TARGET_IPHONE_SIMULATOR
		
#else
		locationManager = [[CLLocationManager alloc] init];
		locationManager.delegate = self;
		locationManager.desiredAccuracy = kCLLocationAccuracyBest;	
		if (![CLLocationManager locationServicesEnabled]) {
			[self locationManager:locationManager didFailWithError:nil];
		}
		else {
			[locationManager startUpdatingLocation];
		}
#endif
	}
	return self;
}

#pragma mark -
#pragma mark CLLocationManger Delegate
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
	[manager stopUpdatingLocation];
	ZSAlertView *av = [[ZSAlertView alloc] initWithTitle:@"錯誤" message:@"無法定位" delegate:self cancelButtonTitle:@"確定" otherButtonTitles:nil];
	[av show];
	[av release];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
	latitude = newLocation.coordinate.latitude;
	longitude = newLocation.coordinate.longitude;
//	location = newLocation.coordinate;
}

#pragma mark Singleton Methods
+ (id)sharedManager
{
	static ZSLocationManager *sharedLocationManager = nil;
	if (!sharedLocationManager) {
		sharedLocationManager = [[ZSLocationManager alloc] init];
	}
	return sharedLocationManager;
}

- (id)retain 
{
	return self;
}

- (unsigned)retainCount 
{
	return UINT_MAX; // denotes an object that cannot be released
}

- (void)release 
{
	// never release
}

- (id)autorelease 
{
	return self;
}	

@end
