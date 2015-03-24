//
//  ViewController.m
//  FaceSet
//
//  Created by Wren on 3/23/15.
//  Copyright (c) 2015 Janardan Yri. All rights reserved.
//

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>


@interface ViewController ()

@property (nonatomic) CIDetector *faceDetector;

@property (nonatomic) AVCaptureSession *captureSession;
@property (nonatomic) AVCaptureInput *cameraInput;
@property (nonatomic) AVCaptureStillImageOutput *imageOutput;

@property (nonatomic) NSTimer *imageTimer;

@property (nonatomic) UIImage *image;
@property (nonatomic, copy) NSArray *faceFeatures;

@end


@implementation ViewController

- (instancetype)init {
  return [self initWithCollectionViewLayout:[[UICollectionViewFlowLayout alloc] init]];
}

- (void)viewDidLoad {
  [super viewDidLoad];

  self.faceDetector = [CIDetector detectorOfType:CIDetectorTypeFace context:nil options:nil];

  AVCaptureDevice *camera = ^{
    for (AVCaptureDevice *device in [AVCaptureDevice devices]) {
      if (device.position == AVCaptureDevicePositionBack && [device hasMediaType:AVMediaTypeVideo]) {
        return device;
      }
    }
    return (AVCaptureDevice *)nil;
  }();

  NSError *error;
  self.cameraInput = [[AVCaptureDeviceInput alloc] initWithDevice:camera error:&error];

  self.imageOutput = [[AVCaptureStillImageOutput alloc] init];

  self.captureSession = [[AVCaptureSession alloc] init];
  [self.captureSession addInput:self.cameraInput];
  [self.captureSession addOutput:self.imageOutput];
}

- (void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];

  [self.captureSession startRunning];
  self.imageTimer = [NSTimer scheduledTimerWithTimeInterval:1
                                                     target:self
                                                   selector:@selector(captureImage)
                                                   userInfo:nil
                                                    repeats:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
  [super viewWillDisappear:animated];

  [self.captureSession stopRunning];
  [self.imageTimer invalidate];
}

- (void)captureImage {
  [self.imageOutput captureStillImageAsynchronouslyFromConnection:self.imageOutput.connections[0] completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
    NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
    CIImage *image = [CIImage imageWithData:imageData];
    NSArray *faceFeatures = [self.faceDetector featuresInImage:image];

    self.image = [UIImage imageWithCIImage:image];
    self.faceFeatures = faceFeatures;

    NSLog(@"%@", faceFeatures);
  }];
}

@end
