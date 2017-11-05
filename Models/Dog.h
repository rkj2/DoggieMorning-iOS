//
//  Dog.h
//  DoggieMorning
//
//  Created by Rajive Jain on 11/4/17.
//  Copyright © 2017 Rajive Jain. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Dog : NSObject <NSCoding>

@property (nonatomic) NSString *previewURL;
- (NSString *)fileName;
- (void)saveDog;

@end
