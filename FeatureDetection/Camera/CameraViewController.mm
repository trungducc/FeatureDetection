//
//  CameraViewController.m
//  FeatureDetection
//
//  Created by trungduc on 1/16/19.
//  Copyright © 2019 trungduc. All rights reserved.
//

#import "CameraViewController.h"

#import <AVFoundation/AVFoundation.h>
#import <opencv2/videoio/cap_ios.h>
#import <opencv2/features2d/features2d.hpp>
#import <opencv2/imgproc/imgproc.hpp>

#import "CameraController.h"
#import "UIImage+OpenCV.h"

const CGFloat kFeatureDetectionThreshold = 3000;

@interface CameraViewController () <CameraControllerDelegate>

// The view which is displayed while camera permission is denied. Gives user chance to go to
// setting and turn the permission on directly from application.
@property (nonatomic, strong) UIView *askForPermissionView;

// The image view which is displayed when the number of features is greater than |kFeatureDetectionThreshold|.
@property (nonatomic, strong) UIImageView *cueImageView;

// The view presents live preview of the camera.
@property (nonatomic, strong) UIImageView *renderTarget;

// The CameraController managing the camera connection.
@property (nonatomic, strong) CameraController *cameraController;

// Detector which is used to detect features from images
@property (nonatomic, assign) cv::Ptr<cv::Feature2D> detector;

// Creates and adds subviews.
- (void)setupSubviews;

// Initializes |camera| and uses |renderTarget| as a target for rendering from camera each frame.
// |renderTarget| must be initialized before calling this method.
- (void)setupCamera;

// Allows the user to go to Feature Detection's settings
- (void)openSettings;

@end

@implementation CameraViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupDetector];
    [self setupSubviews];
    [self setupCamera];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [_cameraController startRecording];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [_cameraController stopRecording];
}

- (void)setupDetector {
    _detector = cv::FastFeatureDetector::create();
}

- (void)setupSubviews {
    // Initilazes subviews

    _askForPermissionView = [[UIView alloc] initWithFrame:self.view.frame];
    _askForPermissionView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:_askForPermissionView];
    
    UILabel *askForPermissionTitleLabel = [[UILabel alloc] init];
    askForPermissionTitleLabel.textColor = [UIColor whiteColor];
    askForPermissionTitleLabel.text = @"Feature Detection";
    askForPermissionTitleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    askForPermissionTitleLabel.font = [UIFont boldSystemFontOfSize:20.f];
    [_askForPermissionView addSubview:askForPermissionTitleLabel];
    
    UILabel *askForPermissionDescriptionLabel = [[UILabel alloc] init];
    askForPermissionDescriptionLabel.textColor = [UIColor lightGrayColor];
    askForPermissionDescriptionLabel.textAlignment = NSTextAlignmentCenter;
    askForPermissionDescriptionLabel.numberOfLines = 2;
    askForPermissionDescriptionLabel.text = @"Enable access so you can start detect features.";
    askForPermissionDescriptionLabel.translatesAutoresizingMaskIntoConstraints = NO;
    askForPermissionDescriptionLabel.font = [UIFont systemFontOfSize:15.f];
    [_askForPermissionView addSubview:askForPermissionDescriptionLabel];
    
    UIButton *enableCameraAccessButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [enableCameraAccessButton setTitle:@"Enable Camera Access" forState:UIControlStateNormal];
    [enableCameraAccessButton addTarget:self action:@selector(openSettings) forControlEvents:UIControlEventTouchUpInside];
    enableCameraAccessButton.translatesAutoresizingMaskIntoConstraints = NO;
    enableCameraAccessButton.titleLabel.font = [UIFont systemFontOfSize:17.f];
    [_askForPermissionView addSubview:enableCameraAccessButton];
    
    _renderTarget = [[UIImageView alloc] initWithFrame:self.view.frame];
    _renderTarget.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:_renderTarget];
    
    UIImage *cueImage = [UIImage imageNamed:@"ok"];
    _cueImageView = [[UIImageView alloc] initWithImage:cueImage];
    _cueImageView.translatesAutoresizingMaskIntoConstraints = NO;
    _cueImageView.hidden = YES;
    [self.view addSubview:_cueImageView];
    
    // Update constraints

    [_askForPermissionView.widthAnchor constraintEqualToAnchor:self.view.widthAnchor].active = YES;
    [_askForPermissionView.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor].active = YES;
    [_askForPermissionView.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor].active = YES;
    [_askForPermissionView.heightAnchor constraintEqualToConstant:120.f].active = YES;
    
    [askForPermissionTitleLabel.topAnchor constraintEqualToAnchor:_askForPermissionView.topAnchor].active = YES;
    [askForPermissionTitleLabel.centerXAnchor constraintEqualToAnchor:_askForPermissionView.centerXAnchor].active = YES;
    
    [askForPermissionDescriptionLabel.topAnchor constraintEqualToAnchor:askForPermissionTitleLabel.bottomAnchor constant:5.f].active = YES;
    [askForPermissionDescriptionLabel.centerXAnchor constraintEqualToAnchor:_askForPermissionView.centerXAnchor].active = YES;
    [askForPermissionDescriptionLabel.widthAnchor constraintEqualToAnchor:_askForPermissionView.widthAnchor].active = YES;
    
    [enableCameraAccessButton.bottomAnchor constraintEqualToAnchor:_askForPermissionView.bottomAnchor].active = YES;
    [enableCameraAccessButton.centerXAnchor constraintEqualToAnchor:_askForPermissionView.centerXAnchor].active = YES;
    
    [_cueImageView.widthAnchor constraintEqualToAnchor:self.view.widthAnchor multiplier:0.3f].active = YES;
    [_cueImageView.heightAnchor constraintEqualToAnchor:self.view.heightAnchor multiplier:0.3f].active = YES;
    [_cueImageView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-8.f].active = YES;
    [_cueImageView.topAnchor constraintEqualToAnchor:self.view.topAnchor constant:44.f].active = YES;
}

- (void)setupCamera {
    assert(_renderTarget);
    
    _cameraController = [[CameraController alloc] initWithDelegate:self];
    switch (_cameraController.authorizationStatus) {
        case AVAuthorizationStatusNotDetermined:
            [_cameraController requestAuthorizationAndLoadCaptureSession];
            break;
        case AVAuthorizationStatusAuthorized:
            [_cameraController loadCaptureSession];
            break;
        case AVAuthorizationStatusRestricted:
        case AVAuthorizationStatusDenied:
            _renderTarget.hidden = YES;
            break;
    }
}

- (void)openSettings {
    NSURL *settingURL = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
    if ([[UIApplication sharedApplication] canOpenURL:settingURL]) {
        [[UIApplication sharedApplication] openURL:settingURL options:@{} completionHandler:nil];
    }
}

#pragma mark - CameraControllerDelegate

- (void)captureOutput:(AVCaptureOutput *)output didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    // Create a cv::Mat from |pixelBuffer|
    UIImage *image = [UIImage imageFromSampleBuffer:sampleBuffer];
    cv::Mat mat = image.cvMat;

    // Detects keypoints from |image|
    std::vector<cv::KeyPoint> keypoints;
    _detector->detect(mat, keypoints);
    
    // Draw keypoints on mat
    cv::Mat rbgMat;
    cvtColor(mat, rbgMat, CV_BGRA2BGR);
    cv::drawKeypoints(rbgMat, keypoints, mat);

    // Updates camera preview and shows  |cueImageView| if needed
    image = [UIImage UIImageFromCVMat:mat];
    dispatch_async(dispatch_get_main_queue(), ^{
        self.renderTarget.image = image;
        self.cueImageView.hidden = keypoints.size() <= kFeatureDetectionThreshold;
    });
}

@end
