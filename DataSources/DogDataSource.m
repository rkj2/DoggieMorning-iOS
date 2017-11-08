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
#import "PersistenceService.h"

static CGFloat const numberOfColumns = 2;
static CGFloat const kGapBetweenCells = 2;

@interface DogDataSource()
@property (nonatomic) DMPhotoWebService *webService;
@property (nonatomic) NSMutableArray *dogs;
@property (nonatomic) NSMutableDictionary *seenDogs;
@property (nonatomic) CGRect screenBounds;
@property (nonatomic) UICollectionView *collectionView;
@property (nonatomic) PersistenceService *persistenceService;
@end

@implementation DogDataSource

- (instancetype)initWith:(DMPhotoWebService *)webService forCollectionView:(UICollectionView *)collectionView
{
    if (!(self = [super init])) {
        return nil;
    }
    self.webService = webService;
    self.collectionView = collectionView;
    self.persistenceService = [[PersistenceService alloc] init];
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

- (void)firstFetch:(void (^)(NSError *))callback
{
    [self.webService firstFetch:^(NSArray *dogsJson, NSError *error) {
        if (error) {
            if (callback) {
                callback(error);
            }
        } else {
            [self populateObjectsWith:dogsJson];
            if (callback) {
                callback(nil);
            }
        }
    }];
}

- (void)fetchMoreDogs:(void (^)(NSError *))callback
{
    [self.webService fetchMoreDogs:^(NSArray *dogsJson, NSError *error) {
        if (error) {
            if (callback) {
                callback(error);
            }
        } else {
            [self populateObjectsWith:dogsJson];
            if (callback) {
                callback(nil);
            }
        }
    }];
}

- (void)populateObjectsWith: (NSArray *)dogsJson
{
    @synchronized(self.dogs) {
        for(NSDictionary *dogJson in dogsJson) {
            Dog *dog = [[Dog alloc] initWithJson: dogJson];
            if (dog != nil) {
                if (![self.persistenceService historyContainsImageId:[dog dogImageId]]) {
                    [self.dogs addObject:dog];
                }
            }
        }
    }
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
            [self.seenDogs removeAllObjects];
        }];
    }
}

- (void)findAndDeleteDogsInList:(NSArray *)dogsToDelete
{
    @synchronized(self.dogs) {
        for (Dog *dogToDelete in dogsToDelete) {
            @autoreleasepool {
                NSUInteger deletionIndex = [self.dogs indexOfObject:dogToDelete];
                [self.dogs removeObjectAtIndex: deletionIndex];
            }
        }
    }
}

#pragma mark - Removing and saving to disk

- (void)writeSeenHistoryToDisk
{
    [self.persistenceService writeSeenHistoryToDiskForObjects:self.seenDogs];
}

- (NSDictionary *)readHistoryCopyFromDisk
{
    return [[self readHistoryFromDisk] copy];
}

- (NSMutableDictionary *)readHistoryFromDisk
{
    return [self.persistenceService readHistoryFromDisk];
}

- (void)clearHistoryFromDisk
{
    [self.persistenceService clearHistoryFromDisk];
}

- (void)clearHistoryFromDiskAndUpdateView:(UICollectionView *)collectionView
{
    [self.persistenceService clearHistoryFromDiskAndUpdateView:collectionView forObjects:self.dogs];
}
@end
