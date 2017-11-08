//
//  PersistenceService.m
//  DoggieMorning
//
//  Created by Rajive Jain on 11/7/17.
//  Copyright © 2017 Rajive Jain. All rights reserved.
//

#import "PersistenceService.h"
#import "Dog.h"

@implementation PersistenceService

- (NSString *)appFileName
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *appFile = [documentsDirectory stringByAppendingPathComponent:@"dog-history.txt"];
    return appFile;
}

- (void)writeSeenHistoryToDiskForObjects: (NSMutableDictionary *)objects
{
    NSString *fileName = [self appFileName];
    
    @synchronized(objects) {
        NSMutableDictionary *currentSeen = [objects mutableCopy];
        NSMutableDictionary *oldHistory = [self readHistoryFromDisk];
        [currentSeen addEntriesFromDictionary:oldHistory];
        [NSKeyedArchiver archiveRootObject: currentSeen toFile:fileName];
    }
}

- (void)clearHistoryFromDisk
{
    NSString *fileName = [self appFileName];
    NSMutableDictionary *emptyDictionary = [[NSMutableDictionary alloc] init];
    [NSKeyedArchiver archiveRootObject:emptyDictionary toFile:fileName];
}

- (NSDictionary *)readHistoryCopyFromDisk
{
    return [[self readHistoryFromDisk] copy];
}

- (NSMutableDictionary *)readHistoryFromDisk
{
    NSMutableDictionary *seenFromDisk;
    NSString *fileName = [self appFileName];
    seenFromDisk = [NSKeyedUnarchiver unarchiveObjectWithFile:fileName];
    return seenFromDisk;
}

- (void)clearHistoryFromDiskAndUpdateView:(UICollectionView *)collectionView forObjects:(NSMutableArray *)objects
{
    NSMutableDictionary *history = [self readHistoryFromDisk];
    NSArray *historyDogs = [history allValues];
    __block NSMutableArray *indexPathsToInsert = [[NSMutableArray alloc] init];
    
    NSUInteger currentCount = objects.count;
    
    @synchronized(objects) {
        [collectionView performBatchUpdates:^{
            [objects addObjectsFromArray:historyDogs];
            [historyDogs enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                NSUInteger newRow = currentCount + idx;
                NSIndexPath *newPathToInsert = [NSIndexPath indexPathForItem:newRow inSection:0];
                [indexPathsToInsert addObject:newPathToInsert];
            }];
            [collectionView insertItemsAtIndexPaths:indexPathsToInsert];
        } completion:^(BOOL finished) {
        }];
    }
    
    [self clearHistoryFromDisk];
}

- (BOOL)historyContainsImageId:(NSString *)dogImageId
{
    NSDictionary *data = [self readHistoryCopyFromDisk];
    NSArray *values = [data allValues];
    NSPredicate *foundImageIdPredicate = [NSPredicate predicateWithBlock:^BOOL(id  _Nullable evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
        if ([evaluatedObject isKindOfClass:[Dog class]] && values.count > 0) {
            Dog *evaluatedObjectDog = (Dog *)evaluatedObject;
            return [[evaluatedObjectDog dogImageId] isEqualToString:dogImageId];
        } else {
            return false;
        }
    }];
    return [values filteredArrayUsingPredicate:foundImageIdPredicate].count > 0;
}
@end
