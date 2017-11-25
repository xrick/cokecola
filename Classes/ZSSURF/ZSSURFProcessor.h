//
//  ZSSURFProcessor.h
//  coke
//
//  Created by Franky on 1/23/11.
//  Copyright 2011 Zoaks Co., Ltd. All rights reserved.
//

#include <opencv2/objdetect/objdetect.hpp>
#include <opencv2/features2d/features2d.hpp>
#include <opencv2/imgproc/imgproc_c.h>

double compareSURFDescriptors(const float* d1, const float* d2, double best, int length);
int naiveNearestNeighbor(const float* vec, int laplacian, const CvSeq* model_keypoints, const CvSeq* model_descriptors);
void findPairs(const CvSeq* objectKeypoints, const CvSeq* objectDescriptors, const CvSeq* imageKeypoints, const CvSeq* imageDescriptors, vector<int>& ptpairs);

@interface ZSSURFProcessor : NSObject 
{
	CvMemStorage* storage;
	
	IplImage* modelImage;
	CvSeq *modelKeypoints;
	CvSeq *modelDescriptors;
}
- (void)addModelImage:(IplImage *)image;
- (NSUInteger)compareWithImage:(IplImage *)image;
@end
