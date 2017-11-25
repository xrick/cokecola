//
//  ZSSURFProcessor.m
//  coke
//
//  Created by Franky on 1/23/11.
//  Copyright 2011 Zoaks Co., Ltd. All rights reserved.
//

#import "ZSSURFProcessor.h"


@implementation ZSSURFProcessor
- (void) dealloc
{
//	cvRelease(&modelKeypoints);
//	cvRelease(&modelDescriptors);
//	cvReleaseMemStorage(&storage);
	cvReleaseImage(&modelImage);
	[super dealloc];
}

- (id) init
{
	self = [super init];
	if (self != nil) {
		storage = cvCreateMemStorage(0);
	}
	return self;
}

- (void)addModelImage:(IplImage *)image
{
	modelImage = image;
//	double tt = (double)cvGetTickCount();
	modelKeypoints = 0;
	modelDescriptors = 0;
	CvSURFParams params = cvSURFParams(500, 1);
	cvExtractSURF(modelImage, 0, &modelKeypoints, &modelDescriptors, storage, params, 0);
//	NSLog(@"Model Descriptors: %d\n", modelDescriptors->total);
//    NSLog(@"Extraction time = %gms\n", tt / (cvGetTickFrequency()*1000));
}

- (NSUInteger)compareWithImage:(IplImage *)image
{
//	double tt = (double)cvGetTickCount();
	CvSeq *imageKeypoints = 0, *imageDescriptors = 0;
    CvSURFParams params = cvSURFParams(500, 1);
	cvExtractSURF(image, 0, &imageKeypoints, &imageDescriptors, storage, params, 0);
//    NSLog(@"Image Descriptors: %d\n", imageDescriptors->total);
	vector<int> ptpairs;
	
	findPairs(modelKeypoints, modelDescriptors, imageKeypoints, imageDescriptors, ptpairs);
	
//	NSLog(@"Detection time = %gms\n", tt / (cvGetTickFrequency()*1000));
//	cvReleaseImage(&image);
	return ptpairs.size();
}

@end


double compareSURFDescriptors(const float* d1, const float* d2, double best, int length)
{
    double total_cost = 0;
    assert( length % 4 == 0 );
    for( int i = 0; i < length; i += 4 )
    {
        double t0 = d1[i] - d2[i];
        double t1 = d1[i+1] - d2[i+1];
        double t2 = d1[i+2] - d2[i+2];
        double t3 = d1[i+3] - d2[i+3];
        total_cost += t0*t0 + t1*t1 + t2*t2 + t3*t3;
        if( total_cost > best )
            break;
    }
    return total_cost;
}

int naiveNearestNeighbor(const float* vec, int laplacian, const CvSeq* model_keypoints, const CvSeq* model_descriptors)
{
    int length = (int)(model_descriptors->elem_size/sizeof(float));
    int i, neighbor = -1;
    double d, dist1 = 1e6, dist2 = 1e6;
    CvSeqReader reader, kreader;
    cvStartReadSeq( model_keypoints, &kreader, 0 );
    cvStartReadSeq( model_descriptors, &reader, 0 );
	
    for( i = 0; i < model_descriptors->total; i++ )
    {
        const CvSURFPoint* kp = (const CvSURFPoint*)kreader.ptr;
        const float* mvec = (const float*)reader.ptr;
    	CV_NEXT_SEQ_ELEM( kreader.seq->elem_size, kreader );
        CV_NEXT_SEQ_ELEM( reader.seq->elem_size, reader );
        if( laplacian != kp->laplacian )
            continue;
        d = compareSURFDescriptors( vec, mvec, dist2, length );
        if( d < dist1 )
        {
            dist2 = dist1;
            dist1 = d;
            neighbor = i;
        }
        else if ( d < dist2 )
            dist2 = d;
    }
    if ( dist1 < 0.6*dist2 )
        return neighbor;
    return -1;
}

void findPairs(const CvSeq* objectKeypoints, const CvSeq* objectDescriptors, const CvSeq* imageKeypoints, const CvSeq* imageDescriptors, vector<int>& ptpairs)
{
    int i;
    CvSeqReader reader, kreader;
    cvStartReadSeq( objectKeypoints, &kreader );
    cvStartReadSeq( objectDescriptors, &reader );
    ptpairs.clear();
	
    for( i = 0; i < objectDescriptors->total; i++ )
    {
        const CvSURFPoint* kp = (const CvSURFPoint*)kreader.ptr;
        const float* descriptor = (const float*)reader.ptr;
        CV_NEXT_SEQ_ELEM( kreader.seq->elem_size, kreader );
        CV_NEXT_SEQ_ELEM( reader.seq->elem_size, reader );
        int nearest_neighbor = naiveNearestNeighbor( descriptor, kp->laplacian, imageKeypoints, imageDescriptors );
        if( nearest_neighbor >= 0 )
        {
            ptpairs.push_back(i);
            ptpairs.push_back(nearest_neighbor);
        }
    }
}
