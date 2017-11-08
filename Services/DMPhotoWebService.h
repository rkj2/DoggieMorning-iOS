//
//  DMPhotoWebService.h
//  DoggieMorning
//
//  Created by Rajive Jain on 11/5/17.
//  Copyright © 2017 Rajive Jain. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DMPhotoWebService : NSObject
- (void)firstFetch: (void (^)(NSArray *, NSError *))callback;
- (void)fetchMoreDogs: (void (^)(NSArray *dogs, NSError *error))callback;
@end
