//
//  CameraController.h
//  FeatureDetection
//
//  Created by trungduc on 1/19/19.
//  Copyright © 2019 trungduc. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol CameraControllerDelegate

// Notifies the delegate that a new video frame was written.
- (void)captureOutput:(AVCaptureOutput *)output didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection;

@end

// The CameraController manages the AVCaptureSession, its inputs, outputs.
@interface CameraController : NSObject

// The app's authorization in regards to the camera.
@property (nonatomic, readonly) AVAuthorizationStatus authorizationStatus;

// Returns a new controller with the |delegate|.
- (instancetype)initWithDelegate:(id<CameraControllerDelegate>)delegate;

- (instancetype)init NS_UNAVAILABLE;

// Asks the user to grant the authorization to access the camera.
- (void)requestAuthorizationAndLoadCaptureSession;

// Loads the camera.
- (void)loadCaptureSession;

// Starts the camera capture session. Does nothing if the camera is not available.
- (void)startRecording;

// Stops the camera capture session. Does nothing if the camera is not available.
- (void)stopRecording;

@end

NS_ASSUME_NONNULL_END
