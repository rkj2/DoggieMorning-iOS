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
#import "DMHistoryViewController.h"

@interface DMDogsViewController ()
@property (weak, nonatomic) IBOutlet UIBarButtonItem *showButton;
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
    self.dogsDataSource = [[DogDataSource alloc] initWith:webService forCollectionView:self.collectionView];
}

- (void)setUpCollectionView
{
    self.collectionView.dataSource = self.dogsDataSource;
    self.collectionView.delegate = self.dogsDataSource;
}

- (void)styleButton
{
    [self.showButton setStyle:UIBarButtonItemStylePlain];
}
- (void)loadData
{
    [self.dogsDataSource firstFetch:^(NSError *error) {
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
    [self.dogsDataSource fetchMoreDogs:^(NSError *error) {
        if (!error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.collectionView reloadData];
            });
        } else {
            //show error message
        }
    }];
}

- (IBAction)clearHistory:(id)sender {
    [self.dogsDataSource clearHistoryFromDiskAndUpdateView:self.collectionView];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    //could use shouldPerformSegueWithIdentifier to check for history before seguing and giving better UX experience
    
    if ([[segue identifier] isEqualToString:@"DMShowHistoryID"]) {
        DMHistoryViewController *historyController = (DMHistoryViewController *)[segue destinationViewController];
        NSDictionary *history = [self.dogsDataSource readHistoryCopyFromDisk];
        if ([history allKeys].count > 0) {
            [historyController setHistory:history];
        } else {
            [historyController setHistory:@{}];
        }
    }
}


@end
