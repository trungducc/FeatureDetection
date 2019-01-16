//
//  CameraViewController.m
//  FeatureDetection
//
//  Created by trungduc on 1/16/19.
//  Copyright © 2019 trungduc. All rights reserved.
//

#import "CameraViewController.h"

#import <opencv2/videoio/cap_ios.h>
#import <AVFoundation/AVFoundation.h>

@interface CameraViewController () <CvVideoCameraDelegate>

// The view which is displayed while camera permission is denied. Gives user chance to go to
// setting and turn the permission on directly from application. By default, it's hidden.
@property (nonatomic, strong) UIView *askForPermissionView;

// The view presents live preview of the camera.
@property (nonatomic, strong) UIImageView *renderTarget;

// The object which receives input from device camera and renders on |renderTarget|.
@property (nonatomic, strong) CvVideoCamera *camera;

// Creates and adds subviews.
- (void)setupSubviews;

// Initializes |camera| and uses |renderTarget| as a target for rendering from camera each frame.
// |renderTarget| must be initialized before calling this method.
- (void)setupCamera;

@end

@implementation CameraViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupSubviews];
    [self setupCamera];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [_camera start];
}

- (void)setupSubviews {
    _askForPermissionView = [[UIImageView alloc] initWithFrame:self.view.frame];
    _askForPermissionView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:_askForPermissionView];
    
    _askForPermissionView.hidden = YES;
    
    _renderTarget = [[UIImageView alloc] initWithFrame:self.view.frame];
    _renderTarget.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:_renderTarget];
}

- (void)setupCamera {
    _camera = [[CvVideoCamera alloc] initWithParentView:_renderTarget];
    _camera.defaultAVCaptureDevicePosition = AVCaptureDevicePositionBack;
    _camera.defaultAVCaptureSessionPreset = AVCaptureSessionPresetHigh;
    _camera.defaultAVCaptureVideoOrientation = AVCaptureVideoOrientationPortrait;
    _camera.defaultFPS = 30;
    _camera.grayscaleMode = NO;
    _camera.delegate = self;
}

#pragma mark - CvVideoCameraDelegate

- (void)processImage:(cv::Mat&)image {
    
}

@end
