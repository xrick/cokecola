

#import "MenuPagePreviewController.h"
@implementation MenuPagePreviewController


// load the view nib and initialize the pageNumber ivar
- (id)initWithPageNumber:(int)page imageNamePrefix:(NSString *)prefix
{
	self = [super initWithNibName:@"MenuPagePreviewController" bundle:nil];
    if (self != nil)
    {
		imageNamePrefix = [[NSString alloc] initWithString:prefix];
        pageNumber = page;
    }
    return self;
}
-(void) viewDidLoad
{
	[super viewDidLoad];
    UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"%@%d.png",imageNamePrefix,pageNumber + 1]];
//	[self.view setBackgroundColor:[UIColor colorWithPatternImage:image]];
    imageView.image = image;
    [self.view addSubview:[imageView autorelease]];
    self.view.opaque = NO;
}
- (void)dealloc
{
	[imageNamePrefix release];
    [super dealloc];
}


@end
