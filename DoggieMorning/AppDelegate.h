//
//  AppDelegate.h
//  DoggieMorning
//
//  Created by Rajive Jain on 11/4/17.
//  Copyright © 2017 Rajive Jain. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong) NSPersistentContainer *persistentContainer;

- (void)saveContext;


@end

