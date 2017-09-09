//
//  FaceARDetectIOS.m
//  FaceAR_SDK_IOS_OpenFace_RunFull
//
//  Created by Keegan Ren on 7/5/16.
//  Copyright © 2016 Keegan Ren. All rights reserved.
//

#import "FaceARDetectIOS.h"
#include <iostream>
#include <fstream>
#include <sstream>
#include <opencv2/videoio/videoio.hpp>  // Video write
#include <opencv2/videoio/videoio_c.h>  // Video write
#include <opencv2/imgproc.hpp>
#include <opencv2/highgui/highgui.hpp>

#include "LandmarkCoreIncludes.h"
#include "GazeEstimation.h"


LandmarkDetector::FaceModelParameters det_parameters;
// The modules that are being used for tracking
LandmarkDetector::CLNF clnf_model;

@interface FaceARDetectIOS ()

@end

@implementation FaceARDetectIOS

//bool inits_FaceAR();
-(id) init
{
    self = [super init];
    NSString *location = [[NSBundle mainBundle] resourcePath];
    det_parameters.init();
    det_parameters.model_location = [location UTF8String] + std::string("/model/main_clnf_general.txt");
    det_parameters.face_detector_location = [location UTF8String] + std::string("/classifiers/haarcascade_frontalface_alt.xml");
    
    std::cout << "model_location = " << det_parameters.model_location << std::endl;
    std::cout << "face_detector_location = " << det_parameters.face_detector_location << std::endl;
    
    clnf_model.model_location_clnf = [location UTF8String] + std::string("/model/main_clnf_general.txt");
    clnf_model.face_detector_location_clnf = [location UTF8String] + std::string("/classifiers/haarcascade_frontalface_alt.xml");
    clnf_model.inits();

    return self;
}

// Visualising the results
//void visualise_tracking(cv::Mat& captured_image, cv::Mat_<float>& depth_image, const LandmarkDetector::CLNF& face_model, const LandmarkDetector::FaceModelParameters& det_parameters, int frame_count, double fx, double fy, double cx, double cy)
-(BOOL) visualise_tracking:(cv::Mat)captured_image depth_image_:(cv::Mat)depth_image face_model_:(const LandmarkDetector::CLNF)face_model det_parameters_:(const LandmarkDetector::FaceModelParameters)det_parameters frame_count_:(int)frame_count fx_:(double)fx fy_:(double)fy cx_:(double)cx cy_:(double)cy
{
    
    // Drawing the facial landmarks on the face and the bounding box around it if tracking is successful and initialised
    double detection_certainty = face_model.detection_certainty;
    bool detection_success = face_model.detection_success;
    
    double visualisation_boundary = 0.2;
    
    // Only draw if the reliability is reasonable, the value is slightly ad-hoc
    if (detection_certainty < visualisation_boundary)
    {
        LandmarkDetector::Draw(captured_image, face_model);

        double vis_certainty = detection_certainty;
        if (vis_certainty > 1)
            vis_certainty = 1;
        if (vis_certainty < -1)
            vis_certainty = -1;
        
        vis_certainty = (vis_certainty + 1) / (visualisation_boundary + 1);
        
        // A rough heuristic for box around the face width
        int thickness = (int)std::ceil(2.0* ((double)captured_image.cols) / 640.0);
        
        cv::Vec6d pose_estimate_to_draw = LandmarkDetector::GetCorrectedPoseWorld(face_model, fx, fy, cx, cy);
        
        // Draw it in reddish if uncertain, blueish if certain
//        LandmarkDetector::DrawBox(captured_image, pose_estimate_to_draw, cv::Scalar((1 - vis_certainty)*255.0, 0, vis_certainty * 255), thickness, fx, fy, cx, cy);
//
//        std::vector<std::pair<cv::Point, cv::Point> > lines = LandmarkDetector::CalculateBox(pose_estimate_to_draw, fx, fy, cx, cy);
//        NSMutableArray *objcLines = [NSMutableArray new];
//        for (size_t i = 0; i < lines.size(); ++i)
//        {
//            cv::Point p1 = lines.at(i).first;
//            cv::Point p2 = lines.at(i).second;
//            // Only draw the line if one of the points is inside the image
//            CGPoint point1 = CGPointMake(p1.x, p1.y);
//            CGPoint point2 = CGPointMake(p2.x, p2.y);
//
//            NSArray *line = @[[NSValue valueWithCGPoint: point1], [NSValue valueWithCGPoint: point2]];
//            [objcLines addObject: line];
//        }
//        self.objcLines = objcLines;
        
        cv::Mat_<double> rawMatrix = LandmarkDetector::CalculateBox3DSpace(pose_estimate_to_draw, fx, fy, cx, cy);
        int num_points = rawMatrix.rows;
        double X, Y, Z;
        cv::Mat_<double>::const_iterator mData = rawMatrix.begin();
        NSMutableArray *matrix = [NSMutableArray new];
        for(int i = 0;i < num_points; i++)
        {
            // Get the points
            X = *(mData++);
            Y = *(mData++);
            Z = *(mData++);
            NSArray *point = @[@(X), @(Y), @(Z)];
            [matrix addObject:point];
        }
        self.boundingBoxMatrix = matrix;
        self.xTranslation = pose_estimate_to_draw[0];
        self.yTranslation = pose_estimate_to_draw[1];
        self.zTranslation = pose_estimate_to_draw[2];
        self.xRotation = pose_estimate_to_draw[3];
        self.yRotation = pose_estimate_to_draw[4];
        self.zRotation = pose_estimate_to_draw[5];
        cv::Matx33d rotationMatrix = LandmarkDetector::RotationMatrix(pose_estimate_to_draw);
        self.rotationMatrix = @[@[@(rotationMatrix(0,0)), @(rotationMatrix(0,1)), @(rotationMatrix(0,2))],
                                @[@(rotationMatrix(1,0)), @(rotationMatrix(1,1)), @(rotationMatrix(1,2))],
                                @[@(rotationMatrix(2,0)), @(rotationMatrix(2,1)), @(rotationMatrix(2,2))]];
        
//        cv::Mat_<double> landmarks = face_model.detected_landmarks;
//        int numberOfRows = landmarks.rows;
//        double x, y, z;
//        cv::Mat_<double>::const_iterator matrixData = landmarks.begin();
//        NSMutableArray *objcLandmarks = [NSMutableArray new];
//        for(int i = 0;i < numberOfRows; i++)
//        {
//            // Get the points
//            x = *(matrixData++);
//            y = *(matrixData++);
//            z = *(matrixData++);
//            NSArray *point = @[@(x), @(y), @(z)];
//            [objcLandmarks addObject:point];
//        }
//        self.landmarks = objcLandmarks;
    }
    return YES;
}


//bool run_FaceAR(cv::Mat &captured_image, int frame_count, float fx, float fy, float cx, float cy);
-(BOOL) run_FaceAR:(cv::Mat)captured_image frame__:(int)frame_count fx__:(double)fx fy__:(double)fy cx__:(double)cx cy__:(double)cy
{
    // Reading the images
    cv::Mat_<float> depth_image;
    cv::Mat_<uchar> grayscale_image;
    
    if(captured_image.channels() == 3)
    {
        cv::cvtColor(captured_image, grayscale_image, CV_BGR2GRAY);
    }
    else
    {
        grayscale_image = captured_image.clone();
    }
    
    // The actual facial landmark detection / tracking
    bool detection_success = LandmarkDetector::DetectLandmarksInVideo(grayscale_image, depth_image, clnf_model, det_parameters);
    //            bool detection_success = LandmarkDetector::DetectLandmarksInImage(grayscale_image, depth_image, clnf_model, det_parameters);
    
    // Visualising the results
    // Drawing the facial landmarks on the face and the bounding box around it if tracking is successful and initialised
    double detection_certainty = clnf_model.detection_certainty;
    self.detectionCertain = detection_certainty;
    [self visualise_tracking:captured_image depth_image_:depth_image face_model_:clnf_model det_parameters_:det_parameters frame_count_:frame_count fx_:fx fy_:fy cx_:cx cy_:cy];
    //visualise_tracking(captured_image, depth_image, clnf_model, det_parameters, frame_count, fx, fy, cx, cy);
    
    //////////////////////////////////////////////////////////////////////
    /// gaze EstimateGaze
    ///
    cv::Point3f gazeDirection0(0, 0, -1);
    cv::Point3f gazeDirection1(0, 0, -1);
    if (det_parameters.track_gaze && detection_success && clnf_model.eye_model)
    {
        GazeEstimate::EstimateGaze(clnf_model, gazeDirection0, fx, fy, cx, cy, true);
        GazeEstimate::EstimateGaze(clnf_model, gazeDirection1, fx, fy, cx, cy, false);
        GazeEstimate::DrawGaze(captured_image, clnf_model, gazeDirection0, gazeDirection1, fx, fy, cx, cy);
    }
    
    return true;
}

//bool reset_FaceAR();
-(BOOL) reset_FaceAR
{
    clnf_model.Reset();
    
    return true;
}

//bool clear_FaceAR();
-(BOOL) clear_FaceAR
{
    clnf_model.Reset();
    
    return true;
}

+ (cv::Mat)toCVMat:(UIImage*)image
{
    // (1) Get image dimensions
    CGFloat cols = image.size.width;
    CGFloat rows = image.size.height;
    
    // (2) Create OpenCV image container, 8 bits per component, 4 channels
    cv::Mat cvMat(rows, cols, CV_8UC4);
    
    // (3) Create CG context and draw the image
    CGContextRef contextRef = CGBitmapContextCreate(cvMat.data,
                                                    cols,
                                                    rows,
                                                    8,
                                                    cvMat.step[0],
                                                    CGImageGetColorSpace(image.CGImage),
                                                    kCGImageAlphaNoneSkipLast |
                                                    kCGBitmapByteOrderDefault);
    
    CGContextDrawImage(contextRef, CGRectMake(0, 0, cols, rows), image.CGImage);
    CGContextRelease(contextRef);
    
    // (4) Return OpenCV image container reference
    return cvMat;
}

- (void)processImage:(cv::Mat &)image
{
    cv::Mat targetImage(image.cols,image.rows,CV_8UC3);
    cv::cvtColor(image, targetImage, cv::COLOR_BGRA2BGR);
    if(targetImage.empty()){
        std::cout << "targetImage empty" << std::endl;
    }
    else
    {
        float fx, fy, cx, cy;
        cx = 1.0*targetImage.cols / 2.0;
        cy = 1.0*targetImage.rows / 2.0;
        
        fx = 500 * (targetImage.cols / 640.0);
        fy = 500 * (targetImage.rows / 480.0);
        
        fx = (fx + fy) / 2.0;
        fy = fx;
        
        
        [self run_FaceAR:targetImage frame__:self.frame_count fx__:fx fy__:fy cx__:cx cy__:cy];
        self.frame_count = self.frame_count + 1;
    }
    cv::cvtColor(targetImage, image, cv::COLOR_BGRA2RGB);
}

- (void)processUIImage:(UIImage*)image
{
    cv::Mat cvImage = [FaceARDetectIOS toCVMat: image];
    [self processImage: cvImage];
}

- (void)processBuffer:(CVImageBufferRef)pixelBuffer
{
    CVPixelBufferLockBaseAddress(pixelBuffer, 0);
    
    // get the address to the image data
    void *imgBufAddr = CVPixelBufferGetBaseAddressOfPlane(pixelBuffer, 0);
    
    // get image properties
    int w = (int)CVPixelBufferGetWidth(pixelBuffer);
    int h = (int)CVPixelBufferGetHeight(pixelBuffer);
    
    // create the cv mat
    cv::Mat image;
    image.create(h, w, CV_8UC4);
    memcpy(image.data, imgBufAddr, w * h);
    
    [self processImage:image];
    CVPixelBufferUnlockBaseAddress(pixelBuffer, 0);
}

@end
