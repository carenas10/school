//
//  VTKStandardsViewController.m
//  jacksod.a2
//
//  Created by Jake Dawkins on 9/22/14.
//  Copyright (c) 2014 Jake Dawkins. All rights reserved.
//

#import "VTKStandardsViewController.h"
#import "VTKCodecDetailViewController.h"

@interface VTKStandardsViewController ()
@property (strong,nonatomic) VidSetting *settingInFocus;
@end

@implementation VTKStandardsViewController

@synthesize settingsTable;
@synthesize settings;
@synthesize refreshController;
@synthesize settingInFocus;


- (void)viewDidLoad
{
    [super viewDidLoad];
    settings = [Database database].getSettings;
    refreshController = [[UIRefreshControl alloc] init];
    [refreshController addTarget:self
                          action:@selector(refresh)
                forControlEvents:UIControlEventValueChanged];
    [settingsTable addSubview:refreshController];
    
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if([segue.identifier isEqualToString:@"detailCodecView"]){
        VTKCodecDetailViewController *destination = [segue destinationViewController];
        destination.detailSetting =settingInFocus;
    }
}





//The actual action that takes place when we pull and then release.
-(void)refresh{
    settings = [Database database].getSettings;
    [settingsTable reloadData];
    [refreshController endRefreshing];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [settings count];
}


//sets display properties for each row
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *simpleTableIdentifier = @"SimpleTableCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
    }

    cell.textLabel.text = ((VidSetting *)[settings objectAtIndex:indexPath.row]).name;
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    settingInFocus = [settings objectAtIndex:indexPath.row];
    [self performSegueWithIdentifier:@"detailCodecView" sender:self];
    
}



@end
