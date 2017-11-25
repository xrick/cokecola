
#define kNumberOfPages 6


@interface MenuPagePreviewController : UIViewController
{
    int pageNumber;
	NSString *imageNamePrefix;
    IBOutlet UIImageView *imageView;
}

- (id)initWithPageNumber:(int)page imageNamePrefix:(NSString *)prefix;
@end
