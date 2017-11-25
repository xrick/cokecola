#import <Foundation/Foundation.h>
#import <opencv/cv.h>

@interface UIImage (OpenCV) 

+ (UIImage *)imageWithCVImage:(IplImage *)cvImage;
+ (UIImage *)imageWithGralyScaleCVImage:(IplImage *)cvImage;

- (IplImage *)cvImage;

- (IplImage *)cvGrayscaleImage;

@end
