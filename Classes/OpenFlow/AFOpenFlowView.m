/**
 * Copyright (c) 2009 Alex Fajkowski, Apparent Logic LLC
 *
 * Permission is hereby granted, free of charge, to any person
 * obtaining a copy of this software and associated documentation
 * files (the "Software"), to deal in the Software without
 * restriction, including without limitation the rights to use,
 * copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following
 * conditions:
 * 
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
 * OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
 * HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
 * WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
 * OTHER DEALINGS IN THE SOFTWARE.
 */
#import "AFOpenFlowView.h"
#import "AFOpenFlowConstants.h"
#import "AFUIImageReflection.h"


@interface AFOpenFlowView (hidden)

- (void)resetDataState;
- (void)setDefaults;
- (void)setUpInitialState;
- (AFItem *)coverForIndex:(NSInteger)coverIndex;
- (void)layoutCovers:(int)selected fromCover:(NSInteger)lowerBound toCover:(NSInteger)upperBound;
- (void)layoutCover:(AFItem *)aCover 
		 inPosition:(NSInteger)position 
	  selectedCover:(NSInteger)selectedIndex 
		   animated:(Boolean)animated;
- (void) layoutCovers;
- (AFItem *)findCoverOnscreen:(CALayer *)targetLayer;

@end

@implementation AFOpenFlowView

@synthesize dataSource; 
@synthesize viewDelegate;

@synthesize continousLoop; 
@synthesize coverSpacing; 
@synthesize centerCoverOffset; 
@synthesize sideCoverAngle; 
@synthesize sideCoverZPosition; 
@synthesize coverBuffer; 
@synthesize dragDivisor; 
@synthesize reflectionFraction; 
@synthesize coverHeightOffset; 
@synthesize coverImageSize; 

@synthesize backingColor; 

@synthesize numberOfImages; 
@synthesize defaultImage;
@synthesize selectedCoverView;

@synthesize allScreenCovers;
@synthesize onScreenCovers;

#pragma mark Utility Methods 

NS_INLINE NSRange NSMakeRangeToIndex(NSUInteger loc, NSUInteger loc2) {
    NSRange r;
    r.location = loc;
    r.length = loc2 + 1 - loc;
    return r;
}

- (void)dealloc {
	self.dataSource = nil; 
	self.viewDelegate = nil; 
	self.defaultImage = nil; 
	self.selectedCoverView = nil; 
	
	self.allScreenCovers = nil; 
	self.onScreenCovers = nil;
	
	[super dealloc];
}

#pragma mark Accessor 

- (void) setDataSource:(id <AFOpenFlowViewDataSource>)ds {
	if (ds != dataSource) {
		[ds retain]; 
		[dataSource release];
		dataSource = ds; 
		[self setDefaults]; // This is needed or you will get errors loading from a nib!
		[self reloadData];
	}
}

#pragma mark Hidden Implementation details

- (void)resetDataState {
	// Set up the default image for the coverflow.
	self.defaultImage = [self.dataSource defaultImage];
	
	if (self.allScreenCovers == nil) {
		self.allScreenCovers = [[[NSMutableDictionary alloc] init] autorelease];
	}
	
	if (self.onScreenCovers == nil) {
		self.onScreenCovers = [[[NSMutableDictionary alloc] init] autorelease];
	} else {
		for (AFItem *cover in [self.onScreenCovers allValues]) {
			[cover.imageLayer removeFromSuperlayer]; 
		}
		[self.onScreenCovers removeAllObjects];
	}
}

- (void)setDefaults {
	self.coverSpacing = COVER_SPACING;
	self.centerCoverOffset = CENTER_COVER_OFFSET;
	self.sideCoverAngle = SIDE_COVER_ANGLE;
	self.sideCoverZPosition = SIDE_COVER_ZPOSITION;
	self.coverBuffer = COVER_BUFFER;
	self.dragDivisor = DRAG_DIVISOR;
	self.reflectionFraction = REFLECTION_FRACTION;
	self.coverHeightOffset = COVER_HEIGHT_OFFSET;
	self.coverImageSize = COVER_IMAGE_SIZE; //TODO: Check this might not be used. 
	
	self.backingColor = self.backgroundColor; 
}

- (void)setUpInitialState {
	[self resetDataState]; 
	
	self.multipleTouchEnabled = NO;
	self.userInteractionEnabled = YES;
	self.autoresizesSubviews = YES;
	self.layer.position = CGPointMake(self.frame.origin.x + self.frame.size.width / 2, 
									  self.frame.origin.y + self.frame.size.height / 2);
	
	// Initialize the visible and selected cover range.
	selectedCoverView = nil;
	
	// Set up the cover's left & right transforms.
	leftTransform = CATransform3DIdentity;
	leftTransform = CATransform3DRotate(leftTransform, self.sideCoverAngle, 0.0f, 1.0f, 0.0f);
	rightTransform = CATransform3DIdentity;
	rightTransform = CATransform3DRotate(rightTransform, self.sideCoverAngle, 0.0f, -1.0f, 0.0f);
	
	// Set some perspective
	CATransform3D sublayerTransform = CATransform3DIdentity;
	sublayerTransform.m34 = -0.01;
	[self.layer setSublayerTransform:sublayerTransform];
}

- (AFItem *)coverForIndex:(NSInteger)coverIndex {
	AFItem *cover = [self.allScreenCovers objectForKey:[NSNumber numberWithInt:coverIndex]];
	
	if (!cover) {
		cover = [[[AFItem alloc] init] autorelease];
		cover.number = coverIndex;
		[self.allScreenCovers setObject:cover forKey:[NSNumber numberWithInt:coverIndex]];
	} 
	
	if (! cover.imageRequested) {	//Request we load in the image. 
		[cover setImage:self.defaultImage backingColor:self.backingColor];
		cover.imageRequested = YES;
		[self.dataSource openFlowView:self requestImageForIndex:cover.number];	
	}
	
	return cover;
}

#pragma mark Cover Layout Code!

- (void) layoutCovers {	
	//NSLog(@"Laying out sublayers: %@", self.layer.sublayers); 	
	
	if (self.continousLoop) {
		[self layoutCovers:self.selectedCoverView.number 
				 fromCover:self.selectedCoverView.number - self.coverBuffer 
				   toCover:self.selectedCoverView.number + self.coverBuffer];
	} else {
		NSInteger lowerBound = MAX(0, self.selectedCoverView.number - self.coverBuffer);
		NSInteger upperBound = MIN(self.numberOfImages - 1, self.selectedCoverView.number + self.coverBuffer);
		[self layoutCovers:self.selectedCoverView.number fromCover:lowerBound toCover:upperBound];	
	}
}	

- (void)layoutCovers:(NSInteger)selected fromCover:(NSInteger)lowerBound toCover:(NSInteger)upperBound {
	AFItem *cover;
	NSNumber *coverNumber;
	
	NSInteger coverPos = lowerBound - selected;
	if (coverPos > 0) {
		coverPos = lowerBound - (self.numberOfImages + 1); 
	}
	
	for (NSInteger i = lowerBound; i <= upperBound; i++) {
		if (i < 0) {
			coverNumber = [NSNumber numberWithInt:i + self.numberOfImages];
		} else if (i > self.numberOfImages - 1) {
			coverNumber = [NSNumber numberWithInt:i - self.numberOfImages];
		} else {
			coverNumber = [NSNumber numberWithInt:i];
		}
		cover = (AFItem *)[self.onScreenCovers objectForKey:coverNumber];
		[self layoutCover:cover inPosition:coverPos++ selectedCover:selected animated:YES];
	}
}

- (void)layoutCover:(AFItem *)aCover 
		 inPosition:(NSInteger)position 
	  selectedCover:(NSInteger)selectedIndex 
		   animated:(Boolean)animated {
	
	CATransform3D newTransform;
	CGFloat newZPosition = self.sideCoverZPosition;
	CGPoint newPosition;
	
	newPosition.x = (self.bounds.size.width / 2) + dragOffset;
	newPosition.y = (self.bounds.size.height / 2) + self.coverHeightOffset;
	
	newPosition.x += position * self.centerCoverOffset; 
	
	if (position < 0) {
		newTransform = leftTransform; 
	} else if (position > 0) {
		newTransform = rightTransform;
	} else {
		newZPosition = 0;
		newTransform = CATransform3DIdentity;
	}

	[CATransaction begin];
		if (animated) {
			[CATransaction setValue:[NSNumber numberWithFloat:0.1f] forKey:kCATransactionAnimationDuration];
		} else {
			[CATransaction setValue:[NSNumber numberWithFloat:0.00f] forKey:kCATransactionAnimationDuration];
		}
		aCover.imageLayer.position = newPosition;
	[CATransaction commit];
	
	
	[CATransaction begin];
		if (animated) {
			[CATransaction setValue:[NSNumber numberWithFloat:0.25f] forKey:kCATransactionAnimationDuration];
		} else {
			[CATransaction setValue:[NSNumber numberWithFloat:0.00f] forKey:kCATransactionAnimationDuration];
		}
		aCover.imageLayer.transform = newTransform;
		aCover.imageLayer.zPosition = newZPosition;
	[CATransaction commit];
}

- (AFItem *)findCoverOnscreen:(CALayer *)targetLayer {
	// See if this layer is one of our covers.
	NSEnumerator *coverEnumerator = [onScreenCovers objectEnumerator];
	AFItem *aCover = nil;
	
	while (aCover = (AFItem *)[coverEnumerator nextObject]) {
		if ([aCover.imageLayer isEqual:targetLayer]) {
			return aCover;
		}
	}
	
	return nil; 
}

#pragma mark View Management 

- (void)awakeFromNib {
	[self setBackgroundColor:[UIColor blackColor]]; // TODO: Add by Zoaks
	[self setDefaults];
	[self setUpInitialState];
}

- (id)initWithFrame:(CGRect)frame {
	if (self = [super initWithFrame:frame]) {
		[self setDefaults];
		[self setUpInitialState];
	}
	
	return self;
}

- (void) layoutSubviews {
	[self layoutCovers];
	[super layoutSubviews];
}

#pragma mark Data Management Code

- (void)setNumberOfImages:(NSInteger)newNumberOfImages {
	numberOfImages = newNumberOfImages;

	NSInteger lowerBound = MAX(0, selectedCoverView.number - self.coverBuffer);
	NSInteger upperBound = MIN(self.numberOfImages - 1, selectedCoverView.number + self.coverBuffer);
	
	if (selectedCoverView) {
		[self layoutCovers:selectedCoverView.number fromCover:lowerBound toCover:upperBound];
	} else {
		[self setSelectedCover:0];
	}
}

- (void)setDefaultImage:(UIImage *)newDefaultImage {
	if (newDefaultImage != defaultImage) {
		defaultImageHeight = newDefaultImage.size.height;
		if (newDefaultImage) {
			defaultImage = [[newDefaultImage addImageReflection:self.reflectionFraction] retain];
		} else {
			[defaultImage release]; 
			defaultImage = nil; 
		}
	}
}

- (void)setImage:(UIImage *)image forIndex:(NSInteger)index {
	// Create a reflection for this image.
	UIImage *imageWithReflection = [image addImageReflection:self.reflectionFraction];

	AFItem *cover = [self coverForIndex:index];
	if (cover) {
		[cover setImage:imageWithReflection backingColor:self.backingColor];
	}
	[self layoutCovers];
}

#pragma mark Touch management 

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	startPoint = [[touches anyObject] locationInView:self];
	
	isDraggingACover = NO;
	
	// Which cover did the user tap?
	CALayer *targetLayer = (CALayer *)[self.layer hitTest:startPoint];
	AFItem *targetCover = [self findCoverOnscreen:targetLayer];
	isDraggingACover = (targetCover != nil);

	beginningCover = selectedCoverView.number;

	isSingleTap = ([touches count] == 1);
	
	selectedCoverAtDragStart = selectedCoverView.number;

    if ([self.viewDelegate respondsToSelector:@selector(openFlowViewScrollingDidBegin:)]) {
        [self.viewDelegate openFlowViewScrollingDidBegin:self];
	}
}


- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	isSingleTap = NO;
	isDoubleTap = NO;
	
	CGPoint movedPoint = [[touches anyObject] locationInView:self];
	dragOffset = (movedPoint.x - startPoint.x) / self.dragDivisor;  
	NSInteger newCoverDiff = (dragOffset * -1) / self.coverSpacing;
	
	dragOffset = dragOffset + (newCoverDiff * self.coverSpacing); 
	
	if (newCoverDiff != 0) { 
		NSInteger newSelectedCover = selectedCoverAtDragStart + newCoverDiff;
		
		if (newSelectedCover == self.selectedCoverView.number) {
			[self layoutCovers]; 
		} else {
			if (self.continousLoop) {
				[self setSelectedCover:newSelectedCover];
			} else {
				if (newSelectedCover < 0) {
					[self setSelectedCover:0];
				} else if (newSelectedCover >= self.numberOfImages) {
					[self setSelectedCover:self.numberOfImages - 1];
				} else {
					[self setSelectedCover:newSelectedCover];
				}
			}
		}
	} else {
		[self layoutCovers]; 
	}
		
	if ([self.viewDelegate respondsToSelector:@selector(openFlowViewAnimationDidBegin:)]) {
        [self.viewDelegate openFlowViewAnimationDidBegin:self];
	}
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	
	dragOffset = 0.0; 

	if (isSingleTap) {
		// Which cover did the user tap?
		CGPoint targetPoint = [[touches anyObject] locationInView:self];
		CALayer *targetLayer = (CALayer *)[self.layer hitTest:targetPoint];
		AFItem *targetCover = [self findCoverOnscreen:targetLayer];
		if (targetCover && (targetCover.number != selectedCoverView.number)) {
			[self setSelectedCover:targetCover.number];
		}
	}
	
	// And send the delegate the newly selected cover message.
	if (beginningCover == selectedCoverView.number) {
        // Tap?
        if([[event allTouches] count]==1) {
            UITouch *touch = [[event allTouches] anyObject];    
            if ([touch tapCount] == 1) {
                if ([self.viewDelegate respondsToSelector:@selector(openFlowView:didTap:)])
                    [self.viewDelegate openFlowView:self didTap:selectedCoverView.number];
            } else if ([touch tapCount] == 2) {
                if ([self.viewDelegate respondsToSelector:@selector(openFlowView:didDoubleTap:)])
                    [self.viewDelegate openFlowView:self didDoubleTap:selectedCoverView.number];            
            }   
            
        }    
    } else {
		if ([self.viewDelegate respondsToSelector:@selector(openFlowView:selectionDidChange:)])
			[self.viewDelegate openFlowView:self selectionDidChange:selectedCoverView.number];
    }
	
	[self layoutCovers];
	
    // End of scrolling 
    if ([self.viewDelegate respondsToSelector:@selector(openFlowViewScrollingDidEnd:)]) {
        [self.viewDelegate openFlowViewScrollingDidEnd:self];    
	}
}

- (void)reloadData {
	[self resetDataState];
	self.numberOfImages = [self.dataSource numberOfImagesInOpenView:self];
}

- (NSIndexSet *) coverIndexSetForSelectedCoverIndex:(NSInteger)selectedCoverIndex {
	NSMutableIndexSet *onScreenCoversIndex; 
	
	if (self.continousLoop) {
		if (selectedCoverIndex - self.coverBuffer >= 0 && selectedCoverIndex + self.coverBuffer < self.numberOfImages) {
			onScreenCoversIndex = [NSMutableIndexSet indexSetWithIndexesInRange:NSMakeRange(selectedCoverIndex - self.coverBuffer, (self.coverBuffer * 2 + 1))];
		} else {
			if (selectedCoverIndex - self.coverBuffer < 0) {
				onScreenCoversIndex = [NSMutableIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 
																								selectedCoverIndex + self.coverBuffer + 1)];
	
				[onScreenCoversIndex addIndexesInRange:NSMakeRangeToIndex(self.numberOfImages + selectedCoverIndex - self.coverBuffer, self.numberOfImages - 1)]; //Covers at the end for loop 
				
			} else {
				onScreenCoversIndex = [NSMutableIndexSet indexSetWithIndexesInRange:NSMakeRangeToIndex(selectedCoverIndex - self.coverBuffer, 
																								self.numberOfImages - 1)];
				[onScreenCoversIndex addIndexesInRange:NSMakeRange(0, (selectedCoverIndex + self.coverBuffer) - self.numberOfImages + 1)]; //Covers at the start for loop
			}
		}
	} else {
		onScreenCoversIndex = [NSMutableIndexSet indexSetWithIndexesInRange:NSMakeRangeToIndex(MAX(0, selectedCoverIndex - self.coverBuffer), 
																						MIN(self.numberOfImages - 1, selectedCoverIndex + self.coverBuffer))];
	}	
	return onScreenCoversIndex; 
}

- (void)setSelectedCover:(NSInteger)newSelectedCover {
	//Don't do anything if the currently selectedCover is the newSelectedCover. 
	if (selectedCoverView && (newSelectedCover == selectedCoverView.number)) {
		return;
	}

	if (newSelectedCover < 0) {
		newSelectedCover = self.numberOfImages + newSelectedCover; 
	} else if (newSelectedCover > self.numberOfImages - 1) {
		newSelectedCover = newSelectedCover - self.numberOfImages; 
	}
	
	NSIndexSet *onScreenCoversIndex = [self coverIndexSetForSelectedCoverIndex:newSelectedCover]; 
	for (AFItem *cover in [self.onScreenCovers allValues]) {	//TODO: iOS4.0 enumerateKeysAndObjectsUsingBlock:
		if (! [onScreenCoversIndex containsIndex:cover.number]) {
			[cover.imageLayer removeFromSuperlayer];
			[self.onScreenCovers removeObjectForKey:[NSNumber numberWithInt:cover.number]];
		}
	}

	for (NSInteger i = 0; i < self.numberOfImages; i++) { 
		if ([onScreenCoversIndex containsIndex:i]) { //TODO: Implement using enumerateIndexesUsingBlock: iOS 4.0 only!
			//Add to screen. 
			AFItem *cover = [onScreenCovers objectForKey:[NSNumber numberWithInt:i]];
			if (cover == nil) {
				cover = [self coverForIndex:i];;
				[onScreenCovers setObject:cover forKey:[NSNumber numberWithInt:i]];
				[self.layer addSublayer:cover.imageLayer];
				NSInteger coverPos = 0; 
				if (cover.number >= newSelectedCover - self.coverBuffer && 
					cover.number <= newSelectedCover + self.coverBuffer) {
					coverPos = cover.number - newSelectedCover;
				} else if (cover.number >= newSelectedCover + self.coverBuffer) { //newSelectedCover near 0 with cont looping. 
					coverPos = cover.number - (newSelectedCover + self.numberOfImages); 
				} else { //newSelectedCover near number of Images with cont looping.
					coverPos = (self.numberOfImages - newSelectedCover) + cover.number + 1;
				}
				
				[self layoutCover:cover 
					   inPosition:coverPos 
					selectedCover:newSelectedCover 
						 animated:NO];
			}
		}
	}
	

	
	self.selectedCoverView = [onScreenCovers objectForKey:[NSNumber numberWithInt:newSelectedCover]];
	
	[self layoutCovers];
}


- (void)layoutCoverAnimationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context {
    if ([self.viewDelegate respondsToSelector:@selector(openFlowViewAnimationDidEnd:)]) {
        [self.viewDelegate openFlowViewAnimationDidEnd:self];    
	}
}

- (void)dismissFlippedAnimationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context {
	// Same as layoutCoverAnimationDidStop: for now
    if ([self.viewDelegate respondsToSelector:@selector(openFlowViewAnimationDidEnd:)]) {
        [self.viewDelegate openFlowViewAnimationDidEnd:self];    
	}
}


@end