//
//  DMDogCell.m
//  DoggieMorning
//
//  Created by Rajive Jain on 11/6/17.
//  Copyright © 2017 Rajive Jain. All rights reserved.
//

#import "DMDogCell.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface DMDogCell()
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@end

@implementation DMDogCell

- (void)configureWithDog:(Dog *)dog
{
    NSURL *imageUrl = [NSURL URLWithString:[dog previewURL]];
    [self.imageView sd_setImageWithURL:imageUrl placeholderImage:[UIImage imageNamed:@"placeholder"]];
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    [self.imageView setImage:nil];
}
@end
