//
//  CoreDataManager.h
//
//  Created by John on 2010/5/9.
//  Copyright 2010 zOaks. All rights reserved.
//

#import <CoreData/CoreData.h>
#import "CoreDataConstants.h"
@interface CoreDataManager : NSObject  
{
	NSManagedObjectModel *managedObjectModel;
    NSManagedObjectContext *managedObjectContext;
    NSPersistentStoreCoordinator *persistentStoreCoordinator;
}
- (void)removeDiscountByDiscountID:(NSString *)discountID;
- (NSManagedObject *)searchDiscountByDiscountID:(NSString *)discountID;

- (NSManagedObject *)addDiscount:(NSDictionary *)discountDict;
- (BOOL)isExistDiscountForDict:(NSDictionary *)discountDict;
- (void)saveCoreData;
+ (id)sharedManager;

@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (NSString *)applicationDocumentsDirectory;
@end
