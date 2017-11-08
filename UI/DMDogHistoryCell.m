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
    // Initialization code
}

- (void)configureWithItem:(Dog *)dog
{
    self.textLabel.text = [dog fileName];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    
}
@end
