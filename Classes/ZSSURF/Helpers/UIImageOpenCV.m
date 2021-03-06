#import "UIImageOpenCV.h"

@implementation UIImage (OpenCV)

+ (UIImage *)imageWithCVImage:(IplImage *)cvImage 
{
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	// Allocating the buffer for CGImage
	NSData *data = [NSData dataWithBytes:cvImage->imageData length:cvImage->imageSize];
	CGDataProviderRef provider = CGDataProviderCreateWithCFData((CFDataRef)data);
	// Creating CGImage from chunk of IplImage
	CGImageRef imageRef = CGImageCreate(
										cvImage->width, cvImage->height,
										cvImage->depth, cvImage->depth * cvImage->nChannels, cvImage->widthStep,
										colorSpace, kCGImageAlphaNone|kCGBitmapByteOrderDefault,
										provider, NULL, false, kCGRenderingIntentDefault
										);
	// Getting UIImage from CGImage
	UIImage *ret = [UIImage imageWithCGImage:imageRef];
	CGImageRelease(imageRef);
	CGDataProviderRelease(provider);
	CGColorSpaceRelease(colorSpace);
	return ret;
}
+ (UIImage *)imageWithGralyScaleCVImage:(IplImage *)cvImage 
{
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
	// Allocating the buffer for CGImage
	NSData *data = [NSData dataWithBytes:cvImage->imageData length:cvImage->imageSize];
	CGDataProviderRef provider = CGDataProviderCreateWithCFData((CFDataRef)data);
	// Creating CGImage from chunk of IplImage
	CGImageRef imageRef = CGImageCreate(
										cvImage->width, cvImage->height,
										cvImage->depth, cvImage->depth * cvImage->nChannels, cvImage->widthStep,
										colorSpace, kCGImageAlphaNone|kCGBitmapByteOrderDefault,
										provider, NULL, false, kCGRenderingIntentDefault
										);
	// Getting UIImage from CGImage
	UIImage *ret = [UIImage imageWithCGImage:imageRef];
	CGImageRelease(imageRef);
	CGDataProviderRelease(provider);
	CGColorSpaceRelease(colorSpace);
	return ret;}

- (CGContextRef)createARGBBitmapContext 
{
    CGContextRef    context = NULL;
    CGColorSpaceRef colorSpace;
    void *          bitmapData;
    int             bitmapByteCount;
    int             bitmapBytesPerRow;
    
    // Get image width, height. We'll use the entire image.
    size_t pixelsWide = CGImageGetWidth(self.CGImage);
    size_t pixelsHigh = CGImageGetHeight(self.CGImage);
    
    // Declare the number of bytes per row. Each pixel in the bitmap in this
    // example is represented by 4 bytes; 8 bits each of red, green, blue, and
    // alpha.
    bitmapBytesPerRow   = (pixelsWide * 4);
    bitmapByteCount     = (bitmapBytesPerRow * pixelsHigh);
    
    // Use the generic RGB color space.
    colorSpace = CGColorSpaceCreateDeviceRGB();
    if (colorSpace == NULL) {
        return NULL;
    }
    // Allocate memory for image data. This is the destination in memory
    // where any drawing to the bitmap context will be rendered.
    bitmapData = malloc(bitmapByteCount);
    if (bitmapData == NULL) {
        CGColorSpaceRelease(colorSpace);
        return NULL;
    }
    // Create the bitmap context. We want pre-multiplied ARGB, 8-bits
    // per component. Regardless of what the source image format is
    // (CMYK, Grayscale, and so on) it will be converted over to the format
    // specified here by CGBitmapContextCreate.
    context = CGBitmapContextCreate (bitmapData,
                                     pixelsWide,
                                     pixelsHigh,
                                     8,      // bits per component
                                     bitmapBytesPerRow,
                                     colorSpace,
                                     kCGImageAlphaPremultipliedFirst);
    if (context == NULL) {
        free (bitmapData);
    }
    // Make sure and release colorspace before returning
    CGColorSpaceRelease( colorSpace );
    return context;
}

- (IplImage *)cvImage 
{
	
	// Getting CGImage from UIImage
	CGImageRef imageRef = self.CGImage;
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	// Creating temporal IplImage for drawing
	IplImage *iplimage = cvCreateImage(cvSize(self.size.width, self.size.height), IPL_DEPTH_8U, 4);
	// Creating CGContext for temporal IplImage
	CGContextRef contextRef = CGBitmapContextCreate(
													iplimage->imageData, iplimage->width, iplimage->height,
													iplimage->depth, iplimage->widthStep,
													colorSpace, kCGImageAlphaPremultipliedLast|kCGBitmapByteOrderDefault
													);
	// Drawing CGImage to CGContext
	CGContextDrawImage(
					   contextRef,
					   CGRectMake(0, 0, self.size.width, self.size.height),
					   imageRef
					   );
	CGContextRelease(contextRef);
	CGColorSpaceRelease(colorSpace);
	
	// Creating result IplImage
	IplImage *ret = cvCreateImage(cvGetSize(iplimage), IPL_DEPTH_8U, 3);

	cvCvtColor(iplimage, ret, CV_RGBA2RGB);
	cvReleaseImage(&iplimage);
	
	return ret;

}

- (IplImage *)cvGrayscaleImage 
{
    
    IplImage *cvImage = cvCreateImage(cvSize(CGImageGetWidth(self.CGImage), CGImageGetHeight(self.CGImage)), 8, 1);
    
    // Create the bitmap context
    CGContextRef context = [self createARGBBitmapContext];
    if (context == NULL) {
        return nil;
    }
    
    int height,width,step,channels;
    uchar *cvdata;
    int x,y;
    height    = cvImage->height;
    width     = cvImage->width;
    step      = cvImage->widthStep;
    channels  = cvImage->nChannels;
    cvdata      = (uchar *)cvImage->imageData;
//    NSLog(@"cvGrayscaleImage height: %d width: %d", height, width);
    CGRect rect = {{0,0},{width,height}};
    
    // Draw the image to the bitmap context. Once we draw, the memory
    // allocated for the context for rendering will then contain the
    // raw image data in the specified color space.
    CGContextDrawImage(context, rect, self.CGImage);
    
    // Now we can get a pointer to the image data associated with the bitmap
    // context.
    unsigned char *data = (unsigned char*) CGBitmapContextGetData (context);
    if (data != NULL) {
        for(y=0;y<height;y++) {
            for(x=0;x<width;x++) {
                int intensity = 0.30 * data[(4*y*width)+(4*x)+1] + 
                                0.59 * data[(4*y*width)+(4*x)+2] + 
                                0.11 * data[(4*y*width)+(4*x)+3];
                
                
                cvdata[y*step+x*channels+0] = intensity;
                //cvdata[y*step+x*channels+1] = data[(4*y*width)+(4*x)+2];
                //cvdata[y*step+x*channels+2] = data[(4*y*width)+(4*x)+1];
            }
        }
    }
    
    // When finished, release the context
    CGContextRelease(context);
    
    // Free image data memory for the context
    if (data) {
        free(data);
    }
    
    return cvImage;
}


@end
