//
//  POI.m
//  FashionGuide
//
//  Created by Franky on 12/17/10.
//  Copyright 2010 Zoaks Co., Ltd. All rights reserved.
//

#import "POI.h"

@implementation POI
@synthesize coordinate, title, subtitle, mapImage, sourceData;

-(void) dealloc
{
	[title release];
	[subtitle release];
	[mapImage release];
	[sourceData release];
	[super dealloc];
}

- (id)initWithCoordinate:(CLLocationCoordinate2D)cord sourceData:(NSDictionary *)rawData
{
	if (self = [super init]) {
		coordinate = cord;
		sourceData = [[NSDictionary alloc] initWithDictionary:rawData];
	}
	
	return self;
}

- (id)initWithPOIDict:(NSDictionary *)poiDict
{
	if (self = [super init]) {
		mapImage = [[UIImage alloc] initWithData:[poiDict objectForKey:@"MapImage"]];
		coordinate.latitude = [[poiDict objectForKey:@"CoordinateLat"] doubleValue];
		coordinate.longitude = [[poiDict objectForKey:@"CoordinateLon"] doubleValue];
		title = [[NSString alloc] initWithString:[poiDict objectForKey:@"PlaceName"]];
		subtitle = [[NSString alloc] initWithString:[poiDict objectForKey:@"Distance"]];
		sourceData = [[NSDictionary alloc] initWithDictionary:[poiDict objectForKey:@"SourceData"]];
	}
	
	return self;
}

- (NSData *)convertImageToData:(UIImage *)image
{
	NSData *imageData = UIImagePNGRepresentation(image); // or UIImageJEPGRepresentation(image);
	return imageData;
}

- (NSDictionary *)convertToDictionary
{
	NSMutableDictionary *poiDict = [NSMutableDictionary dictionary];
	NSNumber *lat = [NSNumber numberWithDouble:coordinate.latitude];
	NSNumber *lon = [NSNumber numberWithDouble:coordinate.longitude];
	[poiDict setObject:[self convertImageToData:mapImage] forKey:@"MapImage"];
	[poiDict setObject:title forKey:@"PlaceName"];
	[poiDict setObject:subtitle forKey:@"Distance"];
	[poiDict setObject:sourceData forKey:@"SourceData"];
	[poiDict setObject:lat forKey:@"CoordinateLat"];
	[poiDict setObject:lon forKey:@"CoordinateLon"];
	return poiDict;
}

@end
