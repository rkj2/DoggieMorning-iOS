//
//  PersistenceService.h
//  DoggieMorning
//
//  Created by Rajive Jain on 11/7/17.
//  Copyright © 2017 Rajive Jain. All rights reserved.
//

@import Foundation;
@import UIKit;

@interface PersistenceService : NSObject

- (NSString *)appFileName;
- (void)writeSeenHistoryToDiskForObjects: (NSMutableDictionary *)objects;
- (NSMutableDictionary *)readHistoryFromDisk;
- (NSDictionary *)readHistoryCopyFromDisk;
- (void)clearHistoryFromDisk;
- (void)clearHistoryFromDiskAndUpdateView:(UICollectionView *)collectionView forObjects: (NSMutableArray *)objects;

@end
