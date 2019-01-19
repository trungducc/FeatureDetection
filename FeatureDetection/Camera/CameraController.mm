//
//  CameraController.m
//  FeatureDetection
//
//  Created by trungduc on 1/19/19.
//  Copyright © 2019 trungduc. All rights reserved.
//

#import "CameraController.h"

#import <UIKit/UIKit.h>

@interface CameraController () <AVCaptureVideoDataOutputSampleBufferDelegate>

// The capture session for recording video.
@property (nonatomic, strong) AVCaptureSession *captureSession;

// The delegate which receives the capture output.
@property (nonatomic, weak) id<CameraControllerDelegate> delegate;

// The queue for dispatching calls to |captureSession|.
@property (nonatomic, strong) dispatch_queue_t sessionQueue;

@end

@implementation CameraController

- (instancetype)initWithDelegate:(id<CameraControllerDelegate>)delegate {
    self = [super init];
    if (self) {
        assert(delegate);

        _delegate = delegate;
        _sessionQueue = dispatch_queue_create("com.trungduc.FeatureDetection.CaptureSessionQueue", DISPATCH_QUEUE_SERIAL);
        _captureSession = [[AVCaptureSession alloc] init];
    }
    return self;
}

#pragma mark - Public methods

- (AVAuthorizationStatus)getAuthorizationStatus {
    return [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
}

- (void)requestAuthorizationAndLoadCaptureSession {
    assert(self.authorizationStatus == AVAuthorizationStatusNotDetermined);
    [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
        if (granted) {
            [self loadCaptureSession];
        }
    }];
}

- (void)loadCaptureSession {
    dispatch_async(_sessionQueue, ^{
        // Get the back camera.
        AVCaptureDeviceDiscoverySession *discoverySession = [AVCaptureDeviceDiscoverySession discoverySessionWithDeviceTypes:@[ AVCaptureDeviceTypeBuiltInWideAngleCamera ] mediaType:AVMediaTypeVideo position:AVCaptureDevicePositionBack];
        NSArray* videoCaptureDevices = [discoverySession devices];
        NSUInteger cameraIndex = [videoCaptureDevices indexOfObjectPassingTest:^BOOL(AVCaptureDevice *device, NSUInteger idx, BOOL *stop) {
            return device.position == AVCaptureDevicePositionBack;
        }];
        
        // Allow only the back camera.
        if (cameraIndex == NSNotFound) {
            return;
        }
        AVCaptureDevice *camera = videoCaptureDevices[cameraIndex];
        
        // Configure camera input.
        NSError *error = nil;
        AVCaptureDeviceInput *videoInput = [AVCaptureDeviceInput deviceInputWithDevice:camera error:&error];
        if (error || !videoInput) {
            return;
        }
        
        AVCaptureSession *session = [[AVCaptureSession alloc] init];
        if (![session canAddInput:videoInput]) {
            return;
        }
        [session addInput:videoInput];
        
        // Configure data output.
        AVCaptureVideoDataOutput *dataOutput = [[AVCaptureVideoDataOutput alloc] init];
        [dataOutput setSampleBufferDelegate:self queue:self.sessionQueue];
        if (![session canAddOutput:dataOutput]) {
            return;
        }
        [session addOutput:dataOutput];
        
        // Specify the pixel format
        dataOutput.videoSettings = [NSDictionary dictionaryWithObject:@(kCVPixelFormatType_32BGRA)
                                                               forKey:(id)kCVPixelBufferPixelFormatTypeKey];
        
        self.captureSession = session;
        [self.captureSession startRunning];
    });
}

- (void)startRecording {
    dispatch_async(_sessionQueue, ^{
        if (![self.captureSession isRunning]) {
            [self.captureSession startRunning];
        }
    });
}

- (void)stopRecording {
    dispatch_async(_sessionQueue, ^{
        if ([self.captureSession isRunning]) {
            [self.captureSession stopRunning];
        }
    });
}

#pragma mark - AVCaptureVideoDataOutputSampleBufferDelegate

- (void)captureOutput:(AVCaptureOutput *)output didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    [_delegate captureOutput:output didOutputSampleBuffer:sampleBuffer fromConnection:connection];
}

@end
