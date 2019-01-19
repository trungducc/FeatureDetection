//
//  UIImage+OpenCV.h
//  FeatureDetection
//
//  Created by trungduc on 1/19/19.
//  Copyright © 2019 trungduc. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <CoreMedia/CoreMedia.h>
#import <opencv2/core.hpp>

NS_ASSUME_NONNULL_BEGIN

@interface UIImage (OpenCV)

// Create a UIImage from sample buffer data
+ (UIImage *)imageFromSampleBuffer:(CMSampleBufferRef)sampleBuffer;

// Create a cv::Mat from image
- (cv::Mat)cvMat;

// Create an UIImage from given cvMat
+ (UIImage *)UIImageFromCVMat:(cv::Mat)cvMat;

@end

NS_ASSUME_NONNULL_END
