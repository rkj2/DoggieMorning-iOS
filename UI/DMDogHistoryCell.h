//
//  DMDogHistoryCell.h
//  DoggieMorning
//
//  Created by Rajive Jain on 11/7/17.
//  Copyright © 2017 Rajive Jain. All rights reserved.
//

@import UIKit;
#import "Dog.h"

@interface DMDogHistoryCell : UITableViewCell
- (void)configureWithItem:(Dog *)dog;
@end
