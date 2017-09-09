//
//  FaceARDetectIOS.h
//  FaceAR_SDK_IOS_OpenFace_RunFull
//
//  Created by Keegan Ren on 7/5/16.
//  Copyright © 2016 Keegan Ren. All rights reserved.
//

#import <UIKit/UIKit.h>
#include <AVFoundation/AVFoundation.h>


// OpenCV includes


@interface FaceARDetectIOS : NSObject
@property (nonatomic, assign)  double detectionCertain;
@property (nonatomic, strong) NSMutableArray *objcLines;
@property (nonatomic, strong) NSMutableArray *boundingBoxMatrix;
@property (nonatomic, strong) NSMutableArray *landmarks;
@property (nonatomic, strong) NSArray *rotationMatrix;
@property (nonatomic, assign) double xRotation;
@property (nonatomic, assign) double yRotation;
@property (nonatomic, assign) double zRotation;
@property (nonatomic, assign) double xTranslation;
@property (nonatomic, assign) double yTranslation;
@property (nonatomic, assign) double zTranslation;
@property (nonatomic, assign) int frame_count;

//bool inits_FaceAR();
//-(instancetype) inits_FaceAR;
//-(id) init;

// void visualise_tracking(cv::Mat& captured_image, cv::Mat_<float>& depth_image, const LandmarkDetector::CLNF& face_model, const LandmarkDetector::FaceModelParameters& det_parameters, int frame_count, double fx, double fy, double cx, double cy)
//-(BOOL) visualise_tracking:(cv::Mat)captured_image depth_image_:(cv::Mat)depth_image face_model_:(const LandmarkDetector::CLNF)face_model det_parameters_:(const LandmarkDetector::FaceModelParameters)det_parameters frame_count_:(int)frame_count fx_:(double)fx fy_:(double)fy cx_:(double)cx cy_:(double)cy;

//bool run_FaceAR(cv::Mat &captured_image, int frame_count, float fx, float fy, float cx, float cy);

//bool reset_FaceAR();
-(BOOL) reset_FaceAR;

//bool clear_FaceAR();
-(BOOL) clear_FaceAR;
- (void)processUIImage:(UIImage*)image;
- (void)processBuffer:(CVImageBufferRef)pixelBuffer;
@end
