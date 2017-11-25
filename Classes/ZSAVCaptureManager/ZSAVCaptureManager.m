//
//  ZSAVCaptureManager.m
//
//  Created by Chin-Hao Hu on 1/2/11.
//  Copyright 2011 Zoaks Co., Ltd. All rights reserved.
//

#import "ZSAVCaptureManager.h"
#if !TARGET_IPHONE_SIMULATOR
#import <MobileCoreServices/UTCoreTypes.h>
#import <AssetsLibrary/AssetsLibrary.h>


@interface ZSAVCaptureManager (AVCaptureFileOutputRecordingDelegate) <AVCaptureFileOutputRecordingDelegate>
@end


@interface ZSAVCaptureManager ()

@property (nonatomic,retain) AVCaptureSession *session;
@property (nonatomic,retain) AVCaptureDeviceInput *videoInput;
@property (nonatomic,retain) AVCaptureDeviceInput *audioInput;
@property (nonatomic,retain) AVCaptureMovieFileOutput *movieFileOutput;
@property (nonatomic,retain) AVCaptureStillImageOutput *stillImageOutput;
@property (nonatomic,retain) AVCaptureVideoDataOutput *videoDataOutput;
@property (nonatomic,retain) AVCaptureAudioDataOutput *audioDataOutput;
@property (nonatomic,retain) id deviceConnectedObserver;
@property (nonatomic,retain) id deviceDisconnectedObserver;
@property (nonatomic,assign) UIBackgroundTaskIdentifier backgroundRecordingID;

@end

@interface ZSAVCaptureManager (Internal)

- (AVCaptureDevice *) cameraWithPosition:(AVCaptureDevicePosition)position;
- (AVCaptureDevice *) frontFacingCamera;
- (AVCaptureDevice *) backFacingCamera;
- (AVCaptureDevice *) audioDevice;
- (NSURL *) tempFileURL;

@end



@implementation ZSAVCaptureManager

@synthesize session = _session;
@synthesize videoInput = _videoInput;
@synthesize audioInput = _audioInput;
@synthesize movieFileOutput = _movieFileOutput;
@synthesize stillImageOutput = _stillImageOutput;
@dynamic flashMode;
@dynamic torchMode;
@dynamic focusMode;
@dynamic exposureMode;
@dynamic whiteBalanceMode;
@synthesize delegate = _delegate;
@synthesize videoDataOutput = _videoDataOutput;
@synthesize audioDataOutput = _audioDataOutput;
@synthesize backgroundRecordingID = _backgroundRecordingID;
@synthesize deviceConnectedObserver = _deviceConnectedObserver;
@synthesize deviceDisconnectedObserver = _deviceDisconnectedObserver;
@synthesize originalImageSize;
- (void) dealloc
{
    [[self session] stopRunning];
    [self setSession:nil];
    [self setVideoInput:nil];
    [self setAudioInput:nil];
    [self setMovieFileOutput:nil];
    [self setStillImageOutput:nil];
    [self setVideoDataOutput:nil];
    [self setAudioDataOutput:nil];
	// transform section
	if (newColorSpace) {
		CGColorSpaceRelease(newColorSpace);
	}
	if (context) {
		CGContextRelease(context);
	}
	if (pixels) {
		free(pixels);
	}
	if (outputImageContext) {
		CGContextRelease(outputImageContext);
	}
	if (outputImagePixels) {
		free(outputImagePixels);
	}
    [super dealloc];
}

- (id) init
{
    self = [super init];
    if (self != nil) {
		counter = 0;
        void (^deviceConnectedBlock)(NSNotification *) = ^(NSNotification *notification) {
            AVCaptureSession *session = [self session];
//            AVCaptureDeviceInput *newAudioInput = [[AVCaptureDeviceInput alloc] initWithDevice:[self audioDevice] error:nil];
            AVCaptureDeviceInput *newVideoInput = [[AVCaptureDeviceInput alloc] initWithDevice:[self backFacingCamera] error:nil];
			
            [session beginConfiguration];
//            [session removeInput:[self audioInput]];
//            if ([session canAddInput:newAudioInput]) {                
//                [session addInput:newAudioInput];
//            }
            [session removeInput:[self videoInput]];
            if ([session canAddInput:newVideoInput]) {
                [session addInput:newVideoInput];
            }
            [session commitConfiguration];
            
//            [self setAudioInput:newAudioInput];
//            [newAudioInput release];
            [self setVideoInput:newVideoInput];
            [newVideoInput release];
            
            id delegate = [self delegate];
            if ([delegate respondsToSelector:@selector(deviceCountChanged)]) {
                [delegate deviceCountChanged];
            }
            
            if (![session isRunning])
                [session startRunning];
        };
        void (^deviceDisconnectedBlock)(NSNotification *) = ^(NSNotification *notification) {
            AVCaptureSession *session = [self session];
            
            [session beginConfiguration];
            
            if (![[[self audioInput] device] isConnected])
                [session removeInput:[self audioInput]];
            if (![[[self videoInput] device] isConnected])
                [session removeInput:[self videoInput]];
            
            [session commitConfiguration];
            
            [self setAudioInput:nil];
            
            id delegate = [self delegate];
            if ([delegate respondsToSelector:@selector(deviceCountChanged)]) {
                [delegate deviceCountChanged];
            }
            
            if (![session isRunning])
                [session startRunning];
        };
        NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
        [self setDeviceConnectedObserver:[notificationCenter addObserverForName:AVCaptureDeviceWasConnectedNotification object:nil queue:nil usingBlock:deviceConnectedBlock]];
        [self setDeviceDisconnectedObserver:[notificationCenter addObserverForName:AVCaptureDeviceWasDisconnectedNotification object:nil queue:nil usingBlock:deviceDisconnectedBlock]];            
    }
    return self;
}

#pragma mark AVCaptureVideoDataOutputSampleBufferDelegate
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection
{ 
	if (counter % 10 == 0) { // delay delegation speed
		id delegate = [self delegate];
		UIImage *sampleImage = [self imageFromSampleBuffer:sampleBuffer];
		if ([delegate respondsToSelector:@selector(captureOutput:didOutputSampleImage:)]) {
			[delegate captureOutput:captureOutput didOutputSampleImage:sampleImage];
		}
	}
	else if (counter == 10000) {
		counter = 0;
	}

	counter++;
}

- (BOOL) setupSessionWithPreset:(NSString *)sessionPreset error:(NSError **)error
{
    BOOL success = NO;
    
    // Init the device inputs
    AVCaptureDeviceInput *videoInput = [[[AVCaptureDeviceInput alloc] initWithDevice:[self backFacingCamera] error:error] autorelease];
    [self setVideoInput:videoInput]; // stash this for later use if we need to switch cameras
    
//    AVCaptureDeviceInput *audioInput = [[[AVCaptureDeviceInput alloc] initWithDevice:[self audioDevice] error:error] autorelease];
//    [self setAudioInput:audioInput];
    
    // Setup the default file outputs
    AVCaptureStillImageOutput *stillImageOutput = [[[AVCaptureStillImageOutput alloc] init] autorelease];
    NSDictionary *outputSettings = [[NSDictionary alloc] initWithObjectsAndKeys:
                                    AVVideoCodecJPEG, AVVideoCodecKey,
                                    nil];
    [stillImageOutput setOutputSettings:outputSettings];
    [outputSettings release];
    [self setStillImageOutput:stillImageOutput];
    
//    AVCaptureMovieFileOutput *movieFileOutput = [[AVCaptureMovieFileOutput alloc] init];
//    [self setMovieFileOutput:movieFileOutput];
//    [movieFileOutput release];
    
	AVCaptureVideoDataOutput *videoDataOutput = [[AVCaptureVideoDataOutput alloc] init];
	[self setVideoDataOutput:videoDataOutput];
	dispatch_queue_t queue;
	queue = dispatch_queue_create("com.AVCapture.VideoData", NULL);
	[videoDataOutput setSampleBufferDelegate:self queue:queue]; 
	// Set the video output to store frame in BGRA 
	NSString* key = (NSString*)kCVPixelBufferPixelFormatTypeKey; 
	NSNumber* value = [NSNumber numberWithUnsignedInt:kCVPixelFormatType_32BGRA]; 
	NSDictionary* videoSettings = [NSDictionary dictionaryWithObject:value forKey:key]; 
	[videoDataOutput setVideoSettings:videoSettings];
	
    // Setup and start the capture session
    AVCaptureSession *session = [[AVCaptureSession alloc] init];
    
    if ([session canAddInput:videoInput]) {
        [session addInput:videoInput];
    }
//    if ([session canAddInput:audioInput]) {
//        [session addInput:audioInput];
//    }
//    if ([session canAddOutput:movieFileOutput]) {
//        [session addOutput:movieFileOutput];
//    }
    if ([session canAddOutput:stillImageOutput]) {
        [session addOutput:stillImageOutput];
    }
	if ([session canAddOutput:videoDataOutput]) {
        [session addOutput:videoDataOutput];
    }
    
    [session setSessionPreset:sessionPreset];
    [session startRunning];
    
    [self setSession:session];
    
    [session release];
    
    success = YES;
    
    return success;
}

- (NSUInteger) cameraCount
{
    return [[AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo] count];
}

- (NSUInteger) micCount
{
    return [[AVCaptureDevice devicesWithMediaType:AVMediaTypeAudio] count];
}

- (BOOL) isRecording
{
    return [[self movieFileOutput] isRecording];
}

- (void) startRecording
{
    if ([[UIDevice currentDevice] isMultitaskingSupported]) {
        [self setBackgroundRecordingID:[[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{}]];
    }
    
    AVCaptureConnection *videoConnection = [ZSAVCaptureManager connectionWithMediaType:AVMediaTypeVideo fromConnections:[[self movieFileOutput] connections]];
    if ([videoConnection isVideoOrientationSupported]) {
        [videoConnection setVideoOrientation:AVCaptureVideoOrientationPortrait];
    }
    
    [[self movieFileOutput] startRecordingToOutputFileURL:[self tempFileURL]
                                        recordingDelegate:self];
}

- (void) stopRecording
{
    [[self movieFileOutput] stopRecording];
}

- (void) captureStillImage
{
    AVCaptureConnection *videoConnection = [ZSAVCaptureManager connectionWithMediaType:AVMediaTypeVideo fromConnections:[[self stillImageOutput] connections]];
    if ([videoConnection isVideoOrientationSupported]) {
        [videoConnection setVideoOrientation:AVCaptureVideoOrientationPortrait];
    }
    
    [[self stillImageOutput] captureStillImageAsynchronouslyFromConnection:videoConnection
                                                         completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
                                                             if (imageDataSampleBuffer != NULL) {
                                                                 NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
                                                                 UIImage *image = [[UIImage alloc] initWithData:imageData];  
																 id delegate = [self delegate];
																 if ([delegate respondsToSelector:@selector(didCaptureStillImage:)]) {
																	 [delegate didCaptureStillImage:image];
																 } 
//                                                                 ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
//                                                                 [library writeImageToSavedPhotosAlbum:[image CGImage]
//                                                                                           orientation:(ALAssetOrientation)[image imageOrientation]
//                                                                                       completionBlock:^(NSURL *assetURL, NSError *error){
//                                                                                           if (error) {
//                                                                                               id delegate = [self delegate];
//                                                                                               if ([delegate respondsToSelector:@selector(captureStillImageFailedWithError:)]) {
//                                                                                                   [delegate captureStillImageFailedWithError:error];
//                                                                                               }                                                                                               
//                                                                                           }
//                                                                                       }];
//                                                                 [library release];
                                                                 [image release];
                                                             } else if (error) {
                                                                 id delegate = [self delegate];
                                                                 if ([delegate respondsToSelector:@selector(captureStillImageFailedWithError:)]) {
                                                                     [delegate captureStillImageFailedWithError:error];
                                                                 }
                                                             }
                                                         }];
}

- (BOOL) cameraToggle
{
    BOOL success = NO;
    
    if ([self hasMultipleCameras]) {
        NSError *error;
        AVCaptureDeviceInput *videoInput = [self videoInput];
        AVCaptureDeviceInput *newVideoInput;
        AVCaptureDevicePosition position = [[videoInput device] position];
        if (position == AVCaptureDevicePositionBack) {
            newVideoInput = [[AVCaptureDeviceInput alloc] initWithDevice:[self frontFacingCamera] error:&error];
        } else if (position == AVCaptureDevicePositionFront) {
            newVideoInput = [[AVCaptureDeviceInput alloc] initWithDevice:[self backFacingCamera] error:&error];
        } else {
            goto bail;
        }
        
        AVCaptureSession *session = [self session];
        if (newVideoInput != nil) {
            [session beginConfiguration];
            [session removeInput:videoInput];
            if ([session canAddInput:newVideoInput]) {
                [session addInput:newVideoInput];
                [self setVideoInput:newVideoInput];
            } else {
                [session addInput:videoInput];
            }
            [session commitConfiguration];
            success = YES;
            [newVideoInput release];
        } else if (error) {
            id delegate = [self delegate];
            if ([delegate respondsToSelector:@selector(someOtherError:)]) {
                [delegate someOtherError:error];
            }
        }
    }
    
bail:
    return success;
}

- (BOOL) hasMultipleCameras
{
    return [[AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo] count] > 1 ? YES : NO;
}

- (BOOL) hasFlash
{
    return [[[self videoInput] device] hasFlash];
}

- (AVCaptureFlashMode) flashMode
{
    return [[[self videoInput] device] flashMode];
}

- (void) setFlashMode:(AVCaptureFlashMode)flashMode
{
    AVCaptureDevice *device = [[self videoInput] device];
    if ([device isFlashModeSupported:flashMode] && [device flashMode] != flashMode) {
        NSError *error;
        if ([device lockForConfiguration:&error]) {
            [device setFlashMode:flashMode];
            [device unlockForConfiguration];
        } else {
            id delegate = [self delegate];
            if ([delegate respondsToSelector:@selector(acquiringDeviceLockFailedWithError:)]) {
                [delegate acquiringDeviceLockFailedWithError:error];
            }
        }    
    }
}

- (BOOL) hasTorch
{
    return [[[self videoInput] device] hasTorch];
}

- (AVCaptureTorchMode) torchMode
{
    return [[[self videoInput] device] torchMode];
}

- (void) setTorchMode:(AVCaptureTorchMode)torchMode
{
    AVCaptureDevice *device = [[self videoInput] device];
    if ([device isTorchModeSupported:torchMode] && [device torchMode] != torchMode) {
        NSError *error;
        if ([device lockForConfiguration:&error]) {
            [device setTorchMode:torchMode];
            [device unlockForConfiguration];
        } else {
            id delegate = [self delegate];
            if ([delegate respondsToSelector:@selector(acquiringDeviceLockFailedWithError:)]) {
                [delegate acquiringDeviceLockFailedWithError:error];
            }
        }
    }
}

- (BOOL) hasFocus
{
    AVCaptureDevice *device = [[self videoInput] device];
    
    return  [device isFocusModeSupported:AVCaptureFocusModeLocked] ||
            [device isFocusModeSupported:AVCaptureFocusModeAutoFocus] ||
            [device isFocusModeSupported:AVCaptureFocusModeContinuousAutoFocus];
}

- (AVCaptureFocusMode) focusMode
{
    return [[[self videoInput] device] focusMode];
}

- (void) setFocusMode:(AVCaptureFocusMode)focusMode
{
    AVCaptureDevice *device = [[self videoInput] device];
    if ([device isFocusModeSupported:focusMode] && [device focusMode] != focusMode) {
        NSError *error;
        if ([device lockForConfiguration:&error]) {
            [device setFocusMode:focusMode];
            [device unlockForConfiguration];
        } else {
            id delegate = [self delegate];
            if ([delegate respondsToSelector:@selector(acquiringDeviceLockFailedWithError:)]) {
                [delegate acquiringDeviceLockFailedWithError:error];
            }
        }    
    }
}

- (BOOL) hasExposure
{
    AVCaptureDevice *device = [[self videoInput] device];
    
    return  [device isExposureModeSupported:AVCaptureExposureModeLocked] ||
            [device isExposureModeSupported:AVCaptureExposureModeAutoExpose] ||
            [device isExposureModeSupported:AVCaptureExposureModeContinuousAutoExposure];
}

- (AVCaptureExposureMode) exposureMode
{
    return [[[self videoInput] device] exposureMode];
}

- (void) setExposureMode:(AVCaptureExposureMode)exposureMode
{
    if (exposureMode == 1) {
        exposureMode = 2;
    }
    AVCaptureDevice *device = [[self videoInput] device];
    if ([device isExposureModeSupported:exposureMode] && [device exposureMode] != exposureMode) {
        NSError *error;
        if ([device lockForConfiguration:&error]) {
            [device setExposureMode:exposureMode];
            [device unlockForConfiguration];
        } else {
            id delegate = [self delegate];
            if ([delegate respondsToSelector:@selector(acquiringDeviceLockFailedWithError:)]) {
                [delegate acquiringDeviceLockFailedWithError:error];
            }
        }
    }
}

- (BOOL) hasWhiteBalance
{
    AVCaptureDevice *device = [[self videoInput] device];
    
    return  [device isWhiteBalanceModeSupported:AVCaptureWhiteBalanceModeLocked] ||
            [device isWhiteBalanceModeSupported:AVCaptureWhiteBalanceModeAutoWhiteBalance];
}

- (AVCaptureWhiteBalanceMode) whiteBalanceMode
{
    return [[[self videoInput] device] whiteBalanceMode];
}

- (void) setWhiteBalanceMode:(AVCaptureWhiteBalanceMode)whiteBalanceMode
{
    if (whiteBalanceMode == 1) {
        whiteBalanceMode = 2;
    }    
    AVCaptureDevice *device = [[self videoInput] device];
    if ([device isWhiteBalanceModeSupported:whiteBalanceMode] && [device whiteBalanceMode] != whiteBalanceMode) {
        NSError *error;
        if ([device lockForConfiguration:&error]) {
            [device setWhiteBalanceMode:whiteBalanceMode];
            [device unlockForConfiguration];
        } else {
            id delegate = [self delegate];
            if ([delegate respondsToSelector:@selector(acquiringDeviceLockFailedWithError:)]) {
                [delegate acquiringDeviceLockFailedWithError:error];
            }
        }
    }
}

- (void) focusAtPoint:(CGPoint)point
{
    AVCaptureDevice *device = [[self videoInput] device];
    if ([device isFocusPointOfInterestSupported] && [device isFocusModeSupported:AVCaptureFocusModeAutoFocus]) {
        NSError *error;
        if ([device lockForConfiguration:&error]) {
            [device setFocusPointOfInterest:point];
            [device setFocusMode:AVCaptureFocusModeAutoFocus];
            [device unlockForConfiguration];
        } else {
            id delegate = [self delegate];
            if ([delegate respondsToSelector:@selector(acquiringDeviceLockFailedWithError:)]) {
                [delegate acquiringDeviceLockFailedWithError:error];
            }
        }        
    }
}

- (void) exposureAtPoint:(CGPoint)point
{
    AVCaptureDevice *device = [[self videoInput] device];
    if ([device isExposurePointOfInterestSupported] && [device isExposureModeSupported:AVCaptureExposureModeContinuousAutoExposure]) {
        NSError *error;
        if ([device lockForConfiguration:&error]) {
            [device setExposurePointOfInterest:point];
            [device setExposureMode:AVCaptureExposureModeContinuousAutoExposure];
            [device unlockForConfiguration];
        } else {
            id delegate = [self delegate];
            if ([delegate respondsToSelector:@selector(acquiringDeviceLockFailedWithError:)]) {
                [delegate acquiringDeviceLockFailedWithError:error];
            }
        }
    }    
}

- (void) setConnectionWithMediaType:(NSString *)mediaType enabled:(BOOL)enabled;
{
    [[ZSAVCaptureManager connectionWithMediaType:mediaType fromConnections:[[self movieFileOutput] connections]] setEnabled:enabled];
}

+ (AVCaptureConnection *)connectionWithMediaType:(NSString *)mediaType fromConnections:(NSArray *)connections;
{
	for ( AVCaptureConnection *connection in connections ) {
		for ( AVCaptureInputPort *port in [connection inputPorts] ) {
			if ( [[port mediaType] isEqual:mediaType] ) {
				return [[connection retain] autorelease];
			}
		}
	}
	return nil;
}

@end

@implementation ZSAVCaptureManager (Internal)

- (AVCaptureDevice *) cameraWithPosition:(AVCaptureDevicePosition) position
{
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *device in devices) {
        if ([device position] == position) {
            return device;
        }
    }
    return nil;
}

- (AVCaptureDevice *) frontFacingCamera
{
    return [self cameraWithPosition:AVCaptureDevicePositionFront];
}

- (AVCaptureDevice *) backFacingCamera
{
    return [self cameraWithPosition:AVCaptureDevicePositionBack];
}

- (AVCaptureDevice *) audioDevice
{
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeAudio];
    if ([devices count] > 0) {
        return [devices objectAtIndex:0];
    }
    return nil;
}

- (NSURL *) tempFileURL
{
    NSString *outputPath = [[NSString alloc] initWithFormat:@"%@%@", NSTemporaryDirectory(), @"output.mov"];
    NSURL *outputURL = [[NSURL alloc] initFileURLWithPath:outputPath];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:outputPath]) {
        NSError *error;
        if ([fileManager removeItemAtPath:outputPath error:&error] == NO) {
            id delegate = [self delegate];
            if ([delegate respondsToSelector:@selector(someOtherError:)]) {
                [delegate someOtherError:error];
            }            
        }
    }
    [outputPath release];
    return [outputURL autorelease];
}

@end


@implementation ZSAVCaptureManager (AVCaptureFileOutputRecordingDelegate)

- (void)             captureOutput:(AVCaptureFileOutput *)captureOutput
didStartRecordingToOutputFileAtURL:(NSURL *)fileURL
                   fromConnections:(NSArray *)connections
{
    id delegate = [self delegate];
    if ([delegate respondsToSelector:@selector(recordingBegan)]) {
        [delegate recordingBegan];
    }
}

- (void)              captureOutput:(AVCaptureFileOutput *)captureOutput
didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL
                    fromConnections:(NSArray *)connections
                              error:(NSError *)error
{
    id delegate = [self delegate];
    if (error && [delegate respondsToSelector:@selector(someOtherError:)]) {
        [delegate someOtherError:error];
    }
    
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    if ([library videoAtPathIsCompatibleWithSavedPhotosAlbum:outputFileURL]) {
        [library writeVideoAtPathToSavedPhotosAlbum:outputFileURL
                                    completionBlock:^(NSURL *assetURL, NSError *error){
                                        if (error && [delegate respondsToSelector:@selector(assetLibraryError:forURL:)]) {
                                            [delegate assetLibraryError:error forURL:assetURL];
                                        }
                                    }];
    } else {
        if ([delegate respondsToSelector:@selector(cannotWriteToAssetLibrary)]) {
            [delegate cannotWriteToAssetLibrary];
        }
    }
    [library release];    
    
    if ([[UIDevice currentDevice] isMultitaskingSupported]) {
        [[UIApplication sharedApplication] endBackgroundTask:[self backgroundRecordingID]];
    }
    
    if ([delegate respondsToSelector:@selector(recordingFinished)]) {
        [delegate recordingFinished];
    }
}
@end

@implementation ZSAVCaptureManager (AVCaptureVideoDataHelper)
// Create a UIImage from sample buffer data
- (UIImage *) imageFromSampleBuffer:(CMSampleBufferRef) sampleBuffer   
{  
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);  
    // Lock the base address of the pixel buffer  
    CVPixelBufferLockBaseAddress(imageBuffer,0);  
	
    // Get the number of bytes per row for the pixel buffer  
    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);   
    // Get the pixel buffer width and height  
    size_t width = CVPixelBufferGetWidth(imageBuffer);   
    size_t height = CVPixelBufferGetHeight(imageBuffer);   
	originalImageSize = CGSizeMake(height, width);
    // Create a device-dependent RGB color space  
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();   
    if (!colorSpace) {  
        ZSLog(@"CGColorSpaceCreateDeviceRGB failure");  
        return nil;  
    }  
	
    // Get the base address of the pixel buffer  
    void *baseAddress = CVPixelBufferGetBaseAddress(imageBuffer);  
    // Get the data size for contiguous planes of the pixel buffer.  
    size_t bufferSize = CVPixelBufferGetDataSize(imageBuffer);   
	
    // Create a Quartz direct-access data provider that uses data we supply  
    CGDataProviderRef provider = CGDataProviderCreateWithData(NULL, baseAddress, bufferSize,   
															  NULL);  
    // Create a bitmap image from data supplied by our data provider  
    CGImageRef cgImage =   
	CGImageCreate(width,  
				  height,  
				  8,  
				  32,  
				  bytesPerRow,  
				  colorSpace,  
				  kCGImageAlphaNoneSkipFirst | kCGBitmapByteOrder32Little,  
				  provider,  
				  NULL,  
				  true,  
				  kCGRenderingIntentDefault);  
    CGDataProviderRelease(provider);  
    CGColorSpaceRelease(colorSpace);  
	
	//transform section
	if (!pixels) {
		pixels = (struct pixelStructure*) calloc(1, width * height * sizeof(struct pixelStructure));	
	}
	if (!outputImagePixels) {
		outputImagePixels = (struct outPixelStructure*) calloc(1, outImageWidth * outImageHeight * sizeof(struct outPixelStructure));	
	}
	if (!newColorSpace) {
		newColorSpace = CGColorSpaceCreateDeviceGray();
	}
	if (!context) {
		context = CGBitmapContextCreate ((void*) pixels, width, height, 8, width * 4, CGImageGetColorSpace(cgImage), kCGImageAlphaPremultipliedLast);
	}
	if (!outputImageContext) {
		outputImageContext = CGBitmapContextCreate ((void*) outputImagePixels, outImageWidth, outImageHeight, 8, outImageWidth * 1, newColorSpace, kCGImageAlphaNone);
	}
	CGContextDrawImage(context, CGRectMake(0.0f, 0.0f, width, height), cgImage);
	CGContextDrawImage(outputImageContext, CGRectMake(0.0f, 0.0f, outImageWidth, outImageHeight), cgImage); // buggy but useful
	
	int startX = width / 2 - outImageWidth / 2;
	int startY = height / 2 - outImageHeight / 2;
	int endX = width / 2 + outImageWidth / 2;
	int endY = height / 2 + outImageHeight / 2;

	for (int y=startY; y<endY; y++) {
		for (int x=startX; x<endX; x++) {
			struct pixelStructure *oldPixel = pixels + (y * width + x);
			double newLuma = oldPixel -> r * 0.299 + oldPixel -> g * 0.587 + oldPixel -> b * 0.114;
			struct outPixelStructure *newPixel = (outputImagePixels + ((outImageWidth - y + startY) + outImageWidth * (x - startX)));
			newPixel -> luma = (unsigned char)newLuma;
		}
	}
 
	CGImageRef outputImage = CGBitmapContextCreateImage(outputImageContext);
	UIImage *image = [UIImage imageWithCGImage:outputImage];  
	CGImageRelease(outputImage);
/*
    // Create and return an image object representing the specified Quartz image  
    UIImage *image = [UIImage imageWithCGImage:cgImage];  
    CGImageRelease(cgImage);  
*/	
    CVPixelBufferUnlockBaseAddress(imageBuffer, 0);  	
    return image;  
}
@end
#endif