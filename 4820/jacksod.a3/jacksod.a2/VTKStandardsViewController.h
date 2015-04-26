//
//  VTKStandardsViewController.h
//  jacksod.a2
//
//  Created by Jake Dawkins on 9/22/14.
//  Copyright (c) 2014 Jake Dawkins. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "database.h"

@interface VTKStandardsViewController : UIViewController//UITableViewController <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *settingsTable; /**< The Table the Route will be displayed on. */
@property (nonatomic) NSArray *settings;
@property (nonatomic) UIRefreshControl *refreshController; /**< Our Nitfy refreshController will allow the Pull-to-refresh action to take place. */

@end
