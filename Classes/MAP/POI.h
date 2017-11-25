//
//  POI.h
//  FashionGuide
//
//  Created by Franky on 12/17/10.
//  Copyright 2010 Zoaks Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>

@interface POI : NSObject <MKAnnotation> 
{
	CLLocationCoordinate2D coordinate;
	NSString *title;
	NSString *subtitle;
	UIImage *mapImage;
	NSDictionary *sourceData;
}

- (id)initWithCoordinate:(CLLocationCoordinate2D)cord sourceData:(NSDictionary *)rawData;
- (id)initWithPOIDict:(NSDictionary *)poiDict;
- (NSData *)convertImageToData:(UIImage *)image;
- (NSDictionary *)convertToDictionary;
@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;
@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSString *subtitle;
@property (nonatomic, retain) UIImage *mapImage;
@property (nonatomic, readonly, retain) NSDictionary *sourceData;
@end
