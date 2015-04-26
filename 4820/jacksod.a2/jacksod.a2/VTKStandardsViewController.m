//
//  VTKStandardsViewController.m
//  jacksod.a2
//
//  Created by Jake Dawkins on 9/22/14.
//  Copyright (c) 2014 Jake Dawkins. All rights reserved.
//

#import "VTKStandardsViewController.h"

@interface VTKStandardsViewController ()

@end

@implementation VTKStandardsViewController
{
    NSArray *standards; //hold standards data
    NSArray *standardsDetails; //details of standards
}



- (void)viewDidLoad
{
    [super viewDidLoad];
    standards = [[NSArray alloc]initWithObjects:@"",@"1080p High Quality",@"720p High Quality",@"480p High Quality",@"360p High Quality",@"1080p Standard Quality",@"720p Standard Quality",@"480p Standard Quality",@"360p Standard Quality",@"4K (2160p) Standard Quality",@"2K (1440p) Standard Quality", nil ];
    standardsDetails = [[NSArray alloc]initWithObjects:@"",@"Video: 50Mbps | Audio: 384kbps",@"Video: 30Mbps | Audio: 384kbps",@"Video: 15Mbps | Audio: 384kbps", @"Video: 5Mbps | Audio: 384kbps",@"Video: 8Mbps | Audio: 384kbps", @"Video: 5Mbps | Audio: 384kbps",@"Video: 2.5MBps | Audio: 128kbps", @"Video: 1000Kb/s | Audio: 128kbps", @"Video: 35-45 Mbps | Audio: 384kbps",@"Video: 10Mbps | Audio: 384Mbps",nil];
    
    
    self.edgesForExtendedLayout = UIRectEdgeAll;
    self.tableView.contentInset = UIEdgeInsetsMake(0.0f, 0.0f, CGRectGetHeight(self.tabBarController.tabBar.frame), 0.0f);

    
    
    
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [standards count];
}


//sets display properties for each row
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *simpleTableIdentifier = @"SimpleTableCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    if (cell == nil) {
    //    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"MyIdentifier"];
    }
    
    cell.textLabel.text = [standards objectAtIndex:indexPath.row];
    cell.detailTextLabel.text = [standardsDetails objectAtIndex:indexPath.row];
    return cell;
}

@end
