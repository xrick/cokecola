//
//  ZSAVCaptureManager.h
//
//  Created by Chin-Hao Hu on 1/2/11.
//  Copyright 2011 Zoaks Co., Ltd. All rights reserved.
//


#if !TARGET_IPHONE_SIMULATOR

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

struct pixelStructure {
    unsigned char r, g, b, a;
};
struct outPixelStructure {
    unsigned char luma;
};
static const int outImageWidth = 200;
static const int outImageHeight = 200;


@protocol ZSAVCaptureManagerDelegate
@optional
- (void) captureStillImageFailedWithError:(NSError *)error;
- (void) acquiringDeviceLockFailedWithError:(NSError *)error;
- (void) cannotWriteToAssetLibrary;
- (void) assetLibraryError:(NSError *)error forURL:(NSURL *)assetURL;
- (void) someOtherError:(NSError *)error;
- (void) recordingBegan;
- (void) recordingFinished;
- (void) deviceCountChanged;
- (void) captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleImage:(UIImage *)image;
- (void) didCaptureStillImage:(UIImage *)stillImage;
@end

@interface ZSAVCaptureManager : NSObject <AVCaptureVideoDataOutputSampleBufferDelegate>
{
    @private
    AVCaptureSession *_session;
    AVCaptureDeviceInput *_videoInput;
    id <ZSAVCaptureManagerDelegate> _delegate;
    
    AVCaptureDeviceInput *_audioInput;
    AVCaptureMovieFileOutput *_movieFileOutput;
    AVCaptureStillImageOutput *_stillImageOutput;
    AVCaptureVideoDataOutput *_videoDataOutput;
    AVCaptureAudioDataOutput *_audioDataOutput;
    id _deviceConnectedObserver;
    id _deviceDisconnectedObserver;
    UIBackgroundTaskIdentifier _backgroundRecordingID;
	
	NSUInteger counter;
	
	// transform section
	CGColorSpaceRef newColorSpace;
	CGContextRef context;
	struct pixelStructure* pixels;
	CGContextRef outputImageContext;
	struct outPixelStructure* outputImagePixels;
	
	//public size of original image
	CGSize originalImageSize;
}

@property (nonatomic,readonly,retain) AVCaptureSession *session;
@property (nonatomic,readonly,retain) AVCaptureDeviceInput *videoInput;
@property (nonatomic,assign) AVCaptureFlashMode flashMode;
@property (nonatomic,assign) AVCaptureTorchMode torchMode;
@property (nonatomic,assign) AVCaptureFocusMode focusMode;
@property (nonatomic,assign) AVCaptureExposureMode exposureMode;
@property (nonatomic,assign) AVCaptureWhiteBalanceMode whiteBalanceMode;
@property (nonatomic,readonly,getter=isRecording) BOOL recording;
@property (nonatomic,assign) id <ZSAVCaptureManagerDelegate> delegate;
@property (nonatomic,readonly) CGSize originalImageSize;

- (BOOL) setupSessionWithPreset:(NSString *)sessionPreset error:(NSError **)error;
- (NSUInteger) cameraCount;
- (NSUInteger) micCount;
- (void) startRecording;
- (void) stopRecording;
- (void) captureStillImage;
- (BOOL) cameraToggle;
- (BOOL) hasMultipleCameras;
- (BOOL) hasFlash;
- (BOOL) hasTorch;
- (BOOL) hasFocus;
- (BOOL) hasExposure;
- (BOOL) hasWhiteBalance;
- (void) focusAtPoint:(CGPoint)point;
- (void) exposureAtPoint:(CGPoint)point;
- (void) setConnectionWithMediaType:(NSString *)mediaType enabled:(BOOL)enabled;
+ (AVCaptureConnection *)connectionWithMediaType:(NSString *)mediaType fromConnections:(NSArray *)connections;
@end

@interface ZSAVCaptureManager (AVCaptureVideoDataHelper)
- (UIImage *) imageFromSampleBuffer:(CMSampleBufferRef) sampleBuffer;
@end
#endif
