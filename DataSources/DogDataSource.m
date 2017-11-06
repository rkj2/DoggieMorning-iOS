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
@end

@implementation DogDataSource

- (instancetype)initWith:(DMPhotoWebService *)webService
{
    if (!(self = [super init])) {
        return nil;
    }
    self.webService = webService;
    self.dogs = [[NSMutableArray alloc] init];
    return self;
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
    CGRect bounds = [[UIScreen mainScreen] bounds];
    CGFloat widthOfCell = (bounds.size.width - ((numberOfColumns - 1) * kGapBetweenCells))/numberOfColumns;
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

@end
