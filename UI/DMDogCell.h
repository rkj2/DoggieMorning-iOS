//
//  DMDogCell.h
//  DoggieMorning
//
//  Created by Rajive Jain on 11/6/17.
//  Copyright © 2017 Rajive Jain. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Dog.h"

@interface DMDogCell : UICollectionViewCell
- (void)configureWithDog: (Dog *)dog;
@end
