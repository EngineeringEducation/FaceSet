//
//  ViewController.m
//  FaceSet
//
//  Created by Wren on 3/23/15.
//  Copyright (c) 2015 Janardan Yri. All rights reserved.
//

#import "ViewController.h"


@interface ViewController ()

@property (nonatomic) CIDetector *faceDetector;

@end


@implementation ViewController

- (instancetype)init {
  return [self initWithCollectionViewLayout:[[UICollectionViewFlowLayout alloc] init]];
}

- (void)viewDidLoad {
  [super viewDidLoad];

  self.faceDetector = [CIDetector detectorOfType:CIDetectorTypeFace context:nil options:nil];
  // Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];



}

@end
