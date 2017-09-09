//
//  ViewController.h
//  FaceAR_SDK_IOS_OpenFace_RunFull
//
//  Created by Keegan Ren on 7/5/16.
//  Copyright © 2016 Keegan Ren. All rights reserved.
//

#import <UIKit/UIKit.h>
#include "FaceARDetectIOS.h"
#import <SceneKit/SceneKit.h>

#import <opencv2/videoio/cap_ios.h>

@interface ViewController : UIViewController<CvVideoCameraDelegate>

//- (IBAction)startButtonPressed:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *start;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (nonatomic, strong) CvVideoCamera* videoCamera;
@property (weak, nonatomic) IBOutlet UILabel *label;
@property (nonatomic, strong) FaceARDetectIOS *faceDetect;
@property (weak, nonatomic) IBOutlet SCNView *sceneView;
@property (nonatomic, strong) SCNNode *cameraNode;
@property (nonatomic, strong) SCNNode *faceNode;
@end

