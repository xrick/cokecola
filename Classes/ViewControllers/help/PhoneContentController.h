
#import "MenuPagePreviewController.h"

@interface PhoneContentController : NSObject <UIScrollViewDelegate>
{   
    UIScrollView *scrollView;
	UIPageControl *pageControl;
    NSMutableArray *viewControllers;
	NSArray *contentList;

    // To be used when scrolls originate from the UIPageControl
    BOOL pageControlUsed;
}

@property (nonatomic, retain) IBOutlet UIScrollView *scrollView;
@property (nonatomic, retain) IBOutlet UIPageControl *pageControl;
@property (nonatomic, retain) NSArray *contentList;

@property (nonatomic, retain) NSMutableArray *viewControllers;
-(int)currentPageNumber;
- (IBAction)changePage:(id)sender;
- (void)loadScrollViewWithPage:(int)page;
- (void)scrollViewDidScroll:(UIScrollView *)sender;
- (UIView *)view;
@end