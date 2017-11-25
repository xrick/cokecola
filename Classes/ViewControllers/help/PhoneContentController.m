
#import "PhoneContentController.h"


@implementation PhoneContentController

@synthesize scrollView, pageControl, viewControllers;
@synthesize contentList;

-(int)currentPageNumber
{
	return pageControl.currentPage;
}

-(id) init
{
	self = [super init];
	if (self != nil) {
		[[NSBundle mainBundle]loadNibNamed:@"PhoneContentController" owner:self options:nil];
		// load our data from a plist file inside our app bundle
//		NSString *path = [[NSBundle mainBundle] pathForResource:@"MenuImageItem" ofType:@"plist"];
//		self.contentList = [NSArray arrayWithContentsOfFile:path];
		
		// view controllers are created lazily
		// in the meantime, load the array with placeholders which will be replaced on demand
		NSMutableArray *controllers = [[NSMutableArray alloc] init];
		for (unsigned i = 0; i < kNumberOfPages; i++)
		{
			[controllers addObject:[NSNull null]];
		}
		self.viewControllers = controllers;
		[controllers release];
		
		// a page is the width of the scroll view
		scrollView.pagingEnabled = YES;
		scrollView.contentSize = CGSizeMake(scrollView.frame.size.width * kNumberOfPages, 460);
		scrollView.showsHorizontalScrollIndicator = NO;
		scrollView.showsVerticalScrollIndicator = NO;
		scrollView.scrollsToTop = NO;
		scrollView.delegate = self;
		scrollView.backgroundColor = [UIColor blackColor];

		pageControl.numberOfPages = kNumberOfPages;
		pageControl.currentPage = 0;
		
		// pages are created on demand
		// load the visible page
		// load the page on either side to avoid flashes when the user starts scrolling
		//
		
		//TODO: fix a bug (shift displaying)
//		[self loadScrollViewWithPage:1];
	}
	return self;
}

- (void)dealloc
{
    [viewControllers release];
    [scrollView release];
    [pageControl release];
    [contentList release];
    [super dealloc];
}

- (UIView *)view
{
	[self loadScrollViewWithPage:0];
    [self.scrollView setBackgroundColor:[UIColor redColor]];
    self.scrollView.opaque = NO;
    return self.scrollView;
}

- (void)loadScrollViewWithPage:(int)page
{
    if (page < 0)
        return;
    if (page >= kNumberOfPages)
        return;
    
    // replace the placeholder if necessary
    MenuPagePreviewController *controller = [viewControllers objectAtIndex:page];
    if ((NSNull *)controller == [NSNull null])
    {
//		NSDictionary *numberItem = [self.contentList objectAtIndex:page];

        controller = [[MenuPagePreviewController alloc] initWithPageNumber:page imageNamePrefix:@"png_300_0"];
        [viewControllers replaceObjectAtIndex:page withObject:controller];
        [controller release];
    }
    
    // add the controller's view to the scroll view
    if (controller.view.superview == nil)
    {
        CGRect frame = scrollView.frame;
        frame.origin.x = frame.size.width * page;
        frame.origin.y = 0;
        controller.view.frame = frame;
        [scrollView addSubview:controller.view];
 /*       
        UIImage *ownerImage = [UIImage imageNamed:[NSString stringWithFormat:@"%@.png",[numberItem valueForKey:ImageKey]]];
		[controller.ownerImageButton setImage:ownerImage forState:UIControlStateNormal];
		if (page > 0) {
			UIImage *levelImage = [UIImage imageNamed:[NSString stringWithFormat:@"level%d.png",page]];
			controller.levelImage.image = levelImage;
		}
  */
	}
}

- (void)scrollViewDidScroll:(UIScrollView *)sender
{
    // We don't want a "feedback loop" between the UIPageControl and the scroll delegate in
    // which a scroll event generated from the user hitting the page control triggers updates from
    // the delegate method. We use a boolean to disable the delegate logic when the page control is used.
    if (pageControlUsed)
    {
        // do nothing - the scroll was initiated from the page control, not the user dragging
        return;
    }
	
    // Switch the indicator when more than 50% of the previous/next page is visible
    CGFloat pageWidth = scrollView.frame.size.width;
    int page = floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    pageControl.currentPage = page;
    
    // load the visible page and the page on either side of it (to avoid flashes when the user starts scrolling)
    [self loadScrollViewWithPage:page - 1];
    [self loadScrollViewWithPage:page];
    [self loadScrollViewWithPage:page + 1];
    
    // A possible optimization would be to unload the views+controllers which are no longer visible
}

// At the begin of scroll dragging, reset the boolean used when scrolls originate from the UIPageControl
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    pageControlUsed = NO;
}

// At the end of scroll animation, reset the boolean used when scrolls originate from the UIPageControl
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    pageControlUsed = NO;
}

- (IBAction)changePage:(id)sender
{
    int page = pageControl.currentPage;
	
    // load the visible page and the page on either side of it (to avoid flashes when the user starts scrolling)
    [self loadScrollViewWithPage:page - 1];
    [self loadScrollViewWithPage:page];
    [self loadScrollViewWithPage:page + 1];
    
	// update the scroll view to the appropriate page
    CGRect frame = scrollView.frame;
    frame.origin.x = frame.size.width * page;
    frame.origin.y = 0;
    [scrollView scrollRectToVisible:frame animated:YES];
    
	// Set the boolean used when scrolls originate from the UIPageControl. See scrollViewDidScroll: above.
    pageControlUsed = YES;
}

@end
