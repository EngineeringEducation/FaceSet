//
//  ViewController.m
//  FaceSet
//
//  Created by Wren on 3/23/15.
//  Copyright (c) 2015 Janardan Yri. All rights reserved.
//

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "FaceCell.h"

NSString *CellReuseIdentifier = @"Cell";
CGSize ItemSize = (CGSize) { .height = 200, .width = 200 };
int MagicPortraitOrientationNumberOfSadness = 5; // Don't ask.

@interface ViewController () <UICollectionViewDelegateFlowLayout>

@property (nonatomic) CIDetector *faceDetector;

@property (nonatomic) AVCaptureSession *captureSession;
@property (nonatomic) AVCaptureInput *cameraInput;
@property (nonatomic) AVCaptureStillImageOutput *imageOutput;
@property (nonatomic) AVCaptureConnection *connection;

@property (nonatomic) NSTimer *imageTimer;

@property (nonatomic, copy) NSArray *faceImages;

@end


@implementation ViewController

- (instancetype)init {
  UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
  layout.itemSize = ItemSize;
  return [self initWithCollectionViewLayout:layout];
}


#pragma mark - View Lifecycle

- (void)viewDidLoad {
  [super viewDidLoad];

  [self.collectionView registerClass:FaceCell.class forCellWithReuseIdentifier:CellReuseIdentifier];

  [self setUpCaptureSession];
}

- (void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];

  [self startUpdates];
}

- (void)viewWillDisappear:(BOOL)animated {
  [super viewWillDisappear:animated];

  [self stopUpdates];
}


#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
  return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
  return self.faceImages.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
  FaceCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellReuseIdentifier
                                                             forIndexPath:indexPath];
  UIImage *faceImage = self.faceImages[indexPath.item];

  // FIXME: use AutoLayout at creation time, not hardcoded frames here
  cell.imageView.frame = (CGRect) { .origin = CGPointZero, .size = ItemSize };
  cell.imageView.image = faceImage;

  return cell;
}


#pragma mark - AV

// This function handles all the AV setup.
- (void)setUpCaptureSession {

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
  if (error) { NSLog(@"AVCaptureDeviceInput init error: %@", error.localizedDescription); }

  self.imageOutput = [[AVCaptureStillImageOutput alloc] init];

  self.captureSession = [[AVCaptureSession alloc] init];
  [self.captureSession addInput:self.cameraInput];
  [self.captureSession addOutput:self.imageOutput];

  self.connection = [self.imageOutput connectionWithMediaType:AVMediaTypeVideo];
}

// Start updates, at the beginning or after interruptions. (There's always interruptions in mobile.)
- (void)startUpdates {
  [self.captureSession startRunning];
  self.imageTimer = [NSTimer scheduledTimerWithTimeInterval:1
                                                     target:self
                                                   selector:@selector(captureImage)
                                                   userInfo:nil
                                                    repeats:YES];
}

// Stop updates due to an interruption.
- (void)stopUpdates {
  [self.captureSession stopRunning];
  [self.imageTimer invalidate];
}

// This function is fired by timer and does all the "update stuff"
- (void)captureImage {
  [self.imageOutput captureStillImageAsynchronouslyFromConnection:self.connection completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
    if (error) { NSLog(@"Capture error: %@", error.localizedDescription); return; }

    NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
    CIImage *image = [CIImage imageWithData:imageData];
    NSArray *faceFeatures = [self.faceDetector featuresInImage:image
                                                       options:@{ CIDetectorImageOrientation : @(MagicPortraitOrientationNumberOfSadness) }];

    if (faceFeatures.count) {
      [self updateWithImage:image faceFeatures:faceFeatures];
    }
  }];
}

// Use a freshly minted image and its faces to update our model and UI.
- (void)updateWithImage:(CIImage *)image faceFeatures:(NSArray *)faceFeatures {

  NSMutableArray *accumulatingImages = [NSMutableArray array];

  for (CIFeature *feature in faceFeatures) {
    NSLog(@"Feature: %@", NSStringFromCGRect(feature.bounds));
    CIImage *croppedImage = [[image imageByCroppingToRect:CGRectIntegral(feature.bounds)]
                             imageByApplyingOrientation:MagicPortraitOrientationNumberOfSadness];
    UIImage *croppedUIImage = [UIImage imageWithCIImage:croppedImage];
    [accumulatingImages addObject:croppedUIImage];
  }

  self.faceImages = accumulatingImages;

  [self.collectionView reloadData];
}

@end
