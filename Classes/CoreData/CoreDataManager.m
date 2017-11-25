//
//  CoreDataManager.m
//
//  Created by John on 2010/5/9.
//  Copyright 2010 zOaks. All rights reserved.
//

#import "CoreDataManager.h"
#import "NSManagedObjectContext-EasyFetch.h"

@implementation CoreDataManager
@synthesize managedObjectContext;
-(void) dealloc
{
	[managedObjectContext release];
    [managedObjectModel release];
    [persistentStoreCoordinator release];
    [super dealloc];
}

- (NSManagedObject *)addDiscount:(NSDictionary *)discountDict;
{
//	NSAssert(![[NSThread currentThread] isMainThread], @"You should run this in background");
//	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	NSManagedObject *newEntry;
	if (![self isExistDiscountForDict:discountDict]) {
		NSString *discount_id = [discountDict objectForKey:@"discount_id"];
		NSString *discount_name = [discountDict objectForKey:@"discount_name"];
		NSString *discountMsg_description = [discountDict objectForKey:@"discountMsg_description"];
		NSString *discountMsg_image = [discountDict objectForKey:@"discountMsg_image"];
		NSString *discount_URL = [discountDict objectForKey:@"discount_url"];

		while (![managedObjectContext tryLock]) {
			;
		}
		newEntry = [NSEntityDescription
									 insertNewObjectForEntityForName:DiscountEntity
									 inManagedObjectContext:managedObjectContext];
		[newEntry setValue:[NSString stringWithFormat:@"%@",discount_id] forKey:DiscountID];
		[newEntry setValue:[NSString stringWithFormat:@"%@",discountMsg_description] forKey:DiscountDescription];
		[newEntry setValue:[NSString stringWithFormat:@"%@",discount_name] forKey:DiscountName];
		[newEntry setValue:[NSString stringWithFormat:@"%@",discountMsg_image] forKey:DiscountImageURL];
		[newEntry setValue:[NSData dataWithContentsOfURL:[NSURL URLWithString:discountMsg_image] options:NSDataReadingUncached error:nil] forKey:DiscountImage];
		[newEntry setValue:[NSDate date] forKey:DiscountReceiveDate];
		if (discount_URL) {
			[newEntry setValue:[NSString stringWithFormat:@"%@",discount_URL] forKey:DiscountLinkURL];
		}
		[self saveCoreData];
		[managedObjectContext unlock];	
	}
	else {
//		NSLog(@"the specified discount data already exists");
		newEntry = [self searchDiscountByDiscountID:[discountDict objectForKey:@"discount_id"]];
		//return nil;
	}
//	NSLog(@"will return entry:%@",newEntry);
//	[pool drain];
	return newEntry;
}

- (NSManagedObject *)searchDiscountByDiscountID:(NSString *)discountID
{
	NSString *predicateString = [NSString stringWithFormat:@"(DiscountID == \"%@\")", discountID];
	NSPredicate *predicate = [NSPredicate predicateWithFormat:predicateString];
	NSArray *queryArray = [managedObjectContext fetchObjectsForEntityName:DiscountEntity withPredicate:predicate];
	if ([queryArray count] == 0) {
		return nil;
	}
	return [queryArray objectAtIndex:0];
}

- (void)removeDiscountByDiscountID:(NSString *)discountID;
{
//	NSAssert(![[NSThread currentThread] isMainThread], @"You should run this in background");
//	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	NSString *predicateString = [NSString stringWithFormat:@"(DiscountID == \"%@\")", discountID];
	NSPredicate *predicate = [NSPredicate predicateWithFormat:predicateString];
	NSArray *queryArray = [managedObjectContext fetchObjectsForEntityName:DiscountEntity withPredicate:predicate];
	while (![managedObjectContext tryLock]) {
		;
	}
	for (NSManagedObject *obj in queryArray) {
		[managedObjectContext deleteObject:obj];
	}
	[self saveCoreData];
	[managedObjectContext unlock];	
//	[pool drain];
}

- (BOOL)isExistDiscountForDict:(NSDictionary *)discountDict;
{
	NSString *discount_id = [discountDict objectForKey:@"discount_id"];
//	NSString *discountMsg_description = [discountDict objectForKey:@"discountMsg_description"];
	
	NSString *predicateString = [NSString stringWithFormat:@"(DiscountID == \"%@\")", discount_id];
	NSPredicate *predicate = [NSPredicate predicateWithFormat:predicateString];
	NSArray *queryArray = [managedObjectContext fetchObjectsForEntityName:DiscountEntity withPredicate:predicate];
	if ([queryArray count] > 0) {
		return YES;
	}
	return NO;	
}

- (void)saveCoreData
{
	NSError *error;
	if (![[self managedObjectContext] save:&error]) {
		NSLog(@"CoreData - Unable To Save: %@", [error description]);
	}
}

#pragma mark -
#pragma mark Core Data stack

/**
 Returns the managed object context for the application.
 If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
 */
- (NSManagedObjectContext *)managedObjectContext 
{
    if (managedObjectContext != nil) {
        return managedObjectContext;
    }
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    
	if (coordinator != nil) {
        managedObjectContext = [[NSManagedObjectContext alloc] init];
        [managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return managedObjectContext;
}


/**
 Returns the managed object model for the application.
 If the model doesn't already exist, it is created by merging all of the models found in the application bundle.
 */
- (NSManagedObjectModel *)managedObjectModel 
{
    if (managedObjectModel != nil) {
        return managedObjectModel;
    }
    managedObjectModel = [[NSManagedObjectModel mergedModelFromBundles:nil] retain];    
    return managedObjectModel;
}


/**
 Returns the persistent store coordinator for the application.
 If the coordinator doesn't already exist, it is created and the application's store added to it.
 */
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator 
{    
    if (persistentStoreCoordinator != nil) {
        return persistentStoreCoordinator;
    }
    
    NSURL *storeUrl = [NSURL fileURLWithPath: [[self applicationDocumentsDirectory] stringByAppendingPathComponent: @".SCCoreData.sqlite"]];
    
    NSError *error = nil;
    persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeUrl options:nil error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
         
         Typical reasons for an error here include:
         * The persistent store is not accessible
         * The schema for the persistent store is incompatible with current managed object model
         Check the error message to determine what the actual problem was.
         */
        ZSLog(@"CoreData : Unresolved error %@, %@", error, [error userInfo]);
    }    
    
    return persistentStoreCoordinator;
}
#pragma mark -
#pragma mark Application's Documents directory

/**
 Returns the path to the application's Documents directory.
 */
- (NSString *)applicationDocumentsDirectory
{
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}

#pragma mark Singleton Methods
+ (id)sharedManager
{
	static CoreDataManager *sharedCoreDataManager = nil;
	if (!sharedCoreDataManager) {
		sharedCoreDataManager = [[CoreDataManager alloc] init];
		//inits variables
		[sharedCoreDataManager persistentStoreCoordinator];
		[sharedCoreDataManager managedObjectModel];
		[sharedCoreDataManager managedObjectContext];
	}
	
	return sharedCoreDataManager;
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
