//
//  ZSLocationManager.h
//  coke
//
//  Created by John on 2011/2/11.
//  Copyright 2011 Zoaks Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>


@interface ZSLocationManager : NSObject <CLLocationManagerDelegate>
{
	CLLocationManager *locationManager;

	CLLocationDegrees longitude;
	CLLocationDegrees latitude;
}
+ (id)sharedManager;
@property(nonatomic,readonly)CLLocationDegrees longitude;
@property(nonatomic,readonly)CLLocationDegrees latitude;

@end
