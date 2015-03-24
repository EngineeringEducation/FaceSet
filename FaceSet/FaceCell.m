//
//  FaceCell.m
//  FaceSet
//
//  Created by Wren on 3/23/15.
//  Copyright (c) 2015 Janardan Yri. All rights reserved.
//

#import "FaceCell.h"

@implementation FaceCell

- (instancetype)initWithFrame:(CGRect)frame {
  self = [super initWithFrame:frame];
  if (self) {
    self.imageView = ^{
      UIImageView *imageView = [[UIImageView alloc] init];
      imageView.contentMode = UIViewContentModeScaleAspectFit;
      [self.contentView addSubview:imageView];
      return imageView;
    }();

  }
  return self;
}

@end
