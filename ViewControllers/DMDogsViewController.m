//
//  DMDogsViewController.m
//  DoggieMorning
//
//  Created by Rajive Jain on 11/6/17.
//  Copyright © 2017 Rajive Jain. All rights reserved.
//

#import "DMDogsViewController.h"
#import "DogDataSource.h"
#import "DMPhotoWebService.h"

@interface DMDogsViewController ()
@property (nonatomic) DogDataSource *dogsDataSource;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@end

@implementation DMDogsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initializeServices];
    [self setUpCollectionView];
    [self loadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)initializeServices
{
    DMPhotoWebService *webService = [[DMPhotoWebService alloc] init];
    self.dogsDataSource = [[DogDataSource alloc] initWith:webService];
}

- (void)setUpCollectionView
{
    self.collectionView.dataSource = self.dogsDataSource;
    self.collectionView.delegate = self.dogsDataSource;
}

- (void)loadData
{
    [self.dogsDataSource fetchAllDogs:^(NSError *error) {
        if (!error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.collectionView reloadData];
            });
        } else {
            //show error message
        }
    }];
}

- (IBAction)fetchMoreData:(id)sender {
    NSLog(@"fetching more...");
}

- (IBAction)clearHistory:(id)sender {
    [self.dogsDataSource clearHistoryFromDiskAndUpdateView:self.collectionView];
}

@end
