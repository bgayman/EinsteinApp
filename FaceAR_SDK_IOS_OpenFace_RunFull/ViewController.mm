//
//  ViewController.m
//  FaceAR_SDK_IOS_OpenFace_RunFull
//
//  Created by Keegan Ren on 7/5/16.
//  Copyright © 2016 Keegan Ren. All rights reserved.
//

#import "ViewController.h"

///// opencv
#import <opencv2/opencv.hpp>
///// C++
#include <iostream>
///// user

//



@interface ViewController ()

@end

@implementation ViewController {
    FaceARDetectIOS *facear;
    int frame_count;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.videoCamera = [[CvVideoCamera alloc] initWithParentView:self.imageView];
    self.videoCamera.delegate = self;
    self.videoCamera.defaultAVCaptureDevicePosition = AVCaptureDevicePositionFront;
    self.videoCamera.defaultAVCaptureSessionPreset = AVCaptureSessionPreset640x480;
    self.videoCamera.defaultAVCaptureVideoOrientation = AVCaptureVideoOrientationPortrait;
    self.videoCamera.defaultFPS = 30;
    self.videoCamera.grayscaleMode = NO;
    
    self.faceDetect = [[FaceARDetectIOS alloc] init];
    
    self.sceneView.scene = [[SCNScene alloc] init];
    self.cameraNode = [[SCNNode alloc] init];
    self.cameraNode.camera = [[SCNCamera alloc] init];
    self.cameraNode.position = SCNVector3Make(0, 0, 10);
    [self.sceneView.scene.rootNode addChildNode:self.cameraNode];
    
    self.faceNode = [SCNNode nodeWithGeometry:[SCNBox boxWithWidth:1 height:2 length:0.5 chamferRadius:0]];
    SCNMaterial *redMaterial = [SCNMaterial new];
    redMaterial.diffuse.contents = [UIColor redColor];
    self.faceNode.geometry.firstMaterial = redMaterial;
    self.faceNode.position = SCNVector3Make(-3.6, 4.6, 0);
    self.faceNode.castsShadow = YES;
    [self.sceneView.scene.rootNode addChildNode:self.faceNode];
    
    SCNNode *lightNode = [[SCNNode alloc]init];
    lightNode.light = [SCNLight light];
    lightNode.light.type = SCNLightTypeOmni;
    lightNode.light.color = [UIColor whiteColor];
    lightNode.position = SCNVector3Make(0, 10, 10);
    [self.sceneView.scene.rootNode addChildNode:lightNode];
}

- (IBAction)startButtonPressed:(id)sender
{
    [self.videoCamera start];
}



@end
