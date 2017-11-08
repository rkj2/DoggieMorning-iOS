//
//  DMDogHistoryCell.m
//  DoggieMorning
//
//  Created by Rajive Jain on 11/7/17.
//  Copyright © 2017 Rajive Jain. All rights reserved.
//

#import "DMDogHistoryCell.h"

@interface DMDogHistoryCell()
@property (weak, nonatomic) IBOutlet UILabel *label;
@end

@implementation DMDogHistoryCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.label.textColor = [UIColor whiteColor];
}

- (void)configureWithItem:(Dog *)dog
{
    self.textLabel.text = [dog fileName];
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    self.label.text = nil;
}
@end
