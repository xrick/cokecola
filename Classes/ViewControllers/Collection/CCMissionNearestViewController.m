//
//  CCMissionNearestViewController.m
//  coke
//
//  Created by Franky on 2/8/11.
//  Copyright 2011 Zoaks Co., Ltd. All rights reserved.
//

#import "CCMissionNearestViewController.h"
#import "CCNetworkAPI.h"
#import "CCPlaceDetailViewController.h"


@implementation CCMissionNearestViewController
- (void)dealloc 
{
	[mapView removeAnnotations:[mapView annotations]];
	[mapView release];
    [super dealloc];
}

- (id)initWithMission:(NSString *)inputMissionID;
{
    self = [super initWithNibName:@"CCMissionNearestViewController" bundle:nil];
    if (self) {
		NSAssert(inputMissionID, @"inputMissionID is nil");
		missionID = [[NSString alloc] initWithString:inputMissionID]; 
        // Custom initialization.
    }
    return self;
}

- (void)processLocationAndDropPin:(NSArray *)locationArray
{
//    NSLog(@"locationArray: %@", locationArray);
	NSAutoreleasePool *thePool = [[NSAutoreleasePool alloc] init];
	for (NSDictionary *obj in locationArray) {
		NSString *name = [NSString stringWithString:[obj objectForKey:@"store_name"]];
//		NSString *addr = [NSString stringWithString:[obj objectForKey:@"store_address"]];
//		NSString *brand = [NSString stringWithString:[obj objectForKey:@"store_brand"]];
//		NSString *sid = [NSString stringWithString:[obj objectForKey:@"store_id"]];
		CLLocationCoordinate2D loc;
		loc.latitude = [[obj objectForKey:@"store_latitude"] doubleValue];
		loc.longitude = [[obj objectForKey:@"store_longitude"] doubleValue];
		POI *target = [[POI alloc] initWithCoordinate:loc sourceData:obj];
		[target setTitle:name];
		[mapView addAnnotation:target];
		[target release];
	}
	[thePool release];
}

- (void)showTargetCalloutView:(id)sender
{
//	[mapView selectAnnotation:target animated:YES];
}

- (int)getDistanceBetweenCoordinate:(CLLocationCoordinate2D)loc1 and:(CLLocationCoordinate2D)loc2
{
	double radians = M_PI / 180;
	double dLon = (loc1.longitude - loc2.longitude) * radians;
	double dLat = (loc1.latitude - loc2.latitude) * radians;
	double a = sin(dLat / 2) * sin (dLat / 2) + cos(loc1.latitude * radians) * cos(loc2.latitude * radians) * sin(dLon / 2) * sin(dLon / 2);
	double c = 2 * atan2(sqrt(a), sqrt(1 - a));
	int d = c * 6371 * 1000;
	
	return d;
}

- (void)viewDidLoad 
{
    [super viewDidLoad];
	shouldMoveToLocation = YES;
	regionChangeCausedBySearching = NO;
	_count = 0;
	
}

-(void) viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	[self sendNearestRequestToServer];
}

- (void)sendNearestRequestToServer
{
	ZSLocationManager *locManager = [ZSLocationManager sharedManager];
	[[CCNetworkAPI requestToURL:kNetworkAPIBaseURL delegate:self] getMissionStoreWithMissionID:missionID longtitude:locManager.longitude latitude:locManager.latitude];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation 
{
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark CCNetworkAPIDelegate
- (void)request:(CCNetworkAPI *)request didGetMissionStore:(NSDictionary *)dict
{
	ZSLog(@"didGetMissionStore:%@",dict);
	locationManager = [ZSLocationManager sharedManager];
	location.longitude = locationManager.longitude;
	location.latitude = locationManager.latitude;
	
	MKCoordinateRegion region;
	region.center=location;
	
	MKCoordinateSpan span;
	span.latitudeDelta=.007;
	span.longitudeDelta=.007;
	region.span=span;
	
	if (shouldMoveToLocation) {
		[mapView setRegion:region animated:YES];
		shouldMoveToLocation = NO;
	}
	
#ifndef TARGET_IPHONE_SIMULATOR
	[mapView setShowsUserLocation:YES];
#endif
	[self processLocationAndDropPin:[dict objectForKey:@"store"]];
	[request release];
}

- (void)request:(CCNetworkAPI *)request didFailGetMissionStoreWithError:(NSError *)error
{
	ZSLog(@"didFailGetMissionStoreWithError:%@",error);
	[request release];
}

- (void)request:(CCNetwork *)request hadStatusCodeError:(int)errorCode
{
	ZSLog(@"hadStatusCodeError: %d", errorCode);
	[request release];

}

#pragma mark -
#pragma mark MKMapView Delegate
- (void)mapView:(MKMapView *)imapView regionDidChangeAnimated:(BOOL)animated
{
	if (regionChangeCausedBySearching) {
		[self performSelector:@selector(showTargetCalloutView:)	withObject:nil afterDelay:0.5];
	}
	regionChangeCausedBySearching = NO;
}

- (MKAnnotationView *)mapView:(MKMapView *)imapView viewForAnnotation:(id <MKAnnotation>)annotation 
{
	ZSAnnotationView *annView = nil;
	
	if ([annotation isMemberOfClass:[POI class]]) {
		annView = (ZSAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:@"poi"];
		if (annView == nil) {
			annView = [[[ZSAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"poi"] autorelease];
		}
	}
	return annView;
}

- (void)mapView:(MKMapView *)imapView annotationView:(MKAnnotationView *)annView calloutAccessoryControlTapped:(UIControl *)control
{	
	for (UIView *subView in [annView subviews]) {
		for (UIView *subSubBiew in [subView subviews]) {
			if ([subSubBiew isMemberOfClass:[UIButton class]]) {
				subSubBiew.hidden = YES; // Hide Right Callout Accessory View
			}
		}
	}
	NSArray *annotations = [imapView selectedAnnotations];
	POI *target = [annotations objectAtIndex:0];
	[mapView setCenterCoordinate:target.coordinate animated:NO];
	//	[mapView setShowsUserLocation:NO];
	
//	UIGraphicsBeginImageContextWithOptions(imapView.frame.size, NO, 0.0);
	UIGraphicsBeginImageContext(imapView.frame.size);
	CGContextRef context = UIGraphicsGetCurrentContext();
	[[imapView layer] renderInContext:context];
	UIImage *mapImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
	[mapView setShowsUserLocation:YES];
	//	CGRect mapFrame = [imapView bounds];
	
	//	CGRect imgRect = CGRectMake(mapFrame.size.width / 2 - 32, mapFrame.size.height / 2 - 40, 320, 260);
	CGRect imgRect = CGRectMake(0, 100, 320, 260);
	
	CGImageRef mapCropped = CGImageCreateWithImageInRect(mapImage.CGImage, imgRect);
	
	UIGraphicsBeginImageContext(CGSizeMake(320, 260));
	context = UIGraphicsGetCurrentContext();
	CGAffineTransform flipVertical = CGAffineTransformMake(1, 0, 0, -1, 0, 260);
	CGContextConcatCTM(context, flipVertical);
	CGContextDrawImage(context, CGRectMake(0, 0, 320, 260), mapCropped);
	CGImageRelease(mapCropped);
	CGContextSetRGBStrokeColor(context, 0, 0, 0, 1);
	CGContextStrokeRectWithWidth(context, CGRectMake(0, 0, 320, 260), 1);
	UIImage *imgCropped = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	target.mapImage = imgCropped;
	
	[mapView deselectAnnotation:target animated:NO];
	CCPlaceDetailViewController *ctrlPlaceDetail = [[CCPlaceDetailViewController alloc] initWithPOI:target];
	[self.navigationController pushViewController:ctrlPlaceDetail animated:YES];
	[ctrlPlaceDetail release];
}

@end
