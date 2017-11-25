//
//  CCMissionNearestViewController.h
//  coke
//
//  Created by Franky on 2/8/11.
//  Copyright 2011 Zoaks Co., Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

#import "POI.h"
#import "ZSAnnotationView.h"

@interface CCMissionNearestViewController : UIViewController <MKMapViewDelegate>
{
	NSString *missionID;
	
	IBOutlet MKMapView *mapView;
	CLLocationCoordinate2D location;
	ZSLocationManager *locationManager;
	BOOL shouldMoveToLocation;
	
	int _count;
	BOOL regionChangeCausedBySearching;
}
- (id)initWithMission:(NSString *)inputMissionID;
- (void)sendNearestRequestToServer;
- (void)processLocationAndDropPin:(NSArray *)locationArray;
- (void)showTargetCalloutView:(id)sender;
- (int)getDistanceBetweenCoordinate:(CLLocationCoordinate2D)loc1 and:(CLLocationCoordinate2D)loc2;
@end
