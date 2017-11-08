//
//  DMHistoryViewController.m
//  DoggieMorning
//
//  Created by Rajive Jain on 11/7/17.
//  Copyright © 2017 Rajive Jain. All rights reserved.
//

#import "DMHistoryViewController.h"
#import "DMDogHistoryCell.h"

@interface DMHistoryViewController () <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@end

@implementation DMHistoryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.navigationItem.title = @"History";
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (self.history) {
        [self.tableView reloadData];
    }
}

#pragma mark - Datasource and delegate calls

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.history allValues].count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DMDogHistoryCell *cell = (DMDogHistoryCell *)[tableView dequeueReusableCellWithIdentifier:@"DMDogHistoryCellID"];
    Dog *dog = [self.history allValues][indexPath.row];
    [cell configureWithItem:dog];
    return cell;
}

@end
