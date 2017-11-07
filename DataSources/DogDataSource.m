//
//  DogDataSource.m
//  DoggieMorning
//
//  Created by Rajive Jain on 11/4/17.
//  Copyright © 2017 Rajive Jain. All rights reserved.
//

@import UIKit;
@import Foundation;

#import "DogDataSource.h"
#import "DMDogCell.h"
#import "Dog.h"

static CGFloat const numberOfColumns = 2;
static CGFloat const kGapBetweenCells = 2;

@interface DogDataSource()
@property (nonatomic) DMPhotoWebService *webService;
@property (nonatomic) NSMutableArray *dogs;
@property (nonatomic) NSMutableDictionary *seenDogs;
@property (nonatomic) CGRect screenBounds;
@end

@implementation DogDataSource

- (instancetype)initWith:(DMPhotoWebService *)webService
{
    if (!(self = [super init])) {
        return nil;
    }
    self.webService = webService;
    [self initializeAndClearHistory];
    return self;
}

- (void)initializeAndClearHistory
{
    self.dogs = [[NSMutableArray alloc] init];
    self.seenDogs = [[NSMutableDictionary alloc] init];
    self.screenBounds = [[UIScreen mainScreen] bounds];

    [self clearHistoryFromDisk];
}

- (void)fetchAllDogs:(void (^)(NSError *))callback
{
    [self.webService fetchAllDogs:^(NSArray *dogsJson, NSError *error) {
        if (error) {
            if (callback) {
                callback(error);
            }
        } else {
            self.dogs = [self populateObjectsWith:dogsJson];
            if (callback) {
                callback(nil);
            }
        }
    }];
}

- (NSMutableArray *)populateObjectsWith: (NSArray *)dogsJson
{
    NSMutableArray *dogsToReturn = [[NSMutableArray alloc] init];
    for(NSDictionary *dogJson in dogsJson) {
        Dog *dog = [[Dog alloc] initWithJson: dogJson];
        if (dog != nil) {
            [dogsToReturn addObject:dog];
        }
    }
    return dogsToReturn;
}

#pragma mark - Delegate datasource methods

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.dogs.count;
}

- (nonnull __kindof UICollectionViewCell *)collectionView:(nonnull UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    DMDogCell *cell = (DMDogCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"DogCell" forIndexPath:indexPath];
    Dog *dog = self.dogs[indexPath.row];
    [cell configureWithDog:dog];
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat widthOfCell = (self.screenBounds.size.width - ((numberOfColumns - 1) * kGapBetweenCells))/numberOfColumns;
    return CGSizeMake(widthOfCell, widthOfCell);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return kGapBetweenCells;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return kGapBetweenCells;
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
    // Following approach of adding to seen only after it disappears from screen
    
    @synchronized(self.dogs) {
        BOOL visible = [collectionView.indexPathsForVisibleItems containsObject:indexPath];
        if (!visible) {
            if (indexPath.row < self.dogs.count) {
                Dog *dog = [self.dogs objectAtIndex:indexPath.row];
                @synchronized(self.seenDogs) {
                    [self.seenDogs setObject:dog forKey:indexPath];
                }
            }
        }
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    
    UICollectionView *collectionView = (UICollectionView *)scrollView;
    [self removeItemsAndUpdateCollectionView:collectionView];
    
}

- (void)removeItemsAndUpdateCollectionView:(UICollectionView *)collectionView
{
    @synchronized(self.seenDogs) {
        [self writeSeenHistoryToDisk];
        NSArray *dogsToDelete = [self.seenDogs allValues];
        NSArray *indexPathsToDelete = [self.seenDogs allKeys];
        
        [collectionView performBatchUpdates:^{
            [self findAndDeleteDogsInList:dogsToDelete];
            [collectionView deleteItemsAtIndexPaths:indexPathsToDelete];
        } completion:^(BOOL finished) {
            NSLog(@"seen before deleting: %@", self.seenDogs);
            [self.seenDogs removeAllObjects];
        }];
    }
}

- (void)findAndDeleteDogsInList:(NSArray *)dogsToDelete
{
    @synchronized(self.dogs) {
        for (Dog *dogToDelete in dogsToDelete) {
            NSUInteger deletionIndex = [self.dogs indexOfObject:dogToDelete];
            [self.dogs removeObjectAtIndex: deletionIndex];
        }
    }
}

#pragma mark - Removing and saving to disk

- (void)writeSeenHistoryToDisk
{
    NSString *fileName = [self appFileName];
   
    @synchronized(self.seenDogs) {
        NSMutableDictionary *currentSeen = [self.seenDogs mutableCopy];
        NSMutableDictionary *oldHistory = [self readHistoryFromDisk];
        [currentSeen addEntriesFromDictionary:oldHistory];
        [NSKeyedArchiver archiveRootObject: currentSeen toFile:fileName];
    }
 
    //testing
    NSMutableDictionary *history = [self readHistoryFromDisk];
    NSLog(@"history: %@", history);
}

- (NSMutableDictionary *)readHistoryFromDisk
{
    NSMutableDictionary *seenFromDisk;
    NSString *fileName = [self appFileName];
    seenFromDisk = [NSKeyedUnarchiver unarchiveObjectWithFile:fileName];
    return seenFromDisk;
}

- (NSString *)appFileName
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *appFile = [documentsDirectory stringByAppendingPathComponent:@"dog-history.txt"];
    return appFile;
}

- (void)clearHistoryFromDisk
{
    NSString *fileName = [self appFileName];
    NSMutableDictionary *emptyDictionary = [[NSMutableDictionary alloc] init];
    [NSKeyedArchiver archiveRootObject:emptyDictionary toFile:fileName];
}

- (void)clearHistoryFromDiskAndUpdateView:(UICollectionView *)collectionView
{
    NSMutableDictionary *history = [self readHistoryFromDisk];
    NSArray *historyDogs = [history allValues];
    NSUInteger currentCount = self.dogs.count;
    __block NSMutableArray *indexPathsToInsert = [[NSMutableArray alloc] init];
    @synchronized(self.dogs) {
        [collectionView performBatchUpdates:^{
            [self.dogs addObjectsFromArray:historyDogs];
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
@end
