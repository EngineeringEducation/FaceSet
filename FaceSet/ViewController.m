//
//  ViewController.m
//  FaceSet
//
//  Created by Wren on 3/23/15.
//  Copyright (c) 2015 Janardan Yri. All rights reserved.
//

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>

NSString *CellReuseIdentifier = @"Cell";


@interface ViewController () <UICollectionViewDelegateFlowLayout>

@property (nonatomic) CIDetector *faceDetector;

@property (nonatomic) AVCaptureSession *captureSession;
@property (nonatomic) AVCaptureInput *cameraInput;
@property (nonatomic) AVCaptureStillImageOutput *imageOutput;

@property (nonatomic) NSTimer *imageTimer;

@property (nonatomic, copy) NSArray *faceImages;

@end


@implementation ViewController

- (instancetype)init {
  UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
  layout.itemSize = (CGSize) { .height = 300, .width = 300 };
  return [self initWithCollectionViewLayout:layout];
}

- (void)viewDidLoad {
  [super viewDidLoad];

  [self.collectionView registerClass:UICollectionViewCell.class forCellWithReuseIdentifier:CellReuseIdentifier];


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
    if (error) { return; }

    NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
    CIImage *image = [CIImage imageWithData:imageData];
    NSArray *faceFeatures = [self.faceDetector featuresInImage:image];

    if (faceFeatures.count) {
      [self updateWithImage:image faceFeatures:faceFeatures];
    }
  }];
}

- (void)updateWithImage:(CIImage *)image faceFeatures:(NSArray *)faceFeatures {

  NSMutableArray *accumulatingImages = [NSMutableArray array];

  for (CIFeature *feature in faceFeatures) {
    NSLog(@"Feature: %@", NSStringFromCGRect(feature.bounds));
    CIImage *croppedImage = [image imageByCroppingToRect:CGRectIntegral(feature.bounds)];
    UIImage *croppedUIImage = [UIImage imageWithCIImage:croppedImage];
    [accumulatingImages addObject:croppedUIImage];
  }

  self.faceImages = accumulatingImages;

  [self.collectionView reloadData];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
  return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
  return self.faceImages.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
  UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellReuseIdentifier
                                                                         forIndexPath:indexPath];

  static NSInteger HackyTag = 32641294; // FIXME

  UIImageView *cellImageView = (UIImageView *)[cell viewWithTag:HackyTag];

  if (cellImageView == nil) {
    CGSize itemSize = [(UICollectionViewFlowLayout *)self.collectionViewLayout itemSize];
    cellImageView = [[UIImageView alloc] initWithFrame:(CGRect) { .origin = CGPointZero, .size = itemSize }];
    cellImageView.contentMode = UIViewContentModeScaleAspectFit;
    cellImageView.tag = HackyTag;
    [cell.contentView addSubview:cellImageView];
  }

  cellImageView.image = self.faceImages[indexPath.item];

  return cell;
}

@end
