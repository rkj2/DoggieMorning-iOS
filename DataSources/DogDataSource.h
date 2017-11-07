//
//  DogDataSource.h
//  DoggieMorning
//
//  Created by Rajive Jain on 11/4/17.
//  Copyright © 2017 Rajive Jain. All rights reserved.
//

@import UIKit;
#import <Foundation/Foundation.h>
#import "DMPhotoWebService.h"

@interface DogDataSource : NSObject <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

- (instancetype)initWith: (DMPhotoWebService *) webService;

//start the dog fetch process
- (void)fetchAllDogs: (void (^)(NSError *))callback;

//clear archived data
- (void)clearHistoryFromDiskAndUpdateView:(UICollectionView *)collectionView;
@end
