//
//  CCDiscountsViewController.m
//  coke
//
//  Created by John on 2011/2/9.
//  Copyright 2011 Zoaks Co., Ltd. All rights reserved.
//

#import "CCDiscountsViewController.h"
#import "CCDiscountDetailViewController.h"
#import "NSManagedObjectContext-EasyFetch.h"

@implementation CCDiscountsViewController
@synthesize _tableView;
- (void)dealloc 
{
	[dataArray release];
    [super dealloc];
}


#pragma mark -
#pragma mark View lifecycle


- (void)viewDidLoad {
    [super viewDidLoad];
	self.tableView.backgroundColor = [UIColor redColor];
//	self.tableView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"Background.png"]];
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}
-(void)refreshDataArray
{
	if (dataArray) {
		[dataArray release];
		dataArray = nil;
	}
	[self.tableView reloadData];
	NSManagedObjectContext *managedObjectContext = [[CoreDataManager sharedManager] managedObjectContext];
	NSArray *queryArray = [managedObjectContext fetchObjectsForEntityName:DiscountEntity sortByKey:DiscountReceiveDate ascending:NO];
	dataArray = [[NSArray alloc] initWithArray:queryArray];
	[self.tableView reloadData];
}
-(IBAction)showHelp
{
    CCHelpViewController *vc = [[CCHelpViewController alloc] init];
    [self.tabBarController presentModalViewController:vc animated:YES];
    [vc release];
    
}
- (void)viewWillAppear:(BOOL)animated 
{
    [super viewWillAppear:animated];
	[self refreshDataArray];
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView 
{
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
    // Return the number of rows in the section.
    return [dataArray count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
		cell.backgroundColor = [UIColor clearColor];
		cell.contentView.backgroundColor = [UIColor clearColor];
		cell.contentView.opaque = NO;
		cell.opaque = NO;
		cell.textLabel.textColor = [UIColor whiteColor];
//		cell.detailTextLabel.textColor = [UIColor whiteColor];
	}
	NSManagedObject *obj = [dataArray objectAtIndex:indexPath.row];
    cell.textLabel.text = [obj valueForKey:DiscountName];
	cell.imageView.image = [UIImage imageWithData:[obj valueForKey:DiscountImage]];
	return cell;
}


#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
	CCDiscountDetailViewController *detailVC = [[CCDiscountDetailViewController alloc] initWithManagedObject:[dataArray objectAtIndex:indexPath.row]];
	UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:detailVC];
	[self presentModalViewController:navController animated:YES];
	[detailVC release];
	[navController release];
}


#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}



@end

